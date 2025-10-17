import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/chat_screens/customer_agent_chat_screen.dart';
import 'package:runpro_9ja/services/customer_services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../auth/Auth_services/auth_service.dart';
import '../services/tracking_service.dart';
import 'add_review_screen.dart';
import 'map_view_screen.dart';

class TrackingPage extends StatefulWidget {
  final String? initialOrderId;
  final List<dynamic>? customerOrders;
  final List<String>? recentOrderIds;

  const TrackingPage({
    super.key,
    this.initialOrderId,
    this.customerOrders,
    this.recentOrderIds,
  });

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final TextEditingController _orderIdController = TextEditingController();
  final AuthService _authService = AuthService();
  List<dynamic> recentOrders = [];
  Map<String, dynamic>? currentOrder;
  bool _isLoading = false;
  bool _searchPerformed = false;
  bool _isAuthenticated = false;
  WebSocketChannel? _channel;
  List<Map<String, dynamic>> _locationHistory = [];
  Map<String, dynamic>? _liveLocation;
  String? _authToken;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    try {
      final String? token = await _authService.getToken();
      setState(() {
        _isAuthenticated = token != null && token.isNotEmpty;
        _authToken = token;
      });

      if (!_isAuthenticated) return;

      // Load current user data
      await _loadUserData();

      if (widget.customerOrders != null && widget.customerOrders!.isNotEmpty) {
        setState(() {
          recentOrders = widget.customerOrders!;
        });
      }

      if (widget.recentOrderIds != null && widget.recentOrderIds!.isNotEmpty) {
        _orderIdController.text = widget.recentOrderIds!.first;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchOrder();
        });
      } else if (widget.initialOrderId != null) {
        _orderIdController.text = widget.initialOrderId!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchOrder();
        });
      }

      if (widget.customerOrders == null || widget.customerOrders!.isEmpty) {
        await _loadRecentOrders();
      }
    } catch (e) {
      _showError('Failed to initialize: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getUserData();
      if (userData != null) {
        setState(() {
          _currentUserId = userData['id']?.toString();
        });

        print('✅ Customer user data loaded:');
        print('   User ID: $_currentUserId');
        print('   Token: ${_authToken != null ? "✓ Available" : "✗ Missing"}');
      } else {
        print('❌ No customer user data found in token');

        // Fallback: Try to get profile from API
        try {
          final profile = await _authService.getUserProfile();
          if (profile.isNotEmpty) {
            _currentUserId = profile['id']?.toString();
            print('✅ Loaded customer data from API profile');
          }
        } catch (e) {
          print('❌ Error loading customer profile from API: $e');
        }
      }
    } catch (e) {
      print('❌ Error loading customer auth data: $e');
    }
  }

  Future<void> _loadRecentOrders() async {
    if (!_isAuthenticated) return;
    try {
      final orders = await CustomerService(_authService).getCustomerOrders();
      if (orders is List) {
        setState(() {
          recentOrders = orders;
        });
      } else {
        setState(() {
          recentOrders = [];
        });
      }
    } catch (e) {
      _handleAuthError();
    }
  }

  Future<void> _searchOrder() async {
    if (!_isAuthenticated) {
      _showAuthError();
      return;
    }

    final orderId = _orderIdController.text.trim();
    if (orderId.isEmpty) {
      _showError('Please enter an order ID');
      return;
    }

    setState(() {
      _isLoading = true;
      _searchPerformed = true;
      _liveLocation = null;
    });

    try {
      print('🔍 Searching for order: $orderId');

      // METHOD 1: Try getting order directly from API
      try {
        final orderData = await TrackingService.getOrderDetails(orderId);
        print('✅ Order found via API: $orderData');

        Map<String, dynamic> order;
        if (orderData['order'] != null) {
          order = _safeMapConversion(orderData['order']);
        } else if (orderData['data'] != null) {
          order = _safeMapConversion(orderData['data']);
        } else {
          order = _safeMapConversion(orderData);
        }

        setState(() {
          currentOrder = order;
          _locationHistory = _parseOrderTimeline(order);
        });

        if (_isDeliveryOrder(order)) {
          await _getLiveLocation(orderId);
          await _connectToWebSocket(orderId);
        }
        return; // Success - exit method

      } catch (apiError) {
        print('❌ API search failed: $apiError');
        // Continue to METHOD 2
      }

      // METHOD 2: Search in recent orders (fallback)
      print('🔄 Searching in recent orders...');
      final foundOrder = _searchInRecentOrders(orderId);

      if (foundOrder != null) {
        print('✅ Order found in recent orders');
        setState(() {
          currentOrder = foundOrder;
          _locationHistory = _parseOrderTimeline(foundOrder);
        });

        if (_isDeliveryOrder(foundOrder)) {
          await _getLiveLocation(orderId);
          await _connectToWebSocket(orderId);
        }
        return; // Success - exit method
      }

      // METHOD 3: Try fetching all customer orders and search
      print('🔄 Fetching all customer orders...');
      try {
        final allOrders = await CustomerService(_authService).getCustomerOrders();

        if (allOrders is List) {
          for (final order in allOrders) {
            final orderMap = _safeMapConversion(order);
            final currentOrderId = _getOrderId(orderMap);

            if (currentOrderId == orderId ||
                currentOrderId.startsWith(orderId) ||
                orderId.startsWith(currentOrderId)) {
              print('✅ Order found in customer orders');
              setState(() {
                currentOrder = orderMap;
                _locationHistory = _parseOrderTimeline(orderMap);
                // Update recent orders too
                if (!recentOrders.contains(orderMap)) {
                  recentOrders.insert(0, orderMap);
                }
              });

              if (_isDeliveryOrder(orderMap)) {
                await _getLiveLocation(orderId);
                await _connectToWebSocket(orderId);
              }
              return; // Success - exit method
            }
          }
        }
      } catch (e) {
        print('❌ Error fetching customer orders: $e');
      }

      // If we get here, order was not found anywhere
      throw Exception('Order not found. Please verify the order ID.');

    } catch (e) {
      print('❌ Final error searching order: $e');
      _handleOrderError(e);
      setState(() {
        currentOrder = null;
        _locationHistory = [];
        _liveLocation = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic>? _searchInRecentOrders(String orderId) {
    for (final order in recentOrders) {
      try {
        final orderMap = _safeMapConversion(order);
        final currentOrderId = _getOrderId(orderMap);

        // Check exact match or partial match
        if (currentOrderId == orderId ||
            currentOrderId.startsWith(orderId) ||
            orderId.startsWith(currentOrderId)) {
          return orderMap;
        }
      } catch (e) {
        print('❌ Error checking order: $e');
      }
    }
    return null;
  }

  void _handleOrderError(dynamic e) {
    final errorMessage = e.toString().toLowerCase();

    if (errorMessage.contains('403') || errorMessage.contains('access denied')) {
      _showError('Access denied. This order may belong to another account.');
    } else if (errorMessage.contains('404') || errorMessage.contains('not found')) {
      _showError('Order not found. Please check the order ID and try again.');
    } else if (errorMessage.contains('401') || errorMessage.contains('authentication')) {
      _handleAuthError();
    } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
      _showError('Network error. Please check your internet connection.');
    } else if (errorMessage.contains('timeout')) {
      _showError('Request timeout. Please try again.');
    } else {
      _showError('Unable to load order. Try copying the full order ID from your order history.');
    }
  }

  String _getOrderId(Map<String, dynamic> order) {
    final id = order['_id']?.toString() ??
        order['id']?.toString() ??
        order['orderId']?.toString() ??
        order['order_id']?.toString();

    if (id == null || id.isEmpty) {
      print('⚠️ No ID found in order. Available keys: ${order.keys.join(", ")}');
      return 'Unknown ID';
    }

    return id.trim();
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _orderIdController,
                decoration: InputDecoration(
                  hintText: "Enter order ID",
                  helperText: "Enter at least 8 characters",
                  helperStyle: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  errorText: _orderIdController.text.isNotEmpty &&
                      _orderIdController.text.trim().length < 8
                      ? "Order ID too short"
                      : null,
                ),
                onSubmitted: (_) => _searchOrder(),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _searchOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white
                  )
              )
                  : const Text("Track", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        if (!_searchPerformed && recentOrders.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Tip: Tap on any recent order below to track it',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    try {
      if (order.isEmpty) {
        print('⚠️ Empty order object');
        return Container();
      }

      final orderId = _getOrderId(order);
      if (orderId == 'Unknown ID') {
        print('⚠️ Order card has unknown ID: $order');
        return Container();
      }

      final status = _getOrderStatus(order);
      final statusInfo = _getStatusInfo(status);

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: statusInfo.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8)
            ),
            child: Icon(statusInfo.icon, color: statusInfo.color, size: 20),
          ),
          title: Text(
              _getServiceName(order),
              style: const TextStyle(fontWeight: FontWeight.bold)
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}'),
              Text(_formatDate(order['createdAt']?.toString())),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: statusInfo.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)
            ),
            child: Text(
                statusInfo.text,
                style: TextStyle(color: statusInfo.color, fontSize: 12)
            ),
          ),
          onTap: () {
            _orderIdController.text = orderId;
            _searchOrder();
          },
        ),
      );
    } catch (e) {
      print('❌ Error building order card: $e');
      return Container();
    }
  }

  Widget _buildOrderHeader(Map<String, dynamic> order) {
    final fullOrderId = _getOrderId(order);
    final displayId = fullOrderId.length > 8
        ? fullOrderId.substring(0, 8)
        : fullOrderId;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Order #$displayId",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                  )
              ),
              const SizedBox(height: 4),
              Text(
                  _getServiceType(order),
                  style: TextStyle(color: Colors.grey.shade600)
              ),
            ],
          ),
        ),
        if (_isDeliveryOrder(order))
          TextButton.icon(
            onPressed: () => _viewInMap(order),
            icon: const Icon(Icons.map, size: 18),
            label: const Text("View Map"),
          ),
      ],
    );
  }

  Map<String, dynamic> _safeMapConversion(dynamic data) {
    try {
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return {};
    } catch (e) {
      return {};
    }
  }

  bool _isDeliveryOrder(Map<String, dynamic> order) {
    final orderType = order['orderType']?.toString().toLowerCase() ?? '';
    return orderType == 'delivery' || orderType == 'errand' ||
        (orderType == 'professional' && order['serviceScale'] == 'minimum');
  }

  Future<void> _connectToWebSocket(String orderId) async {
    try {
      _channel?.sink.close();
      final String? token = await _authService.getToken();
      if (token == null) return;

      _channel = TrackingService.connectToOrderTracking(orderId, token);
      _channel!.stream.listen(
            (data) {
          try {
            final update = json.decode(data);
            if (update['type'] == 'locationUpdate') {
              _handleLocationUpdate(update);
            } else if (update['type'] == 'ORDER_STATUS_UPDATED') {
              _handleStatusUpdate(update);
            }
          } catch (e) {}
        },
        onError: (error) {},
        onDone: () {},
      );
    } catch (e) {}
  }

  void _handleLocationUpdate(Map<String, dynamic> update) {
    setState(() {
      _liveLocation = {
        'coordinates': update['coordinates'] is List ? update['coordinates'] : null,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'realtime'
      };
    });
  }

  void _handleStatusUpdate(Map<String, dynamic> update) {
    if (currentOrder != null) {
      _searchOrder();
    }
  }

  Future<void> _getLiveLocation(String orderId) async {
    try {
      final locationData = await TrackingService.getLiveLocation(orderId);
      if (locationData['data'] != null) {
        setState(() {
          _liveLocation = locationData['data'];
        });
      }
    } catch (e) {}
  }

  List<Map<String, dynamic>> _parseOrderTimeline(Map<String, dynamic> order) {
    final List<Map<String, dynamic>> timeline = [];
    try {
      if (order['timeline'] is List) {
        for (final event in order['timeline']) {
          if (event is Map) {
            timeline.add({
              'type': 'status_update',
              'status': event['status']?.toString() ?? 'unknown',
              'note': event['note']?.toString() ?? 'Status updated',
              'timestamp': event['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
            });
          }
        }
      }

      timeline.add({
        'type': 'order_created',
        'status': 'requested',
        'note': 'Order created',
        'timestamp': order['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      });

      timeline.sort((a, b) {
        final timeA = a['timestamp'] as String;
        final timeB = b['timestamp'] as String;
        return timeA.compareTo(timeB);
      });
    } catch (e) {}
    return timeline;
  }

  void _handleAuthError() {
    setState(() {
      _isAuthenticated = false;
    });
    _showAuthError();
  }

  void _showAuthError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Required'),
        content: const Text('You need to be logged in to track orders.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToLogin();
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return _buildUnauthenticatedView();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Track Order",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_searchPerformed && currentOrder != null)
                      _buildOrderTracking(currentOrder!),
                    if (_searchPerformed && currentOrder == null && !_isLoading)
                      _buildNoResults(),
                    if (!_searchPerformed)
                      _buildPlaceholder(),
                    const SizedBox(height: 20),
                    _buildRecentOrders(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedView() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        title: const Text("Track Order", style: TextStyle(color: Colors.black)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.login, size: 64, color: Colors.grey),
              const SizedBox(height: 20),
              const Text('Authentication Required', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              const Text('Please login to track your orders', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToLogin,
                child: const Text('Login Now'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTracking(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(order),
          const SizedBox(height: 16),
          _buildOrderStatusSection(order),
          const SizedBox(height: 16),
          _buildOrderDetails(order),
          if (_isDeliveryOrder(order)) ...[
            const SizedBox(height: 16),
            _buildMapSection(order),
          ],
          if (_isDeliveryOrder(order) && _liveLocation != null) ...[
            const SizedBox(height: 16),
            _buildLiveLocationSection(),
          ],
          if (_locationHistory.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildTimelineSection(),
          ],
          const SizedBox(height: 16),
          _buildActionButtons(order),
        ],
      ),
    );
  }

  Widget _buildMapSection(Map<String, dynamic> order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Location Tracking", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.map, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Track on Map', style: TextStyle(color: Colors.blue.shade800)),
                    Text('View real-time location and route', style: TextStyle(color: Colors.blue.shade600, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _viewInMap(order),
                icon: const Icon(Icons.map, size: 16),
                label: const Text("Open Map"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiveLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Live Location", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.green.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Agent Location', style: TextStyle(color: Colors.green.shade800)),
                    Text(_getFormattedCoordinates(), style: TextStyle(color: Colors.green.shade600, fontSize: 12)),
                  ],
                ),
              ),
              if (_channel != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.green.shade700),
                      const SizedBox(width: 4),
                      Text('Live', style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _getFormattedCoordinates() {
    if (_liveLocation == null) return 'Location not available';
    try {
      final coordinates = _liveLocation!['coordinates'];
      if (coordinates is List && coordinates.length >= 2) {
        final lat = coordinates[1];
        final lng = coordinates[0];
        if (lat != null && lng != null) {
          return 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
        }
      }
      return 'Coordinates available';
    } catch (e) {
      return 'Location data';
    }
  }

  Widget _buildOrderStatusSection(Map<String, dynamic> order) {
    final status = _getOrderStatus(order);
    final statusInfo = _getStatusInfo(status);
    final progress = _getOrderProgress(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusInfo.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusInfo.icon, size: 16, color: statusInfo.color),
              const SizedBox(width: 6),
              Text(statusInfo.text, style: TextStyle(color: statusInfo.color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          color: statusInfo.color,
        ),
        const SizedBox(height: 8),
        Text('${(progress * 100).toInt()}% Complete', style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildOrderDetails(Map<String, dynamic> order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Order Details", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildDetailRow('Service:', _getServiceName(order)),
        _buildDetailRow('Details:', order['details']?.toString() ?? 'No details'),
        _buildDetailRow('Location:', _getLocation(order)),
        _buildDetailRow('Service Scale:', order['serviceScale']?.toString() ?? 'Standard'),
        _buildDetailRow('Created:', _formatDate(order['createdAt']?.toString())),
        if (order['scheduledDate'] != null) _buildDetailRow('Scheduled:', _formatDate(order['scheduledDate']?.toString())),
        if (order['scheduledTime'] != null) _buildDetailRow('Time:', order['scheduledTime']?.toString() ?? ''),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(color: Colors.grey.shade700))),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Order Timeline", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        for (var event in _locationHistory)
          _buildTimelineEvent(event),
      ],
    );
  }

  Widget _buildTimelineEvent(Map<String, dynamic> event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: _getEventColor(event), shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getEventTitle(event), style: const TextStyle(fontWeight: FontWeight.w500)),
                if (event['note'] != null) Text(event['note']!, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                Text(_formatTimestamp(event['timestamp']), style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order) {
    return Row(
      children: [
        if (order['status'] == 'accepted' || order['status'] == 'in-progress')
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _contactAgent(order),
              icon: const Icon(Icons.message, size: 18),
              label: const Text("Contact Agent"),
            ),
          ),
        const SizedBox(width: 8),
        if (order['status'] == 'completed' && order['rating'] == null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _addReview(order),
              icon: const Icon(Icons.star, size: 18),
              label: const Text("Add Review"),
            ),
          ),
      ],
    );
  }

  void _contactAgent(Map<String, dynamic> order) {
    // Check if auth data is available
    if (_authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication required. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User information not available. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final agent = order['agent'];
    if (agent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No agent assigned to this order yet'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final agentId = agent['_id']?.toString() ?? agent['id']?.toString();
    if (agentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agent information not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print('🚀 Opening chat with agent:');
    print('   Agent ID: $agentId');
    print('   Agent Name: ${agent['fullName'] ?? agent['name']}');
    print('   Order ID: ${_getOrderId(order)}');
    print('   Customer ID: $_currentUserId');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerAgentChatScreen(
          agentId: agentId,
          agentName: agent['fullName'] ?? agent['name'] ?? 'Agent',
          agentImage: agent['profileImage'] ?? agent['image'] ?? 'https://via.placeholder.com/150',
          orderId: _getOrderId(order),
          authToken: _authToken!,
          currentUserId: _currentUserId!,
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text("Order not found", style: TextStyle(color: Colors.grey)),
          Text("Please check the order ID and try again", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Column(
        children: [
          Icon(Icons.local_shipping, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text("Track Your Order", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("Enter your order ID to see real-time updates", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recent Orders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        recentOrders.isEmpty
            ? _buildEmptyRecentOrders()
            : Column(
          children: recentOrders.map((order) {
            try {
              Map<String, dynamic> orderMap = {};
              if (order is Map<String, dynamic>) {
                orderMap = order;
              } else if (order is Map) {
                orderMap = Map<String, dynamic>.from(order);
              }
              return _buildOrderCard(orderMap);
            } catch (e) {
              return Container();
            }
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyRecentOrders() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text("No recent orders", style: TextStyle(color: Colors.grey)),
          Text("Your recent orders will appear here", style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  // Data access methods for your database structure
  String _getServiceType(Map<String, dynamic> order) {
    if (order['orderType'] == 'professional') {
      return 'Professional Service';
    }
    return order['serviceType']?.toString() ?? 'Service';
  }

  String _getServiceName(Map<String, dynamic> order) {
    if (order['orderType'] == 'professional') {
      return 'Professional Service';
    }
    return order['serviceType']?.toString() ?? 'Service';
  }

  String _getLocation(Map<String, dynamic> order) => order['location']?.toString() ?? 'Location not specified';

  String _getOrderStatus(Map<String, dynamic> order) => order['status']?.toString() ?? 'requested';

  StatusInfo _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'requested': return StatusInfo(Icons.pending, Colors.orange, 'Requested');
      case 'accepted': return StatusInfo(Icons.assignment_turned_in, Colors.blue, 'Accepted');
      case 'in-progress': return StatusInfo(Icons.directions_bike, Colors.orange, 'In Progress');
      case 'completed': return StatusInfo(Icons.check_circle, Colors.green, 'Completed');
      case 'cancelled': return StatusInfo(Icons.cancel, Colors.red, 'Cancelled');
      default: return StatusInfo(Icons.help, Colors.grey, 'Requested');
    }
  }

  double _getOrderProgress(String status) {
    switch (status.toLowerCase()) {
      case 'requested': return 0.2;
      case 'accepted': return 0.4;
      case 'in-progress': return 0.7;
      case 'completed': return 1.0;
      case 'cancelled': return 0.0;
      default: return 0.1;
    }
  }

  Color _getEventColor(Map<String, dynamic> event) {
    switch (event['type']) {
      case 'order_created': return Colors.green;
      case 'status_update': return Colors.blue;
      case 'location_update': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _getEventTitle(Map<String, dynamic> event) {
    switch (event['type']) {
      case 'order_created': return 'Order Created';
      case 'status_update': return 'Status Updated';
      case 'location_update': return 'Location Updated';
      default: return 'Order Updated';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final date = DateTime.parse(timestamp);
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')} - ${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid timestamp';
    }
  }

  void _viewInMap(Map<String, dynamic> order) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MapViewPage(
              order: order,
              liveLocation: _liveLocation,
              locationHistory: _locationHistory,
            )
        )
    );
  }

  void _addReview(Map<String, dynamic> order) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewPage(order: order)));
  }
}

class StatusInfo {
  final IconData icon;
  final Color color;
  final String text;
  StatusInfo(this.icon, this.color, this.text);
}