// screens/service_history_screen.dart - WITH CLICKABLE CARDS
import 'package:flutter/material.dart';
import '../../services/customer_services.dart';
import '../../services/order_recovery_service.dart';
import '../../services/pending_orders_service.dart';
import '../../models/customer_models.dart';
import 'errand_services/order_confirmation_screen.dart';

class ServiceHistoryScreen extends StatefulWidget {
  final CustomerService customerService;

  const ServiceHistoryScreen({
    super.key,
    required this.customerService,
  });

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  List<CustomerOrder> _orders = [];
  List<Map<String, dynamic>> _draftOrders = [];
  Map<String, dynamic>? _pendingOrder;
  bool _isLoading = true;
  bool _isCheckingPending = false;
  String _error = '';
  String _source = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadServiceHistory();
    await _loadDraftOrders();
    await _loadPendingOrder();
  }

  Future<void> _loadServiceHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
        _source = '';
      });

      print('🔄 Loading service history...');
      final orders = await widget.customerService.getCustomerServiceHistory();

      setState(() {
        _orders = orders;
        _isLoading = false;
        _source = 'API';
        print('✅ Service history loaded: ${orders.length} orders');
      });
    } catch (e) {
      print('❌ Error loading service history: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _source = 'Error';
      });
    }
  }

  Future<void> _loadDraftOrders() async {
    try {
      final drafts = await OrderRecoveryService.getDraftOrders();
      setState(() {
        _draftOrders = drafts;
      });
      print('📝 Loaded ${drafts.length} draft orders');
    } catch (e) {
      print('❌ Error loading draft orders: $e');
    }
  }

  Future<void> _loadPendingOrder() async {
    try {
      final pending = await PendingOrdersService.getWaitingForAgentOrder();
      setState(() {
        _pendingOrder = pending;
      });
      print('⏳ Loaded pending order: ${pending != null}');

      if (pending != null) {
        _checkPendingOrderStatus(pending['orderId'] as String);
      }
    } catch (e) {
      print('❌ Error loading pending order: $e');
    }
  }

  Future<void> _checkPendingOrderStatus(String orderId) async {
    try {
      setState(() {
        _isCheckingPending = true;
      });

      print('🔍 Checking pending order status: $orderId');

      final orders = await widget.customerService.getCustomerServiceHistory();
      final currentOrder = orders.firstWhere(
            (order) => order.id == orderId,
        orElse: () => throw Exception('Order not found'),
      );

      print('📊 Pending order status from API: ${currentOrder.status}');

      if (currentOrder.status == 'accepted' || currentOrder.status == 'confirmed') {
        await PendingOrdersService.updateOrderStatus(
          orderId: orderId,
          status: currentOrder.status,
          canPay: true,
        );

        await _loadPendingOrder();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Agent accepted your order! You can now pay.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (currentOrder.status == 'rejected' || currentOrder.status == 'cancelled') {
        await PendingOrdersService.clearWaitingForAgentOrder();
        await _loadPendingOrder();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Order was ${currentOrder.status}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

    } catch (e) {
      print('❌ Error checking pending order status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingPending = false;
        });
      }
    }
  }

  // In your ServiceHistoryScreen - UPDATE the _onServiceCardTap method
  void _onServiceCardTap(CustomerOrder order) {
    print('👆 Service card tapped: ${order.id}');
    print('📊 Order status: ${order.status}');
    print('💰 Order amount: ${order.price}');

    // **FIXED: Only navigate to OrderConfirmationScreen for pending/accepted orders**
    // Show modal for completed/cancelled orders
    if (_shouldNavigateToOrderConfirmation(order)) {
      _navigateToOrderConfirmation(order);
    } else {
      _showOrderDetails(order);
    }
  }

// **ADD THIS: Determine which orders should go to Order Confirmation**
  bool _shouldNavigateToOrderConfirmation(CustomerOrder order) {
    final status = order.status.toLowerCase();

    // Orders that should go to Order Confirmation screen
    final confirmationStatuses = [
      'pending',
      'requested',
      'waiting_for_agent',
      'agent_pending',
      'pending_agent_response',
      'accepted',
      'agent_accepted',
      'confirmed',
      'approved',
      'ready_for_payment',
      'payment_pending',
      'pending_payment'
    ];

    final shouldNavigate = confirmationStatuses.contains(status);
    print("🧭 Should navigate to OrderConfirmation: $shouldNavigate (status: $status)");

    return shouldNavigate;
  }

