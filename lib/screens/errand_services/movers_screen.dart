import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/payment_screens/payment_screen.dart';

class MoversApp extends StatelessWidget {
  const MoversApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E8B6D)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2E8B6D), width: 1.4),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E8B6D),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      home: const MoversTypePage(),
    );
  }
}

class MoversTypePage extends StatelessWidget {
  const MoversTypePage({super.key});

  static const _subtitleStyle =
  TextStyle(fontSize: 12.5, color: Color(0xFF6E6E6E));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back)),
        title: const Text('Movers Type',
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _tile(
              title: 'Small Move',
              subtitle: 'Move few items to short distance',
              onTap: () => _openSmallMoveFlow(context),
            ),
            _tile(
              title: 'Apartment Move',
              subtitle: 'Studio,1 room,2 room or more than',
              onTap: () => _openScheduleFlow(context),
            ),
            _tile(
              title: 'Office move',
              subtitle: 'Clearing out or relocating your office building',
              onTap: () => _openScheduleFlow(context),
            ),
            _tile(
              title: 'Truck only/labour only',
              subtitle: 'No truck, but a ton of muscle or vice versa',
              onTap: () => _openScheduleFlow(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15.5)),
                const SizedBox(height: 4),
                Text(subtitle, style: _subtitleStyle),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // ============ FLOW HELPERS ============

  Future<void> _openSmallMoveFlow(BuildContext context) async {
    await _openScheduleStep2(context, goToSmallMove: true);
  }

  Future<void> _openScheduleFlow(BuildContext context) async {
    await _openScheduleStep1(context, goToSmallMove: false);
  }

  Future<void> _openScheduleStep1(BuildContext context,
      {required bool goToSmallMove}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _ScheduleStep1(
          onContinue: () {
            Navigator.of(ctx).pop();
            if (goToSmallMove) {
              _openInstantMoveOverlay(context);
            }
          },
        ),
      ),
    );
  }

  Future<void> _openScheduleStep2(BuildContext context,
      {required bool goToSmallMove}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const SizedBox(height: 6),
            const Text('Schedule your move',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2E8B6D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text("Client's Info:",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            const _LabeledField(label: 'From', hint: 'Type address here'),
            const SizedBox(height: 10),
            const _LabeledField(label: 'To', hint: 'Type address here'),
            const SizedBox(height: 10),
            const _LabeledField(label: 'Building floor', hint: 'Type number here'),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () {

                    Navigator.of(ctx).pop();
                    _openScheduleStep1(context, goToSmallMove: goToSmallMove);

                },
                child: const Text('Continue')),
          ],
        ),
      ),
    );
  }

  Future<void> _openInstantMoveOverlay(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const SizedBox(height: 6),
            const Text('Small Move',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 14),

            // 🔥 Replace "From" and "To" fields with AddressCard
            const AddressCard(
              fromAddress: "22, Tejuosho market, Idi araba Lagos....",
              toAddress: "19, New Abule egba Road, Abeokuta ex...",
            ),

            const SizedBox(height: 10),
            TextFormField(
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                'Please describe what you need moved in details and if you will be on-site to assist the mover',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (c) => const OrderDetailsOverlay(),
                );
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetHandle() => Container(
    width: 42,
    height: 5,
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.1),
      borderRadius: BorderRadius.circular(100),
    ),
  );
}

// ======= STEP 1 CONTENT (date/time/vehicle) =======

class _ScheduleStep1 extends StatefulWidget {
  const _ScheduleStep1({required this.onContinue});
  final VoidCallback onContinue;

  @override
  State<_ScheduleStep1> createState() => _ScheduleStep1State();
}

