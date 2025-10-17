// delivery_screen.dart - Updated to use CustomerService
import 'package:flutter/material.dart';
import 'package:runpro_9ja/auth/Auth_services/auth_service.dart';

import '../../services/customer_services.dart';
import '../../utils/service_mapper.dart';
import '../agents_screen/available_agent_screen.dart';
import 'order_confirmation_screen.dart';
import 'order_detail_bottom_sheet.dart';

class DeliveryPickupScreen extends StatefulWidget {
  const DeliveryPickupScreen({super.key});

  @override
  State<DeliveryPickupScreen> createState() => _DeliveryPickupScreenState();
}

class _DeliveryPickupScreenState extends State<DeliveryPickupScreen> {
  int selectedService = 1; // 0 Basic, 1 Standard, 2 Express
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController packageDescController = TextEditingController();

  late CustomerService _customerService;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _serviceLevels = [
    {
      'type': 'basic',
      'name': 'Basic',
      'price': 1500.00,
      'description': 'Bulk delivery. Get items in the next 2 days',
      'deliveryTime': '2 days'
    },
    {
      'type': 'standard',
      'name': 'Standard',
      'price': 3000.00,
      'description': 'Get your package within 24 hours',
      'deliveryTime': '24 hours'
    },
    {
      'type': 'express',
      'name': 'Express',
      'price': 5000.00,
      'description': 'Delivery in less than 2 hours',
      'deliveryTime': '2 hours'
    },
  ];

  @override
  void initState() {
    super.initState();
    _customerService = CustomerService(AuthService());
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    packageDescController.dispose();
    super.dispose();
  }

// In your DeliveryPickupScreen _confirmOrder method
  // In your DeliveryPickupScreen - update the _confirmOrder method
  // In DeliveryPickupScreen - ensure orderData has the right structure
  // In DeliveryPickupScreen - Update the orderData to include all required fields
  void _confirmOrder() async {
    if (fromController.text.isEmpty || toController.text.isEmpty) {
      _showError('Please enter both pickup and delivery addresses');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final selectedLevel = _serviceLevels[selectedService];
      final totalAmount = selectedLevel['price'];

      // Navigate to agent selection with proper order data
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AgentSelectionScreen(
              serviceType: 'delivery', // Make sure this is 'delivery'
              orderData: {
                'serviceType': 'delivery',
                'fromAddress': fromController.text,
                'toAddress': toController.text,
                'serviceLevel': selectedLevel['type'],
                'totalAmount': totalAmount,
                'packageDescription': packageDescController.text,
                // Add estimated delivery time based on service level
                'estimatedDeliveryTime': _getEstimatedDeliveryTime(selectedLevel['type']),
              },
              orderAmount: totalAmount,
            ),
          ),
        );
      }

    } catch (e) {
      print('❌ Error in delivery confirmation: $e');
      if (mounted) {
        _showError('Failed to proceed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

// Helper method to get estimated delivery time
  String _getEstimatedDeliveryTime(String serviceLevel) {
    switch (serviceLevel) {
      case 'basic':
        return '2 days';
      case 'standard':
        return '24 hours';
      case 'express':
        return '2 hours';
      default:
        return '24 hours';
    }
  }
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showOrderDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => OrderDetailsBottomSheet(
        fromAddress: fromController.text,
        toAddress: toController.text,
        serviceLevel: _serviceLevels[selectedService],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _whiteAppBar(title: 'Delivery/ Pickup'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Location Details'),
            const SizedBox(height: 16),

            // FROM field
            _AddressField(
              controller: fromController,
              label: 'Pickup Address',
              hint: 'Enter pickup location',
              icon: Icons.place_outlined,
            ),
            const SizedBox(height: 16),

            // TO field
            _AddressField(
              controller: toController,
              label: 'Delivery Address',
              hint: 'Enter delivery location',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),

            // Package Description
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Package Description (Optional)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: packageDescController,
                  maxLines: 2,
                  decoration: _greenFieldDecoration('Describe your package...'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Order Details Preview
            GestureDetector(
              onTap: _showOrderDetails,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, color: kGreen, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('View Order Summary')),
                    Icon(Icons.chevron_right, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const _SectionTitle('Select Service Level'),
            const SizedBox(height: 12),

            // Service Level Cards
            ..._serviceLevels.asMap().entries.map((entry) {
              final index = entry.key;
              final service = entry.value;
              return _ServiceLevelCard(
                title: service['name'],
                description: service['description'],
                price: service['price'],
                deliveryTime: service['deliveryTime'],
                selected: selectedService == index,
                onTap: () => setState(() => selectedService = index),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _BottomConfirmButton(
        isSubmitting: _isSubmitting,
        totalAmount: _serviceLevels[selectedService]['price'],
        onConfirm: _confirmOrder,
      ),
    );
  }
}

// Supporting Widgets
class _AddressField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  const _AddressField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: _greenFieldDecoration(hint).copyWith(
            prefixIcon: Icon(icon, color: kGreen),
          ),
        ),
      ],
    );
  }
}

class _ServiceLevelCard extends StatelessWidget {
  final String title;
  final String description;
  final double price;
  final String deliveryTime;
  final bool selected;
  final VoidCallback onTap;

  const _ServiceLevelCard({
    required this.title,
    required this.description,
    required this.price,
    required this.deliveryTime,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? kGreen : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? [
            BoxShadow(
              color: kGreen.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ] : [],
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? kGreen : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: selected ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: kGreen,
                  ),
                ),
              ) : null,
            ),
            const SizedBox(width: 12),

            // Service details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: selected ? kGreen : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: selected ? kGreen : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Estimated: $deliveryTime',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Price
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? kGreen : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '₦${price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomConfirmButton extends StatelessWidget {
  final bool isSubmitting;
  final double totalAmount;
  final VoidCallback onConfirm;

  const _BottomConfirmButton({
    required this.isSubmitting,
    required this.totalAmount,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                '₦${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: kGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isSubmitting ? null : onConfirm,
              child: isSubmitting
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text(
                'Confirm & Proceed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Constants (keep your existing ones)
const kGreen = Color(0xFF2E7D32);
const kFieldRadius = 8.0;

InputDecoration _greenFieldDecoration(String hint) => InputDecoration(
  hintText: hint,
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(kFieldRadius),
    borderSide: const BorderSide(color: Colors.grey, width: 1),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(kFieldRadius),
    borderSide: const BorderSide(color: kGreen, width: 1.5),
  ),
);

PreferredSizeWidget _whiteAppBar({required String title}) => AppBar(
  elevation: 0,
  backgroundColor: Colors.white,
  centerTitle: true,
  leading: const BackButton(color: Colors.black),
  title: Text(
    title,
    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
  ),
);

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
    );
  }
}