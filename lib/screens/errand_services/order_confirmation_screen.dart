import 'dart:async';
import 'package:flutter/material.dart';
import 'package:runpro_9ja/auth/Auth_services/auth_service.dart';

import '../../models/customer_models.dart';
import '../../services/customer_services.dart';
import '../payment_screens/payment_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final String serviceType;
  final String orderId;

  const OrderConfirmationScreen({
    super.key,
    required this.orderData,
    required this.serviceType,
    required this.orderId,
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  final CustomerService _customerService = CustomerService(AuthService());
  bool _isLoading = true;
  bool _isRefreshing = false;
  CustomerOrder? _orderDetails;
  Timer? _refreshTimer;
  int _refreshCount = 0;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrderDetails() async {
    try {
      // **PRIORITY: Try to get ID from multiple sources**
      final orderId = widget.orderData['orderId'] ??
          widget.orderData['_id'] ??
          widget.orderData['id'] ??
          widget.orderId;  // Use widget.orderId as fallback

      print("🆔 ===== ORDER ID DEBUG =====");
      print("   - From orderData['orderId']: ${widget.orderData['orderId']}");
      print("   - From orderData['_id']: ${widget.orderData['_id']}");
      print("   - From orderData['id']: ${widget.orderData['id']}");
      print("   - From widget.orderId: ${widget.orderId}");
      print("   - Final orderId: $orderId");
      print("   - Full order data: ${widget.orderData}");
      print("============================");

      if (orderId != null && _isValidObjectId(orderId.toString())) {
        // We have a valid MongoDB ID - fetch from API
        print("✅ Fetching order with valid ID: $orderId");
        final order = await _customerService.getOrderById(orderId.toString());

        if (mounted) {
          setState(() {
            _orderDetails = order;
            _isLoading = false;
          });
        }

        print("✅ Order loaded successfully!");
        print("   - Order ID: ${order.id}");
        print("   - Status: ${order.status}");

      } else {
        // Invalid or missing ID
        print("❌ INVALID OR MISSING ORDER ID!");
        print("   - Received: $orderId");
        print("   - Is valid MongoDB ID: false");

        if (mounted) {
          setState(() {
            _orderDetails = _createOrderFromData(widget.orderData);
            _isLoading = false;
          });

          // Show error to user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order created but cannot load details. Please check your orders list.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      print("❌ Error loading order details: $e");

      if (mounted) {
        setState(() {
          _orderDetails = _createOrderFromData(widget.orderData);
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load order: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _waitForOrderCreation() async {
    // If we have order creation data but no proper ID,
    // we might need to poll for the actual order creation
    final serviceType = widget.serviceType;
    final orderData = widget.orderData;

    // Check if this looks like a recently created order that might not have ID yet
    if (orderData.containsKey('serviceType') || orderData.containsKey('items')) {
      print("🔄 Order might be processing, will use temporary data");
      setState(() {
        _orderDetails = _createOrderFromData(widget.orderData);
      });

      // You might want to implement a retry mechanism here
      // to check if the backend eventually creates the order
    } else {
      setState(() {
        _orderDetails = _createOrderFromData(widget.orderData);
      });
    }
  }

  bool _isValidObjectId(String id) {
    // MongoDB ObjectId is 24-character hex string
    final objectIdRegex = RegExp(r'^[0-9a-fA-F]{24}$');
    final isValid = objectIdRegex.hasMatch(id) && !id.startsWith('temp_');
    print("🔍 Validating ID '$id': $isValid");
    return isValid;
  }
// Also update the auto-refresh to check for valid ObjectId
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_orderDetails == null || !_isValidObjectId(_orderDetails!.id)) {
        print("🔄 Skipping refresh for temporary order");
        return;
      }

      try {
        final updatedOrder = await _customerService.getOrderById(_orderDetails!.id);

        if (mounted) {
          setState(() {
            _orderDetails = updatedOrder;
            _refreshCount++;
          });
        }

        print("🔥 Current Order Status: ${updatedOrder.status}");
        print("🔄 Order ID: ${updatedOrder.id}");

        // Stop refreshing when order reaches terminal states
        if (_shouldStopRefresh(updatedOrder.status)) {
          timer.cancel();
          print("🛑 Stopped auto-refresh for order: ${updatedOrder.status}");
        }
      } catch (e) {
        print("❌ Error refreshing order: $e");
      }
    });
  }

// Update the manual refresh as well
  Future<void> _manualRefresh() async {
    if (_isRefreshing) return;

    // Don't refresh temporary orders
    if (_orderDetails != null && !_isValidObjectId(_orderDetails!.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot refresh temporary orders'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      if (_orderDetails != null) {
        final updatedOrder = await _customerService.getOrderById(_orderDetails!.id);
        setState(() {
          _orderDetails = updatedOrder;
          _refreshCount++;
        });
      }
    } catch (e) {
      print("❌ Error manually refreshing order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }
  bool _shouldStopRefresh(String status) {
    final stoppedStatuses = ['paid', 'completed', 'cancelled', 'rejected', 'failed'];
    return stoppedStatuses.contains(status.toLowerCase());
  }
  CustomerOrder _createOrderFromData(Map<String, dynamic> data) {
    return CustomerOrder(
      id: data['_id'] ?? data['id'] ?? 'temp_${DateTime.now().millisecondsSinceEpoch}',
      serviceCategory: data['serviceType'] ?? widget.serviceType,
      description: data['itemsDescription'] ?? data['packageDescription'] ?? 'Service Order',
      location: data['fromAddress'] ?? 'Not specified',
      price: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'requested',
      createdAt: DateTime.now(),
      isPublic: data['isPublic'] ?? false,
      isDirectOffer: data['isDirectOffer'] ?? false,
    );
  }

  bool get _canProceedToPayment {
    if (_orderDetails == null) return false;

    final status = _orderDetails!.status.toLowerCase();
    print("🎯 Checking payment eligibility - Status: $status");

    // Expanded list of statuses that allow payment
    final acceptedStatuses = [
      'accepted',
      'agent_selected',
      'quotation_accepted',
      'assigned',
      'confirmed',
      'approved',
      'ready_for_payment'
    ];

    return acceptedStatuses.contains(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Confirmation',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          // Refresh button in app bar
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.refresh, color: Colors.black),
            onPressed: _manualRefresh,
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildConfirmationContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF2E7D32)),
          SizedBox(height: 16),
          Text('Loading order details...'),
        ],
      ),
    );
  }

  Widget _buildConfirmationContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Status icon with refresh animation
          _buildStatusIcon(),
          const SizedBox(height: 20),
          const Text(
            'Order Placed Successfully!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 8),
          Text(
            'Your ${widget.serviceType} order has been received',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildOrderDetailsCard(),
          const SizedBox(height: 20),
          _buildNextSteps(),
          const SizedBox(height: 30),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    return _isRefreshing
        ? SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          // Rotating refresh icon
          Center(
            child: AnimatedRotation(
              turns: _isRefreshing ? 1 : 0,
              duration: const Duration(seconds: 1),
              child: Icon(
                Icons.refresh,
                size: 40,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    )
        : Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, color: Color(0xFF2E7D32), size: 40),
    );
  }

  Widget _buildOrderDetailsCard() {
    final order = _orderDetails!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Order Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              // Refresh count indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Refreshed: $_refreshCount',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Order ID', order.id),
          const SizedBox(height: 12),
          _buildDetailRow('Service Type', _getServiceType(order.serviceCategory)),
          const SizedBox(height: 12),
          _buildDetailRow('Status', order.statusText, valueColor: order.statusColor),
          const SizedBox(height: 12),
          _buildDetailRow('Total Amount', order.formattedPrice, valueColor: Color(0xFF2E7D32), valueWeight: FontWeight.bold),
          const SizedBox(height: 12),
          _buildDetailRow('Order Date', _formatDate(order.createdAt)),
          const SizedBox(height: 12),
          _buildDetailRow('Location', order.location),
          if (order.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailRow('Description', order.description),
          ],

          // Refresh info section
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[600], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _refreshCount == 0
                        ? 'Auto-refreshing every 3 seconds'
                        : 'Last refreshed: ${_formatTime(DateTime.now())}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Debug information
          const SizedBox(height: 16),
          // In _buildOrderDetailsCard(), update the debug section:
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Debug Info:', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                Text('Order ID: "${order.id}"', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                Text('Order Type: ${_isValidObjectId(order.id) ? "Persistent" : "Temporary"}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                Text('Raw Status: "${order.status}"', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                Text('Can Pay: $_canProceedToPayment', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                Text('Auto-refresh: ${_refreshTimer?.isActive ?? false}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, FontWeight? valueWeight}) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700))),
        Expanded(flex: 3, child: Text(value, style: TextStyle(color: valueColor ?? Colors.black, fontWeight: valueWeight ?? FontWeight.normal), textAlign: TextAlign.right)),
      ],
    );
  }

  Widget _buildNextSteps() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What happens next?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
          const SizedBox(height: 12),
          _buildStep('1. Order received and processing'),
          _buildStep('2. Looking for available agents'),
          _buildStep('3. Agent will be assigned soon'),
          _buildStep('4. Track your order in real-time'),
          const SizedBox(height: 8),
          Text(
            '• Auto-refreshing every 3 seconds',
            style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
          ),
          Text(
            '• Tap refresh button for instant update',
            style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [const Icon(Icons.check_circle, color: Colors.blue, size: 16), const SizedBox(width: 8), Expanded(child: Text(text))]),
  );

  // In OrderConfirmationScreen - FIXED Payment Button

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Refresh Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isRefreshing ? null : _manualRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isRefreshing
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 20),
                SizedBox(width: 8),
                Text(
                  'Check Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Payment Button - COMPLETELY FIXED
        // Payment Button - FIXED
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _canProceedToPayment ? Colors.orange : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _canProceedToPayment ? _proceedToPayment : null,
            child: Text(
              _canProceedToPayment ? 'Proceed to Payment' : 'Awaiting Acceptance',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Back to Home Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Color(0xFF2E7D32)),
            ),
            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => true),
            child: const Text(
              'Back to Home',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
            ),
          ),
        ),
      ],
    );
  }

