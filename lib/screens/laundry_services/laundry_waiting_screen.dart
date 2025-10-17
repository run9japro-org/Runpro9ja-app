// screens/laundry_order_waiting_screen.dart
import 'package:flutter/material.dart';
import '../../auth/Auth_services/auth_service.dart';
import '../../models/agent_model.dart';
import '../../models/customer_models.dart';
import '../../services/customer_services.dart';
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
      if (mounted && !_orderAccepted) {
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
        });

        // If order is accepted, stop polling and proceed to payment
        if (_orderAccepted) {
          _navigateToPayment();
        }
      }
    } catch (e) {
      print('❌ Error checking order status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
        });
      }
    }
  }

  void _navigateToPayment() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LaundryOrderSummaryScreen(
        orderData: widget.orderData,
        address: widget.orderData['address'] ?? '',
        phone: widget.orderData['phone'] ?? '',
        instructions: widget.orderData['instructions'] ?? '',
        serviceType: widget.orderData['serviceType'] ?? 'laundry',
        selectedAgent: widget.selectedAgent,
        customerOrder: _currentOrder!, // Use the updated order with accepted status
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting for Agent Acceptance'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated loading icon
            _isCheckingStatus
                ? const CircularProgressIndicator(color: Color(0xFF1B5E20))
                : const Icon(Icons.access_time, size: 80, color: Colors.orange),

            const SizedBox(height: 30),

            Text(
              _orderAccepted ? 'Order Accepted!' : 'Waiting for Agent',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              _orderAccepted
                  ? '${widget.selectedAgent.displayName} has accepted your laundry order!'
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
                          '₦${widget.orderData['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (!_orderAccepted) ...[
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
          ],
        ),
      ),
    );
  }
}