import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/errand_services/movers_screen.dart';

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
// In your Grid item onTap:
// if (item.title == 'Errand service') {
//   Navigator.push(context,
//     MaterialPageRoute(builder: (_) => const ErrandServiceMenu()));
// }

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
class GroceryOrderScreen extends StatelessWidget {
  const GroceryOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _whiteAppBar(title: 'Grocery/Item Shopping'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(decoration: _greenFieldDecoration('Optional').copyWith(helperText: 'Optional', helperStyle: const TextStyle(height: 0.8))),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: _greenFieldDecoration('Items Lists').copyWith(
                hintText: 'Eg. Drinks 12 packets\nApple 4',
              ),
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

            TextField(decoration: _greenFieldDecoration('Drop off')),
            const SizedBox(height: 10),
            TextField(decoration: _greenFieldDecoration("Receiver's name")),
            const SizedBox(height: 10),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: _greenFieldDecoration("Receiver's number"),
            ),
            const SizedBox(height: 18),

            _amountRow('Item Total', '₦75,000.00'),
            _amountRow('Delivery', '₦3,000.00'),
            const SizedBox(height: 6),
            const DashedDivider(),
            const SizedBox(height: 6),
            _amountRow('Total', '₦78,000.00', bold: true),
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
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
                  },
                  child: const Text('Checkout'),
                ),
              ),
            ),
          ],
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

// ───────────────────────── Screen 2: Checkout ─────────────────────────
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  // First Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.place_outlined, color: kGreen),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Shopping from\nPlaza 3, Tejuosho market, Yaba',
                          style: TextStyle(height: 1.25),
                        ),
                      ),
                    ],
                  ),

// 🔥 Dotted Line between the icons
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
                    child: SizedBox(
                      height: 50, // total height of dotted line
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          10, // number of dots
                              (index) => Container(
                            width: 2,      // thickness
                            height: 3,     // dot height
                            decoration: BoxDecoration(
                              color: kGreen, // makes it rounded like dots
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),


                  // Second Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.place_outlined, color: kGreen),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Delivery to\nNew Hall, UNILAG, Lagos',
                          style: TextStyle(height: 1.25),
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

            // 🔥 Bigger and bolder Order Summary box
            Container(
              width: double.infinity,
              height: 180, // makes it taller
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const SingleChildScrollView(
                child: Text(
                  'Rice - Tray\nGolden morn - 6 rolls\nDetols - 2 packs\nAmstel malta - 12 packs\nParty Packs - 50 items\nSupermarket cream - 2 bowls',
                  style: TextStyle(
                    fontWeight: FontWeight.w400, // bolder text
                    fontSize: 15, // slightly larger
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),

      // 🔥 Total + Continue button pinned at bottom
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
            // Total Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Total (incl. delivery)',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  '₦78,000.00',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: kGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Continue Button
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
                onPressed: () {
                },
                child: const Text(
                  'Continue',
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
}


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
