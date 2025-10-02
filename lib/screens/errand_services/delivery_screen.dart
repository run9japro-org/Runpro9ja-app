import 'package:flutter/material.dart';

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

class DeliveryPickupScreen extends StatefulWidget {
  const DeliveryPickupScreen({super.key});

  @override
  State<DeliveryPickupScreen> createState() => _DeliveryPickupScreenState();
}

class _DeliveryPickupScreenState extends State<DeliveryPickupScreen> {
  int selected = 1; // 0 Basic, 1 Standard, 2 Express

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _whiteAppBar(title: 'Delivery/ Pickup'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Location'),
            const SizedBox(height: 8),

            // FROM field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'From',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  decoration:
                      _greenFieldDecoration(
                        'Type delivery/pickup address here',
                      ).copyWith(
                        prefixIcon: const Icon(
                          Icons.place_outlined,
                          color: kGreen,
                        ),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // TO field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('To', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  decoration:
                      _greenFieldDecoration(
                        'Type delivery/pickup address here',
                      ).copyWith(
                        prefixIcon: const Icon(
                          Icons.place_outlined,
                          color: kGreen,
                        ),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: const [
                  Expanded(child: Text('Order details')),
                  Icon(Icons.keyboard_arrow_right),
                ],
              ),
            ),
            const SizedBox(height: 18),

            const _SectionTitle('Payment Summary'),
            const SizedBox(height: 10),

            _paymentCard(
              title: 'Basic',
              subtitle: 'Bulk delivery. Get items in the next 2 days',
              price: '₦ 1500.00',
              selected: selected == 0,
              onTap: () => setState(() => selected = 0),
            ),
            const SizedBox(height: 10),
            _paymentCard(
              title: 'Standard',
              subtitle: 'Get your package within 24 hours',
              price: '₦ 3000.00',
              selected: selected == 1,
              onTap: () => setState(() => selected = 1),
            ),
            const SizedBox(height: 10),
            _paymentCard(
              title: 'Express',
              subtitle: 'Delivery in less than 2 hours',
              price: '₦ 5000.00',
              selected: selected == 2,
              onTap: () => setState(() => selected = 2),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreen,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {},
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _paymentCard({
    required String title,
    required String subtitle,
    required String price,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? kGreen : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: kGreen.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            // Price tag block on the right
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? kGreen : const Color(0xFFBDBDBD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
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
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
    );
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
