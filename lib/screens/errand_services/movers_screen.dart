import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/agents_screen/available_agent_screen.dart';

import '../../models/agent_model.dart';

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
        leading: const BackButton(),
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
    // For small move, collect addresses first, then schedule, then show instant move
    final addressData = await _openAddressStep(context);
    if (addressData == null) return; // User cancelled

    final scheduleData = await _openScheduleStep(context);
    if (scheduleData == null) return; // User cancelled

    // Combine all data and open instant move
    _openInstantMoveOverlay(
      context,
      fromAddress: addressData['fromAddress'],
      toAddress: addressData['toAddress'],
      vehicleType: scheduleData['vehicleType'],
      date: scheduleData['date'],
      timeFrom: scheduleData['timeFrom'],
      timeTo: scheduleData['timeTo'],
    );
  }

  Future<void> _openScheduleFlow(BuildContext context) async {
    // For scheduled moves, collect addresses first, then schedule
    final addressData = await _openAddressStep(context);
    if (addressData == null) return;

    final scheduleData = await _openScheduleStep(context);
    if (scheduleData == null) return;

    // For scheduled moves, go directly to order summary
    _showScheduledMoveSummary(
      context,
      fromAddress: addressData['fromAddress'],
      toAddress: addressData['toAddress'],
      vehicleType: scheduleData['vehicleType'],
      date: scheduleData['date'],
      timeFrom: scheduleData['timeFrom'],
      timeTo: scheduleData['timeTo'],
      moveType: 'apartment', // You can determine this based on which tile was tapped
    );
  }

  // STEP 1: Collect Addresses
  Future<Map<String, dynamic>?> _openAddressStep(BuildContext context) {
    final TextEditingController fromController = TextEditingController();
    final TextEditingController toController = TextEditingController();
    final TextEditingController floorController = TextEditingController();

    return showModalBottomSheet<Map<String, dynamic>>(
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
            const Text('Enter Addresses',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2E8B6D),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text("Pickup & Delivery Addresses",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'From Address',
              hint: 'Enter pickup address',
              controller: fromController,
            ),
            const SizedBox(height: 10),
            _LabeledField(
              label: 'To Address',
              hint: 'Enter delivery address',
              controller: toController,
            ),
            const SizedBox(height: 10),
            _LabeledField(
              label: 'Building floor (Optional)',
              hint: 'Floor number if any',
              controller: floorController,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (fromController.text.isEmpty || toController.text.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please enter both addresses')),
                  );
                  return;
                }

                Navigator.of(ctx).pop({
                  'fromAddress': fromController.text,
                  'toAddress': toController.text,
                  'buildingFloor': floorController.text,
                });
              },
              child: const Text('Continue to Schedule'),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 2: Collect Schedule Details
  Future<Map<String, dynamic>?> _openScheduleStep(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ScheduleStep(
        onContinue: (scheduleData) {
          Navigator.of(ctx).pop(scheduleData);
        },
      ),
    );
  }

  // INSTANT MOVE OVERLAY (for Small Move)
  Future<void> _openInstantMoveOverlay(
      BuildContext context, {
        required String fromAddress,
        required String toAddress,
        required String vehicleType,
        required String date,
        required String timeFrom,
        required String timeTo,
      }) {
    final TextEditingController itemsController = TextEditingController();
    final totalAmount = 17500.00; // Sample amount

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
            const Text('Small Move - Item Details',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 14),

            // Address Card with ACTUAL addresses
            AddressCard(
              fromAddress: fromAddress,
              toAddress: toAddress,
            ),

            const SizedBox(height: 10),
            Text(
              'Scheduled: $date, $timeFrom - $timeTo • Vehicle: ${vehicleType.capitalize()}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 10),
            TextFormField(
              controller: itemsController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Please describe what you need moved in details...',
                border: OutlineInputBorder(),
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
                  builder: (c) => OrderDetailsOverlay(
                    fromAddress: fromAddress,
                    toAddress: toAddress,
                    moveType: 'small',
                    totalAmount: totalAmount,
                    vehicleType: vehicleType,
                    itemsDescription: itemsController.text,
                    date: date,
                    timeFrom: timeFrom,
                    timeTo: timeTo,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E8B6D),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Review Order & Continue'),
            ),
          ],
        ),
      ),
    );
  }

  // SCHEDULED MOVE SUMMARY (for Apartment/Office moves)
  void _showScheduledMoveSummary(
      BuildContext context, {
        required String fromAddress,
        required String toAddress,
        required String vehicleType,
        required String date,
        required String timeFrom,
        required String timeTo,
        required String moveType,
      }) {
    final totalAmount = 25000.00; // Sample amount for scheduled moves

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => OrderDetailsOverlay(
        fromAddress: fromAddress,
        toAddress: toAddress,
        moveType: moveType,
        totalAmount: totalAmount,
        vehicleType: vehicleType,
        itemsDescription: 'Scheduled $moveType move',
        date: date,
        timeFrom: timeFrom,
        timeTo: timeTo,
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

// ======= SCHEDULE STEP =======

class ScheduleStep extends StatefulWidget {
  final Function(Map<String, dynamic>) onContinue;

  const ScheduleStep({super.key, required this.onContinue});

  @override
  State<ScheduleStep> createState() => _ScheduleStepState();
}

class _ScheduleStepState extends State<ScheduleStep> {
  int selectedVehicle = 1;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeFromController = TextEditingController();
  final TextEditingController timeToController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _sheetHandle(),
          const SizedBox(height: 6),
          const Text(
            'Schedule Your Move',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LabeledField(
                label: 'Move Date',
                hint: 'e.g., August 16, 2025',
                controller: dateController,
              ),
              const SizedBox(height: 10),
              const Text("Your Available Time", style: TextStyle(fontSize: 15)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _LabeledField(
                      label: 'From',
                      hint: '4:00 PM',
                      controller: timeFromController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LabeledField(
                      label: 'To',
                      hint: '6:00 PM',
                      controller: timeToController,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Align(
              alignment: Alignment.centerLeft,
              child: Text('Select Vehicle Type',
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
                icon: Icons.airport_shuttle,
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
          ElevatedButton(
            onPressed: () {
              if (dateController.text.isEmpty ||
                  timeFromController.text.isEmpty ||
                  timeToController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all schedule fields')),
                );
                return;
              }

              widget.onContinue({
                'date': dateController.text,
                'timeFrom': timeFromController.text,
                'timeTo': timeToController.text,
                'vehicleType': _getVehicleType(selectedVehicle),
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E8B6D),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  String _getVehicleType(int index) {
    switch (index) {
      case 0: return 'car';
      case 1: return 'van';
      case 2: return 'truck';
      default: return 'van';
    }
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

// ======= ORDER DETAILS OVERLAY (FIXED) =======

class OrderDetailsOverlay extends StatelessWidget {
  final String fromAddress;
  final String toAddress;
  final String moveType;
  final double totalAmount;
  final String vehicleType;
  final String itemsDescription;
  final String date;
  final String timeFrom;
  final String timeTo;

  const OrderDetailsOverlay({
    super.key,
    required this.fromAddress,
    required this.toAddress,
    required this.moveType,
    required this.totalAmount,
    required this.vehicleType,
    required this.itemsDescription,
    required this.date,
    required this.timeFrom,
    required this.timeTo,
  });

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
              const Text("Order Summary",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 12),

          // From/To Card with ACTUAL addresses
          AddressCard(
            fromAddress: fromAddress,
            toAddress: toAddress,
          ),
          const SizedBox(height: 12),

          // Schedule & Vehicle Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _detailRow("Move Type", _getMoveTypeDisplay(moveType)),
                _detailRow("Vehicle", vehicleType.capitalize()),
                _detailRow("Scheduled Date", date),
                _detailRow("Time Slot", '$timeFrom - $timeTo'),
                if (itemsDescription.isNotEmpty)
                  _detailRow("Items Description", itemsDescription),
                const Divider(),
                _detailRow("Total Amount", "₦${totalAmount.toStringAsFixed(2)}", bold: true),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Proceed to Agent Selection Button
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close the overlay
              _proceedToAgentSelection(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E8B6D),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("Find Moving Agents & Continue"),
          )
        ],
      ),
    );
  }

  void _proceedToAgentSelection(BuildContext context) {
    final orderData = {
      'serviceType': 'movers',
      'moveType': moveType,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'vehicleType': vehicleType,
      'totalAmount': totalAmount,
      'itemsDescription': itemsDescription,
      'scheduledDate': date,
      'scheduledTime': '$timeFrom - $timeTo',
      'estimatedHours': 2,
      'numberOfMovers': 2,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgentSelectionScreen(
          serviceType: 'moving',
          orderData: orderData,
          orderAmount: totalAmount,
        ),
      ),
    );
  }

  String _getMoveTypeDisplay(String moveType) {
    switch (moveType) {
      case 'small': return 'Small Move';
      case 'apartment': return 'Apartment Move';
      case 'office': return 'Office Move';
      case 'truck_only': return 'Truck/Labour Only';
      default: return moveType;
    }
  }

  Widget _detailRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );
  }
}

// ======= REUSABLE WIDGETS =======

class _LabeledField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;

  const _LabeledField({required this.label, this.hint, this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
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
        color: const Color(0xFF2E8B6D),
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
                      "PICKUP FROM",
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
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Dotted Line
          Container(
            margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
            height: 20,
            child: Row(
              children: [
                const SizedBox(width: 4),
                Expanded(
                  child: CustomPaint(
                    painter: DottedLinePainter(),
                  ),
                ),
              ],
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
                      "DELIVER TO",
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

// Dotted Line Painter
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// String extension for capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

// Add this after your AgentSelectionScreen in the movers_screen.dart

// ======= ORDER CONFIRMATION SCREEN (with price details + agent) // ======= ORDER CONFIRMATION SCREEN (FIXED) =======
class MoversOrderConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final Agent selectedAgent;
  final String serviceType;

  const MoversOrderConfirmationScreen({
    super.key,
    required this.orderData,
    required this.selectedAgent,
    required this.serviceType,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount = orderData['totalAmount'] ?? 0.0;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Success/Pending Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.access_time,
                color: Colors.orange,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),

            // Status Message
            const Text(
              'Order Sent to Agent!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              // FIX: Changed from selectedAgent.name to selectedAgent.displayName
              'Your ${serviceType} order has been sent to ${selectedAgent.displayName} for approval',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Order Details Card
            _buildOrderDetailsCard(),
            const SizedBox(height: 20),

            // Price Breakdown
            _buildPriceBreakdown(),
            const SizedBox(height: 20),

            // Selected Agent Card
            _buildAgentCard(),
            const SizedBox(height: 20),

            // Next Steps
            _buildNextSteps(),
            const SizedBox(height: 30),

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Service Type', 'Moving Service'),
          _buildDetailRow('Move Type', orderData['moveType'] ?? 'Small Move'),
          _buildDetailRow('From', orderData['fromAddress'] ?? ''),
          _buildDetailRow('To', orderData['toAddress'] ?? ''),
          _buildDetailRow('Vehicle', orderData['vehicleType'] ?? 'Van'),
          if (orderData['scheduledDate'] != null)
            _buildDetailRow('Scheduled Date', orderData['scheduledDate'] ?? ''),
          if (orderData['scheduledTime'] != null)
            _buildDetailRow('Time Slot', orderData['scheduledTime'] ?? ''),
          _buildDetailRow('Status', 'Pending Agent Response',
              valueColor: Colors.orange),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    final basePrice = (orderData['totalAmount'] ?? 0.0) * 0.7;
    final serviceFee = (orderData['totalAmount'] ?? 0.0) * 0.2;
    final taxFee = (orderData['totalAmount'] ?? 0.0) * 0.1;
    final totalAmount = orderData['totalAmount'] ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Breakdown',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Moving Service Fee', basePrice),
          _buildPriceRow('Platform Service Fee', serviceFee),
          _buildPriceRow('Tax & Insurance', taxFee),
          const Divider(height: 20),
          _buildPriceRow('Total Amount', totalAmount, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildAgentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Agent',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[300],
                // FIX: Updated profile image handling
                backgroundImage: selectedAgent.profileImage.isNotEmpty
                    ? NetworkImage('https://runpro9ja-backend.onrender.com${selectedAgent.profileImage}')
                    : null,
                child: selectedAgent.profileImage.isEmpty
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FIX: Changed from selectedAgent.name to selectedAgent.displayName
                    Text(
                      selectedAgent.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber[600], size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${selectedAgent.rating} • ${selectedAgent.completedJobs} jobs completed',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // FIX: Changed from selectedAgent.location to selectedAgent.displayLocation
                    Text(
                      selectedAgent.displayLocation,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E8B6D),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '₦${selectedAgent.price.toStringAsFixed(0)}/hr',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          // FIX: Updated bio handling
          if (selectedAgent.bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              selectedAgent.bio,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNextSteps() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What happens next?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 12),
          // FIX: Changed from selectedAgent.name to selectedAgent.displayName
          _buildNextStepItem('1. Order sent to ${selectedAgent.displayName} for review'),
          _buildNextStepItem('2. Agent will accept or decline within 24 hours'),
          _buildNextStepItem('3. You\'ll be notified when agent responds'),
          _buildNextStepItem('4. Payment will be processed after acceptance'),
          _buildNextStepItem('5. Agent will contact you to confirm details'),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E8B6D),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment will be available after agent accepts your order'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text(
              'Proceed to Payment (After Acceptance)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xFF2E8B6D)),
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
            child: const Text(
              'Back to Home',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E8B6D),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.black,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '₦${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? const Color(0xFF2E8B6D) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.access_time, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}