// **UPDATE: Show order details ONLY (no navigation to Order Confirmation)**
  void _showOrderDetails(CustomerOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: order.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          order.statusIcon,
                          color: order.statusColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.statusText,
                          style: TextStyle(
                            color: order.statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Information
                    _buildDetailSection('Service Information', [
                      _buildDetailRow('Service Type', order.serviceCategory),
                      _buildDetailRow('Description', order.description),
                      _buildDetailRow('Location', order.location),
                      _buildDetailRow('Price', order.formattedPrice),
                      _buildDetailRow('Status', order.statusText, valueColor: order.statusColor),
                    ]),

                    const SizedBox(height: 20),

                    // Timing Information
                    _buildDetailSection('Timing', [
                      _buildDetailRow('Created', order.timeAgo),
                      if (order.createdAt != null)
                        _buildDetailRow('Date',
                            '${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}'),
                    ]),

                    // Status-specific message
                    if (_isCompletedOrder(order)) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Order Completed',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_isCancelledOrder(order)) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.cancel, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Order Cancelled',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // Single Close Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// **ADD THESE: Helper methods for order status**
  bool _isCompletedOrder(CustomerOrder order) {
    final status = order.status.toLowerCase();
    final completedStatuses = ['completed', 'finished', 'delivered', 'done', 'paid'];
    return completedStatuses.contains(status);
  }

  bool _isCancelledOrder(CustomerOrder order) {
    final status = order.status.toLowerCase();
    final cancelledStatuses = ['cancelled', 'rejected', 'declined', 'failed'];
    return cancelledStatuses.contains(status);
  }

  void _navigateToOrderConfirmation(CustomerOrder order) {
    print('🚀 Navigating to OrderConfirmationScreen for order: ${order.id}');

    // Create order data for the confirmation screen
    final orderData = {
      'orderId': order.id,
      '_id': order.id,
      'id': order.id,
      'serviceType': order.serviceCategory,
      'totalAmount': order.price,
      'status': order.status,
      'description': order.description,
      'location': order.location,
      'createdAt': order.createdAt?.toIso8601String(),
      // Include agent information if available
      if (order.agent != null) 'agent': order.agent,
      if (order.assignedAgent != null) 'assignedAgent': order.assignedAgent,
    };

    // Add debug information
    print('📦 Order data for navigation:');
    print('   - Order ID: ${order.id}');
    print('   - Status: ${order.status}');
    print('   - Amount: ${order.price}');
    print('   - Can proceed to payment: ${_canProceedToPayment(order)}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(
          orderData: orderData,
          serviceType: order.serviceCategory,
          orderId: order.id,
        ),
      ),
    );
  }

// **ADD THIS: Check if order can proceed to payment**
  bool _canProceedToPayment(CustomerOrder order) {
    final status = order.status.toLowerCase();
    print("🎯 Checking payment eligibility for order ${order.id}: $status");

    // Orders that can proceed to payment
    final acceptedStatuses = [
      'accepted',
      'agent_accepted',
      'confirmed',
      'approved',
      'ready_for_payment',
      'payment_pending',
      'pending_payment'
    ];

    final canPay = acceptedStatuses.contains(status);
    print("💰 Payment allowed: $canPay for status: $status");

    return canPay;
  }


