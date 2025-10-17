// professional_service_type_selection.dart - COMPLETE IMPLEMENTATION
import 'package:flutter/material.dart';
import 'package:runpro_9ja/models/agent_model.dart';
import 'package:runpro_9ja/screens/payment_screens/payment_screen.dart';

class ProfessionalServiceTypeSelection extends StatefulWidget {
  final Agent selectedAgent;
  final Map<String, dynamic> orderData;
  final String serviceType;

  const ProfessionalServiceTypeSelection({
    super.key,
    required this.selectedAgent,
    required this.orderData,
    required this.serviceType,
  });

  @override
  State<ProfessionalServiceTypeSelection> createState() => _ProfessionalServiceTypeSelectionState();
}

class _ProfessionalServiceTypeSelectionState extends State<ProfessionalServiceTypeSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Type'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Agent Info
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: widget.selectedAgent.profileImage.isNotEmpty
                          ? NetworkImage(widget.selectedAgent.profileImage)
                          : null,
                      child: widget.selectedAgent.profileImage.isEmpty
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.selectedAgent.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₦${widget.selectedAgent.price.toStringAsFixed(0)}/service',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '${widget.selectedAgent.distance.toStringAsFixed(1)} km away',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Choose Service Type",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "How would you like to schedule your professional service?",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Immediate Service Card
            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.flash_on, color: Colors.orange, size: 40),
                title: const Text(
                  "Immediate Service",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: const Text("Get service within the next 2 hours"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showImmediateServiceOverlay(context);
                },
              ),
            ),

            const SizedBox(height: 20),

            // Scheduled Service Card
            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue, size: 40),
                title: const Text(
                  "Schedule Service",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: const Text("Book for a specific date and time"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showScheduledServiceOverlay(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImmediateServiceOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ProfessionalImmediateServiceOverlay(
        selectedAgent: widget.selectedAgent,
        orderData: widget.orderData,
        serviceType: widget.serviceType,
      ),
    );
  }

  void _showScheduledServiceOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ProfessionalScheduledServiceOverlay(
        selectedAgent: widget.selectedAgent,
        orderData: widget.orderData,
        serviceType: widget.serviceType,
      ),
    );
  }
}

// Immediate Service Overlay
class ProfessionalImmediateServiceOverlay extends StatefulWidget {
  final Agent selectedAgent;
  final Map<String, dynamic> orderData;
  final String serviceType;

  const ProfessionalImmediateServiceOverlay({
    super.key,
    required this.selectedAgent,
    required this.orderData,
    required this.serviceType,
  });

  @override
  State<ProfessionalImmediateServiceOverlay> createState() => _ProfessionalImmediateServiceOverlayState();
}

class _ProfessionalImmediateServiceOverlayState extends State<ProfessionalImmediateServiceOverlay> {
  final TextEditingController _instructionsController = TextEditingController();

  void _proceedToPayment() {
    Navigator.pop(context); // Close overlay

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          orderId: widget.orderData['orderId'],
          amount: widget.orderData['orderAmount'] ?? 0.0,
          agentId: widget.selectedAgent.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Immediate Professional Service",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text("Service will be scheduled within 2 hours."),
          const SizedBox(height: 16),
          TextField(
            controller: _instructionsController,
            decoration: const InputDecoration(
              labelText: "Special Instructions (Optional)",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          const Text(
            "Service Details:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("• Professional: ${widget.selectedAgent.displayName}"),
          Text("• Service: ${widget.orderData['serviceName']}"),
          Text("• Estimated Amount: ₦${widget.orderData['orderAmount']?.toStringAsFixed(0) ?? '0'}"),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _proceedToPayment,
              child: const Text(
                "Confirm & Proceed to Payment",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Scheduled Service Overlay
class ProfessionalScheduledServiceOverlay extends StatefulWidget {
  final Agent selectedAgent;
  final Map<String, dynamic> orderData;
  final String serviceType;

  const ProfessionalScheduledServiceOverlay({
    super.key,
    required this.selectedAgent,
    required this.orderData,
    required this.serviceType,
  });

  @override
  State<ProfessionalScheduledServiceOverlay> createState() => _ProfessionalScheduledServiceOverlayState();
}

class _ProfessionalScheduledServiceOverlayState extends State<ProfessionalScheduledServiceOverlay> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  void _proceedToPayment() {
    if (_dateController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    Navigator.pop(context); // Close overlay

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          orderId: widget.orderData['orderId'],
          amount: widget.orderData['orderAmount'] ?? 0.0,
          agentId: widget.selectedAgent.id,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Schedule Professional Service",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _dateController,
            decoration: const InputDecoration(
              labelText: "Service Date",
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _timeController,
            decoration: const InputDecoration(
              labelText: "Service Time",
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.access_time),
            ),
            readOnly: true,
            onTap: () => _selectTime(context),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _instructionsController,
            decoration: const InputDecoration(
              labelText: "Special Instructions (Optional)",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          const Text(
            "Service Details:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("• Professional: ${widget.selectedAgent.displayName}"),
          Text("• Service: ${widget.orderData['serviceName']}"),
          Text("• Estimated Amount: ₦${widget.orderData['orderAmount']?.toStringAsFixed(0) ?? '0'}"),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _proceedToPayment,
              child: const Text(
                "Schedule & Proceed to Payment",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}