// ✅ NEW METHOD: Extract payment data properly
  // ✅ UPDATED METHOD: Include all required payment data
  // ✅ ULTRA-SIMPLE METHOD: Just navigate to payment
  // ===== STEP 1: Update OrderConfirmationScreen._proceedToPayment =====

  void _proceedToPayment() {
    if (_orderDetails == null) {
      _showError('Order details not available');
      return;
    }

    print('');
    print('💰 ===== PAYMENT PROCEDURE STARTED =====');

    // Extract agent ID with detailed logging
    String agentId = _extractAgentIdWithDebug();

    print('');
    print('📊 FINAL PAYMENT DATA:');
    print('   ├─ Order ID: "${_orderDetails!.id}"');
    print('   ├─ Amount: ${_orderDetails!.price}');
    print('   ├─ Agent ID: "$agentId"');
    print('   ├─ Order Status: ${_orderDetails!.status}');
    print('   ├─ Order ID Length: ${_orderDetails!.id.length}');
    print('   ├─ Agent ID Length: ${agentId.length}');
    print('   └─ Amount > 0: ${_orderDetails!.price > 0}');
    print('');

    // Validate all fields
    final validationErrors = <String>[];

    if (_orderDetails!.id.isEmpty) {
      validationErrors.add('Order ID is empty');
    }
    if (_orderDetails!.id.startsWith('temp_')) {
      validationErrors.add('Order ID is temporary');
    }
    if (_orderDetails!.id.length != 24) {
      validationErrors.add('Order ID length is ${_orderDetails!.id.length}, expected 24');
    }
    if (agentId.isEmpty) {
      validationErrors.add('Agent ID is empty');
    }
    if (agentId.length != 24) {
      validationErrors.add('Agent ID length is ${agentId.length}, expected 24');
    }
    if (_orderDetails!.price <= 0) {
      validationErrors.add('Amount is ${_orderDetails!.price}');
    }

    if (validationErrors.isNotEmpty) {
      print('❌ VALIDATION ERRORS:');
      for (var error in validationErrors) {
        print('   ✗ $error');
      }
      print('');
      _showError('Payment validation failed: ${validationErrors.first}');
      return;
    }

    print('✅ ALL VALIDATIONS PASSED');
    print('🚀 Navigating to PaymentScreen...');
    print('========================================');
    print('');

    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            orderId: _orderDetails!.id,
            amount: _orderDetails!.price,
            agentId: agentId,
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('❌ NAVIGATION ERROR: $e');
      print('Stack trace: $stackTrace');
      _showError('Navigation failed: $e');
    }
  }

