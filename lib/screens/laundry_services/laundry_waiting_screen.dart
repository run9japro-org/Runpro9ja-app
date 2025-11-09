// screens/laundry_order_waiting_screen.dart
import 'package:flutter/material.dart';
import '../../auth/Auth_services/auth_service.dart';
import '../../models/agent_model.dart';
import '../../models/customer_models.dart';
import '../../services/customer_services.dart';
import '../payment_screens/payment_screen.dart';
import 'laundry_services.dart';

class LaundryOrderWaitingScreen extends StatefulWidget {
  final String orderId;
  final Agent selectedAgent;
  final Map<String, dynamic> orderData;
  final CustomerOrder customerOrder;

  const LaundryOrderWaitingScreen({
    super.key,
    required this.orderId,
    required this.selectedAgent,
    required this.orderData,
    required this.customerOrder,
  });

  @override
  State<LaundryOrderWaitingScreen> createState() => _LaundryOrderWaitingScreenState();
}

class _LaundryOrderWaitingScreenState extends State<LaundryOrderWaitingScreen> {
  final CustomerService _customerService = CustomerService(AuthService());
  bool _isCheckingStatus = false;
  bool _orderAccepted = false;
  bool _orderDeclined = false;
  CustomerOrder? _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.customerOrder;
    // Start checking order status
    _checkOrderStatus();
    // Set up periodic status checking
    _startStatusPolling();
  }

  void _startStatusPolling() {
    // Check status every 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && !_orderAccepted && !_orderDeclined) {
        _checkOrderStatus();
        _startStatusPolling(); // Continue polling
      }
    });
  }

  Future<void> _checkOrderStatus() async {
    if (_isCheckingStatus) return;

    setState(() {
      _isCheckingStatus = true;
    });

    try {
      final order = await _customerService.getOrderById(widget.orderId);

      if (order != null) {
        setState(() {
          _currentOrder = order;
          _orderAccepted = order.status == 'accepted';
          _orderDeclined = order.status == 'declined' || order.status == 'cancelled';
        });

        // If order is accepted, stop polling and proceed to payment
        if (_orderAccepted) {
          _navigateToPayment();
        }

        // If order is declined, show appropriate message
        if (_orderDeclined) {
          _showOrderDeclinedMessage();
        }
      }
    } catch (e) {
      print('❌ Error checking order status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
        });
      }
    }
  }

  void _showOrderDeclinedMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agent declined your order. Please try another agent.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  void _navigateToPayment() {
    if (!mounted) return;

    // Ensure numeric values are properly handled
    final safeOrderData = Map<String, dynamic>.from(widget.orderData);

    // Convert totalAmount to double if it exists
    if (safeOrderData['totalAmount'] != null) {
      if (safeOrderData['totalAmount'] is int) {
        safeOrderData['totalAmount'] = safeOrderData['totalAmount'].toDouble();
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LaundryOrderSummaryScreen(
        orderData: safeOrderData,
        address: widget.orderData['address'] ?? '',
        phone: widget.orderData['phone'] ?? '',
        instructions: widget.orderData['instructions'] ?? '',
        serviceType: widget.orderData['serviceType'] ?? 'laundry',
        selectedAgent: widget.selectedAgent,
        customerOrder: _currentOrder!,
      )),
    );
  }

  void _navigateBackToServices() {
    if (!mounted) return;

    // Navigate back to services screen or home
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  // Helper method to get the display price
  double get _displayPrice {
    // Use the current order price if available and valid
    if (_currentOrder != null && _currentOrder!.price > 0) {
      return _currentOrder!.price;
    }
    // Fall back to the original order data from widget (safely converted)
    final orderAmount = widget.orderData['totalAmount'];
    if (orderAmount is int) {
      return orderAmount.toDouble();
    } else if (orderAmount is double) {
      return orderAmount;
    } else if (orderAmount is String) {
      return double.tryParse(orderAmount) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting for Agent Acceptance'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _orderDeclined ? _navigateBackToServices : null,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated loading icon
            if (_isCheckingStatus)
              const CircularProgressIndicator(color: Color(0xFF1B5E20))
            else if (_orderAccepted)
              const Icon(Icons.check_circle, size: 80, color: Colors.green)
            else if (_orderDeclined)
                const Icon(Icons.cancel, size: 80, color: Colors.red)
              else
                const Icon(Icons.access_time, size: 80, color: Colors.orange),

            const SizedBox(height: 30),

            Text(
              _orderAccepted
                  ? 'Order Accepted!'
                  : _orderDeclined
                  ? 'Order Declined'
                  : 'Waiting for Agent',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              _orderAccepted
                  ? '${widget.selectedAgent.displayName} has accepted your laundry order!'
                  : _orderDeclined
                  ? '${widget.selectedAgent.displayName} is unavailable. Please try another agent.'
                  : 'We\'ve sent your laundry order to ${widget.selectedAgent.displayName}. '
                  'They usually respond within a few minutes.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // Order Details Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: widget.selectedAgent.profileImage.isNotEmpty
                            ? NetworkImage('https://runpro9ja-backend.onrender.com${widget.selectedAgent.profileImage}')
                            : null,
                        child: widget.selectedAgent.profileImage.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(widget.selectedAgent.displayName),
                      subtitle: Text('Rating: ${widget.selectedAgent.rating} • ${widget.selectedAgent.completedJobs} jobs'),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Order Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '₦${_displayPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (!_orderAccepted && !_orderDeclined) ...[
              const Text(
                'Checking status...',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _checkOrderStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                ),
                child: const Text('Check Now', style: TextStyle(color: Colors.white)),
              ),
            ],

            if (_orderAccepted) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Proceed to Payment',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],

            if (_orderDeclined) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateBackToServices,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Find Another Agent',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


class LaundryOrderSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final String address;
  final String phone;
  final String instructions;
  final String serviceType;
  final Agent selectedAgent;
  final CustomerOrder customerOrder;

  const LaundryOrderSummaryScreen({
    super.key,
    required this.orderData,
    required this.address,
    required this.phone,
    required this.instructions,
    required this.serviceType,
    required this.selectedAgent,
    required this.customerOrder,
  });

  @override
  State<LaundryOrderSummaryScreen> createState() => _LaundryOrderSummaryScreenState();
}

class _LaundryOrderSummaryScreenState extends State<LaundryOrderSummaryScreen> {
  // SAFE getter for total amount that handles all types without casting
  double get totalAmount {
    // First priority: Use the customer order price
    if (widget.customerOrder.price > 0) {
      return widget.customerOrder.price;
    }

    // Second priority: Safely extract from orderData
    final dynamic amount = widget.orderData['totalAmount'];

    if (amount == null) return 0.0;

    // Handle all possible types safely
    if (amount is double) {
      return amount;
    } else if (amount is int) {
      return amount.toDouble(); // Convert int to double
    } else if (amount is String) {
      return double.tryParse(amount) ?? 0.0;
    }

    return 0.0;
  }

  // SAFE getter for order data without direct casting
  String get _safeAddress {
    final address = widget.orderData['address'];
    if (address is String) return address;
    return widget.address;
  }

  String get _safePhone {
    final phone = widget.orderData['phone'];
    if (phone is String) return phone;
    return widget.phone;
  }

  String get _safeInstructions {
    final instructions = widget.orderData['instructions'];
    if (instructions is String) return instructions;
    return widget.instructions;
  }

  String get _safeServiceType {
    final serviceType = widget.orderData['serviceType'];
    if (serviceType is String) return serviceType;
    return widget.serviceType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Agent Info Card
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: widget.selectedAgent.profileImage.isNotEmpty
                          ? NetworkImage('https://runpro9ja-backend.onrender.com${widget.selectedAgent.profileImage}')
                          : null,
                      child: widget.selectedAgent.profileImage.isEmpty
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.selectedAgent.displayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rating: ${widget.selectedAgent.rating}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '${widget.selectedAgent.completedJobs} completed jobs',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Order Details Card
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildDetailRow('Service Type', _safeServiceType),
                    _buildDetailRow('Address', _safeAddress),
                    _buildDetailRow('Phone', _safePhone),

                    if (_safeInstructions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow('Special Instructions', _safeInstructions),
                    ],

                    const Divider(height: 30),

                    // Total Amount - USING THE SAFE GETTER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₦${totalAmount.toStringAsFixed(2)}', // SAFE usage
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Proceed to Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Cancel Order',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment() {
    // Show payment confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agent: ${widget.selectedAgent.displayName}'),
            Text('Service: ${_safeServiceType}'),
            const SizedBox(height: 10),
            Text(
              'Amount: ₦${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Do you want to proceed with payment?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _navigateToPaymentScreen(); // Navigate to actual payment screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
            ),
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  void _navigateToPaymentScreen() {
    try {
      print('🚀 Navigating to PaymentScreen...');
      print('📦 Order ID: ${widget.customerOrder.id}');
      print('💰 Amount: $totalAmount');
      print('👤 Agent ID: ${widget.selectedAgent.id}');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            orderId: widget.customerOrder.id,
            amount: totalAmount,
            agentId: widget.selectedAgent.id,
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('❌ Error navigating to payment screen: $e');
      print('📋 Stack trace: $stackTrace');

      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Payment Successful'),
          ],
        ),
        content: const Text('Your payment has been processed successfully. Your order is now confirmed.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }
}