class _ScheduleStep1State extends State<_ScheduleStep1> {
  int selectedVehicle = 1; // 0=Car,1=Van,2=Truck

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _sheetHandle(),
      const SizedBox(height: 6),
      const Text(
        'Schedule your move',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      const SizedBox(height: 12),

// ✅ Wrap the whole section in a Column, not inside Expanded
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LabeledField(label: 'Date', hint: '08:00'),
          const SizedBox(height: 10),
          const Text("Your Available Time",style: TextStyle(fontSize: 15),),
          const SizedBox(height: 10,),
          Row(
            children: const [
              Expanded(child: _LabeledField(label: 'From', hint: '08:00')),
              SizedBox(width: 12),
              Expanded(child: _LabeledField(label: 'To', hint: '12:00')),
            ],
          ),
        ],
      ),

      const SizedBox(height: 12),
      const Align(
          alignment: Alignment.centerLeft,
          child: Text('Select vehicle type',
              style: TextStyle(fontWeight: FontWeight.w700))),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _VehicleSelect(
            icon: Icons.directions_car,
            label: 'Car',
            selected: selectedVehicle == 0,
            onTap: () => setState(() => selectedVehicle = 0),
          ),
          _VehicleSelect(
            icon: Icons.airport_shuttle, // van-like
            label: 'Van',
            selected: selectedVehicle == 1,
            onTap: () => setState(() => selectedVehicle = 1),
          ),
          _VehicleSelect(
            icon: Icons.local_shipping,
            label: 'Truck',
            selected: selectedVehicle == 2,
            onTap: () => setState(() => selectedVehicle = 2),
          ),
        ],
      ),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: widget.onContinue, child: const Text('Continue')),
    ]);
  }

  Widget _sheetHandle() => Container(
    width: 42,
    height: 5,
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.1),
      borderRadius: BorderRadius.circular(100),
    ),
  );
}

// ======= REUSABLES =======

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, this.hint});
  final String label;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextFormField(decoration: InputDecoration(hintText: hint)),
    ]);
  }
}

class _VehicleSelect extends StatelessWidget {
  const _VehicleSelect({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? const Color(0xFF2E8B6D).withOpacity(.12)
        : const Color(0xFFF1F3F2);
    final border = selected ? const Color(0xFF2E8B6D) : Colors.transparent;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 84,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class AddressCard extends StatelessWidget {
  final String fromAddress;
  final String toAddress;

  const AddressCard({
    super.key,
    required this.fromAddress,
    required this.toAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E8B6D), // green background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // From Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.radio_button_checked,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "From",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fromAddress,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Dotted Line
          Container(
            margin: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
            height: 30,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Flex(
                  direction: Axis.vertical,
                  children: List.generate(
                    10,
                        (index) =>  Container(
                          width: 2,
                      height: 2,
                          color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),

          // To Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "To",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      toAddress,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class OrderDetailsOverlay extends StatelessWidget {
  const OrderDetailsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Order details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 12),

          // From/To Card (reuse your AddressCard)
          const AddressCard(
            fromAddress: "22, Tejuosho market, Idi araba Lagos...",
            toAddress: "19 New Abule egba Road, Abeokuta ex...",
          ),
          const SizedBox(height: 12),

          // Extra Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 6),
                Text("Aug 16 2025\n4:00pm - 6:00pm",
                    style: TextStyle(fontSize: 13)),
              ]),
              Text("1 Mover + 1 muscle\n21.9 miles",
                  style: TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 14),

          // Price Details
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: const [
                _priceRow("Car", "₦7,500.00"),
                _priceRow("Mover + muscle", "₦5,000.00"),
                _priceRow("Total/hr", "₦12,500.00"),
                _priceRow("Total/requested estimated hour", "₦10,000.00"),
                Divider(),
                _priceRow("Sub Total", "₦17,500.00", bold: true),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Mover Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Chibuzor Ebuzé",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text("Sienna 2005 9hr",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.phone, color: Colors.green),
                const SizedBox(width: 10),
                const Icon(Icons.chat, color: Colors.green),
                const SizedBox(width: 10),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    Text("4.8",
                        style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Proceed Button
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentOptionScreen()
                ),
              );
            },
            child: const Text("Proceed to pay"),
          )
        ],
      ),
    );
  }
}

class _priceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _priceRow(this.label, this.value, {this.bold = false, super.
  key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}