// Enhanced agent ID extraction with debug
  String _extractAgentIdWithDebug() {
    print('');
    print('🔍 EXTRACTING AGENT ID:');
    print('   📦 widget.orderData keys: ${widget.orderData.keys.toList()}');

    // Check all possible sources
    if (widget.orderData['agentId'] != null) {
      final id = widget.orderData['agentId'].toString();
      print('   ✓ Found in orderData["agentId"]: "$id"');
      return id;
    }
    print('   ✗ orderData["agentId"] is null');

    if (widget.orderData['selectedAgentId'] != null) {
      final id = widget.orderData['selectedAgentId'].toString();
      print('   ✓ Found in orderData["selectedAgentId"]: "$id"');
      return id;
    }
    print('   ✗ orderData["selectedAgentId"] is null');

    if (_orderDetails!.agent != null) {
      print('   📋 Checking _orderDetails.agent...');
      try {
        final agentMap = _orderDetails!.agent as Map<String, dynamic>;
        print('   Agent map keys: ${agentMap.keys.toList()}');

        if (agentMap['_id'] != null) {
          final id = agentMap['_id'].toString();
          print('   ✓ Found in agent["_id"]: "$id"');
          return id;
        }
        if (agentMap['id'] != null) {
          final id = agentMap['id'].toString();
          print('   ✓ Found in agent["id"]: "$id"');
          return id;
        }
        print('   ✗ No _id or id in agent map');
      } catch (e) {
        print('   ✗ Error reading agent map: $e');
      }
    } else {
      print('   ✗ _orderDetails.agent is null');
    }

    if (_orderDetails!.assignedAgent != null && _orderDetails!.assignedAgent!.isNotEmpty) {
      final id = _orderDetails!.assignedAgent!;
      print('   ✓ Found in assignedAgent: "$id"');
      return id;
    }
    print('   ✗ assignedAgent is null or empty');

    print('   ❌ AGENT ID NOT FOUND ANYWHERE!');
    return '';
  }


// Helper method to extract agent ID
  String _extractAgentId() {
    // Try orderData first (most reliable)
    if (widget.orderData['agentId'] != null) {
      return widget.orderData['agentId'].toString();
    }
    // Try selectedAgentId
    else if (widget.orderData['selectedAgentId'] != null) {
      return widget.orderData['selectedAgentId'].toString();
    }
    // Try from order details agent map
    else if (_orderDetails!.agent != null) {
      final agentMap = _orderDetails!.agent as Map<String, dynamic>;
      return agentMap['_id']?.toString() ?? agentMap['id']?.toString() ?? '';
    }
    // Try assignedAgent field
    else if (_orderDetails!.assignedAgent != null && _orderDetails!.assignedAgent!.isNotEmpty) {
      return _orderDetails!.assignedAgent!;
    }

    return '';
  }

// Helper method to show errors
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getServiceType(String category) {
    switch (category) {
      case 'errand': return 'Errand Service';
      case 'delivery': return 'Delivery/Pickup';
      case 'movers': return 'Movers Service';
      case 'grocery': return 'Grocery Shopping';
      default: return category;
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _formatTime(DateTime date) => '${date.hour}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
}