import 'dart:async';
import 'package:flutter/material.dart';
import 'package:runpro_9ja/auth/Auth_services/auth_service.dart';

import '../../models/customer_models.dart';
import '../../services/customer_services.dart';
import '../payment_screens/payment_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final String serviceType;

  const OrderConfirmationScreen({
    super.key,
    required this.orderData,
    required this.serviceType,
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  final CustomerService _customerService = CustomerService(AuthService());
  bool _isLoading = true;
  CustomerOrder? _orderDetails;
  Timer? _refreshTimer;

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

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_orderDetails == null) return;

      try {
        final updatedOrder = await _customerService.getOrderById(_orderDetails!.id);

        if (mounted) {
          setState(() {
            _orderDetails = updatedOrder;
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

  bool _shouldStopRefresh(String status) {
    final stoppedStatuses = ['paid', 'completed', 'cancelled', 'rejected', 'failed'];
    return stoppedStatuses.contains(status.toLowerCase());
  }

  Future<void> _loadOrderDetails() async {
    try {
      final orderId = widget.orderData['_id'] ?? widget.orderData['id'];
      if (orderId != null) {
        final order = await _customerService.getOrderById(orderId.toString());
        setState(() {
          _orderDetails = order;
        });
      } else {
        setState(() {
          _orderDetails = _createOrderFromData(widget.orderData);
        });
      }
    } catch (e) {
      print("❌ Error loading order details: $e");
      setState(() {
        _orderDetails = _createOrderFromData(widget.orderData);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Color(0xFF2E7D32), size: 40),
          ),
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
          const Text('Order Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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

          // Debug information
          const SizedBox(height: 16),
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
                Text('Raw Status: "${order.status}"', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                Text('Can Pay: $_canProceedToPayment', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
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
        ],
      ),
    );
  }

  Widget _buildStep(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [const Icon(Icons.check_circle, color: Colors.blue, size: 16), const SizedBox(width: 8), Expanded(child: Text(text))]),
  );

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _canProceedToPayment ? Colors.orange : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _canProceedToPayment ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentScreen(
                    orderId: _orderDetails!.id,
                    amount: _orderDetails!.price,
                    agentId: _orderDetails!.assignedAgent ?? '',
                  ),
                ),
              );
            } : null,
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
}