// **UPDATE: Detail row with color option**
  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.grey[800],
                fontSize: 14,
                fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }



  void _deleteDraft(String draftId) async {
    await OrderRecoveryService.removeDraftOrder(draftId);
    await _loadDraftOrders();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft deleted')),
    );
  }

  void _continueDraft(Map<String, dynamic> draft) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Continue Draft?'),
        content: Text('Continue with ${draft['serviceType'] ?? 'this service'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToDraft(draft);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _handlePendingOrderAction() {
    if (_pendingOrder == null) return;

    final canPay = _pendingOrder!['canPay'] == true;

    if (canPay) {
      _proceedToPayment();
    } else {
      _checkPendingOrderStatus(_pendingOrder!['orderId'] as String);
    }
  }

  void _proceedToPayment() {
    if (_pendingOrder == null) return;

    final orderId = _pendingOrder!['orderId'] as String;
    final amount = _pendingOrder!['amount'] as double;
    final serviceType = _pendingOrder!['serviceType'] as String;

    print('💰 Proceeding to payment for order: $orderId');

    _showPaymentDialog(orderId, amount, serviceType);
  }

  void _showPaymentDialog(String orderId, double amount, String serviceType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Proceed to Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: $serviceType'),
            Text('Amount: ₦${amount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text(
              'You will be redirected to the payment page to complete your order.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showTemporaryMessage('Redirecting to payment...');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  void _cancelPendingOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text('This will cancel your pending order. The agent may have already started working on it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Waiting'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmCancelPendingOrder();
            },
            child: const Text('Cancel Order', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmCancelPendingOrder() async {
    try {
      if (_pendingOrder != null) {
        final orderId = _pendingOrder!['orderId'] as String;

        await PendingOrdersService.clearWaitingForAgentOrder();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order cancelled')),
          );
          await _loadPendingOrder();
        }
      }
    } catch (e) {
      print('❌ Error cancelling pending order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToDraft(Map<String, dynamic> draft) {
    print('🚀 Navigating to continue draft: ${draft['serviceType']}');
    _showTemporaryMessage('Draft continuation feature coming soon!');
  }

  void _showTemporaryMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Service History",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_source.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: Text(
                  _source == 'API' ? 'Live Data' : 'Sample Data',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: _source == 'API' ? Colors.green.shade100 : Colors.orange.shade100,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _initializeData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Loading your service history...',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_error.isNotEmpty && _orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: Colors.grey[400], size: 64),
              const SizedBox(height: 16),
              const Text(
                'Connection Issue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Using sample data for demonstration',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initializeData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_pendingOrder != null) _buildPendingOrderSection(),
        if (_draftOrders.isNotEmpty) _buildDraftsSection(),
        if (_source == 'Sample Data')
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Showing sample data. Backend integration in progress.',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _initializeData,
            color: Colors.green,
            child: _orders.isEmpty && _draftOrders.isEmpty && _pendingOrder == null
                ? _buildEmptyState()
                : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_orders.isNotEmpty) ...[
                  Text(
                    "Your Service History (${_orders.length})",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._orders.map((order) => _buildServiceCard(order)).toList(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // **UPDATE: Service card to show navigation hint for pending orders**
  Widget _buildServiceCard(CustomerOrder order) {
    final shouldNavigate = _shouldNavigateToOrderConfirmation(order);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => _onServiceCardTap(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.serviceCategory,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          order.statusIcon,
                          color: order.statusColor,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.statusText,
                          style: TextStyle(
                            color: order.statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    order.location,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.formattedPrice,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        order.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (shouldNavigate) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Complete Order',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... Keep all your existing methods for pending orders, drafts, etc.
  // _buildPendingOrderSection, _buildDraftsSection, _buildDraftCard,
  // _getTimeAgo, _buildEmptyState, and all helper methods remain the same
  Widget _buildPendingOrderSection() {
    final order = _pendingOrder!;
    final canPay = order['canPay'] == true;
    final status = order['status'] as String;
    final agentName = order['agentName'] as String;
    final serviceType = order['serviceType'] as String;
    final amount = order['amount'] as double;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.orange.shade50,
          child: Row(
            children: [
              Icon(Icons.access_time, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Pending Order',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (_isCheckingPending)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.orange.shade700,
                  ),
                ),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        serviceType.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getPendingStatusColor(status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getPendingStatusText(status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Agent: $agentName',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '₦${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getPendingStatusIcon(status),
                        color: _getPendingStatusColor(status),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getPendingStatusMessage(status),
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancelPendingOrder,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel Order'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isCheckingPending ? null : _handlePendingOrderAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canPay ? Colors.green : Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isCheckingPending
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : Text(canPay ? 'Pay Now' : 'Check Status'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ... Keep all your existing helper methods exactly as they were
  Color _getPendingStatusColor(String status) {
    switch (status) {
      case 'waiting_for_agent':
        return Colors.orange;
      case 'accepted':
      case 'confirmed':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPendingStatusText(String status) {
    switch (status) {
      case 'waiting_for_agent':
        return 'Waiting for Agent';
      case 'accepted':
        return 'Accepted';
      case 'confirmed':
        return 'Confirmed';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  IconData _getPendingStatusIcon(String status) {
    switch (status) {
      case 'waiting_for_agent':
        return Icons.access_time;
      case 'accepted':
      case 'confirmed':
        return Icons.check_circle;
      case 'rejected':
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getPendingStatusMessage(String status) {
    switch (status) {
      case 'waiting_for_agent':
        return 'Waiting for agent to accept your order. You can check status or cancel.';
      case 'accepted':
      case 'confirmed':
        return 'Agent accepted your order! You can now proceed to payment.';
      case 'rejected':
        return 'Agent rejected your order. You can create a new one.';
      case 'cancelled':
        return 'Order was cancelled.';
      default:
        return 'Order status: $status';
    }
  }

  Widget _buildDraftsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              Icon(Icons.drafts, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Draft Orders (${_draftOrders.length})',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        ..._draftOrders.map((draft) => _buildDraftCard(draft)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDraftCard(Map<String, dynamic> draft) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.grey.shade100,
      child: ListTile(
        leading: const Icon(Icons.drafts, color: Colors.grey),
        title: Text(draft['serviceType']?.toString() ?? 'Draft Order'),
        subtitle: Text(
            '₦${(draft['totalAmount'] ?? draft['orderAmount'] ?? 0.0).toStringAsFixed(2)} • '
                'Saved ${_getTimeAgo(draft['savedAt'])}'
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.green),
              onPressed: () => _continueDraft(draft),
              tooltip: 'Continue',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteDraft(draft['id'] as String),
              tooltip: 'Delete',
            ),
          ],
        ),
        onTap: () => _continueDraft(draft),
      ),
    );
  }

  String _getTimeAgo(String? savedAt) {
    if (savedAt == null) return 'recently';

    final savedTime = DateTime.parse(savedAt);
    final now = DateTime.now();
    final difference = now.difference(savedTime);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            color: Colors.grey[400],
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Service History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your completed services will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}