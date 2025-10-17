import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/errand_services/movers_screen.dart';
import '../agents_screen/available_agent_screen.dart';
import 'delivery_screen.dart';

const kGreen = Color(0xFF2E7D32);
const kFieldRadius = 6.0;

InputDecoration _greenFieldDecoration(String hint) => InputDecoration(
  hintText: hint,
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(kFieldRadius),
    borderSide: const BorderSide(color: kGreen, width: 1),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(kFieldRadius),
    borderSide: const BorderSide(color: kGreen, width: 1.5),
  ),
);

// ───────────────────────── Connect from HomeScreen ─────────────────────────
class ErrandServiceMenu extends StatelessWidget {
  const ErrandServiceMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final options = const [
      'Grocery/Item shopping',
      'Delivery/Pickup',
      'Movers service',
    ];

    return Scaffold(
      appBar: _whiteAppBar(title: 'Errand Service'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListTile(
              title: Text(options[i]),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if (i == 0) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const GroceryOrderScreen()));
                } else if (i == 1) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const DeliveryPickupScreen()));
                } else {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MoversApp()));
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// ───────────────────────── Screen 1: Grocery/Item Shopping ─────────────────────────
// Updated GroceryOrderScreen with proper state management
class GroceryOrderScreen extends StatefulWidget {
  const GroceryOrderScreen({super.key});

  @override
  State<GroceryOrderScreen> createState() => _GroceryOrderScreenState();
}

class _GroceryOrderScreenState extends State<GroceryOrderScreen> {
  final TextEditingController _itemsController = TextEditingController();
  final TextEditingController _dropOffController = TextEditingController();
  final TextEditingController _receiverNameController = TextEditingController();
  final TextEditingController _receiverPhoneController = TextEditingController();

  double _itemTotal = 75000.00;
  double _deliveryFee = 3000.00;

  @override
  void dispose() {
    _itemsController.dispose();
    _dropOffController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _itemTotal + _deliveryFee;

    return Scaffold(
      appBar: _whiteAppBar(title: 'Grocery/Item Shopping'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: _greenFieldDecoration('Store name (Optional)')
                  .copyWith(helperText: 'Optional', helperStyle: const TextStyle(height: 0.8)),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _itemsController,
              maxLines: 5,
              decoration: _greenFieldDecoration('Items Lists').copyWith(
                hintText: 'Eg. Drinks 12 packets\nApple 4\nRice 2kg',
              ),
              onChanged: (value) {
                // You could add logic to calculate item total based on items
              },
            ),
            const SizedBox(height: 20),

            // Receiver Info header bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: kGreen,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Receiver Info:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _dropOffController,
              decoration: _greenFieldDecoration('Drop off address'),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _receiverNameController,
              decoration: _greenFieldDecoration("Receiver's name"),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _receiverPhoneController,
              keyboardType: TextInputType.phone,
              decoration: _greenFieldDecoration("Receiver's phone number"),
            ),
            const SizedBox(height: 18),

            _amountRow('Item Total', '₦${_itemTotal.toStringAsFixed(2)}'),
            _amountRow('Delivery Fee', '₦${_deliveryFee.toStringAsFixed(2)}'),
            const SizedBox(height: 6),
            const DashedDivider(),
            const SizedBox(height: 6),
            _amountRow('Total', '₦${totalAmount.toStringAsFixed(2)}', bold: true),
            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 140,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _validateAndProceed,
                  child: const Text('Checkout'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validateAndProceed() {
    if (_itemsController.text.isEmpty) {
      _showError('Please enter the items you want to purchase');
      return;
    }

    if (_dropOffController.text.isEmpty) {
      _showError('Please enter the drop-off address');
      return;
    }

    if (_receiverNameController.text.isEmpty) {
      _showError('Please enter receiver\'s name');
      return;
    }

    if (_receiverPhoneController.text.isEmpty) {
      _showError('Please enter receiver\'s phone number');
      return;
    }

    final totalAmount = _itemTotal + _deliveryFee;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          orderData: {
            'serviceType': 'grocery',
            'items': _itemsController.text,
            'itemTotal': _itemTotal,
            'deliveryFee': _deliveryFee,
            'totalAmount': totalAmount,
            'dropOffAddress': _dropOffController.text,
            'receiverName': _receiverNameController.text,
            'receiverPhone': _receiverPhoneController.text,
          },
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _amountRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700])),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
// ───────────────────────── Screen 2: Checkout ─────────────────────────
// Updated CheckoutScreen that receives order data
class CheckoutScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const CheckoutScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final totalAmount = orderData['totalAmount'] ?? 0.0;
    final items = orderData['items'] ?? '';
    final dropOffAddress = orderData['dropOffAddress'] ?? '';
    final receiverName = orderData['receiverName'] ?? '';

    return Scaffold(
      appBar: _whiteAppBar(title: 'Checkout'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Address Details'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shopping Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.shopping_cart, color: kGreen),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Shopping from\nVarious stores as specified',
                          style: TextStyle(height: 1.25),
                        ),
                      ),
                    ],
                  ),

                  // Dotted Line
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                    child: SizedBox(
                      height: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          10,
                              (index) => Container(
                            width: 2,
                            height: 3,
                            decoration: BoxDecoration(color: kGreen),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Delivery Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.place_outlined, color: kGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery to\n$dropOffAddress',
                              style: const TextStyle(height: 1.25),
                            ),
                            if (receiverName.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Receiver: $receiverName',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: kGreen,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text('30 minutes away',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const _SectionTitle('Order Summary'),
            const SizedBox(height: 8),

            // Order Summary box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items.isEmpty
                        ? 'No items specified'
                        : items.replaceAll('\n', '\n• '),
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const DashedDivider(),
                  const SizedBox(height: 10),
                  _amountRow('Items Total', '₦${(orderData['itemTotal'] ?? 0).toStringAsFixed(2)}'),
                  _amountRow('Delivery Fee', '₦${(orderData['deliveryFee'] ?? 0).toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  const DashedDivider(),
                  const SizedBox(height: 6),
                  _amountRow('Total', '₦${totalAmount.toStringAsFixed(2)}', bold: true),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total (incl. delivery)',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black54,
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
                  elevation: 0,
                ),
                onPressed: () => _handleContinue(context),
                child: const Text(
                  'Continue to Agent Selection',
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
      ),
    );
  }

  void _handleContinue(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgentSelectionScreen(
          serviceType: 'grocery',
          orderData: orderData,
          orderAmount: orderData['totalAmount'] ?? 0.0,
        ),
      ),
    );
  }

  Widget _amountRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700])),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
// ───────────────────────── New: Agent Selection Screen ─────────────────────────

// ───────────────────────── Shared widgets ─────────────────────────
PreferredSizeWidget _whiteAppBar({required String title}) => AppBar(
  elevation: 0,
  backgroundColor: Colors.white,
  centerTitle: true,
  leading: const BackButton(color: Colors.black),
  title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
);

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16));
  }
}

// Simple dashed divider to match your mock
class DashedDivider extends StatelessWidget {
  final double dashWidth;
  final double dashSpace;
  final double thickness;
  final Color color;
  const DashedDivider({
    super.key,
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.thickness = 1,
    this.color = const Color(0xFFB0B8C1),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
                (_) => SizedBox(
              width: dashWidth,
              height: thickness,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            ),
          ),
        );
      },
    );
  }
}