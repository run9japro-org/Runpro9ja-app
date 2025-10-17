import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/payment_screens/payment_screen.dart';

import '../../models/agent_model.dart';
import '../agents_screen/available_agent_screen.dart';

class BabysittingApp extends StatelessWidget {
  const BabysittingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Babysitting Service",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const ServiceSelectionScreen(),
    );
  }
}

/// 1. Service Selection Screen
class ServiceSelectionScreen extends StatelessWidget {
  const ServiceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text(
          "Babysitting Service",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green[50]!,
                    Colors.green[100]!,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.child_care,
                      size: 40,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Choose Service Type",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Select the type of babysitting service you need",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Child Babysitting Card
                    _buildServiceCard(
                      icon: Icons.child_friendly,
                      title: "Child Babysitting",
                      subtitle: "Professional childcare services",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BookingDetailsScreen(
                              serviceType: 'child_babysitting',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Animal Babysitting Card
                    _buildServiceCard(
                      icon: Icons.pets,
                      title: "Animal Babysitting",
                      subtitle: "Pet care and sitting services",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BookingDetailsScreen(
                              serviceType: 'animal_babysitting',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.green,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 5. Booking Details Screen
class BookingDetailsScreen extends StatefulWidget {
  final String serviceType;

  const BookingDetailsScreen({super.key, required this.serviceType});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _needsController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isChildService = widget.serviceType == 'child_babysitting';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Booking Details",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green[50]!,
                    Colors.white,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green[100]!,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isChildService ? Icons.child_friendly : Icons.pets,
                      color: Colors.green[700]!,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isChildService ? "Child Babysitting" : "Animal Babysitting",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "Fill in the details below",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Section
                      _buildSectionHeader("Basic Information"),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _nameController,
                        label: isChildService ? "Child's Name" : "Pet's Name",
                        hintText: isChildService ? "Enter child's full name" : "Enter pet's name",
                        icon: Icons.person_outline,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _ageController,
                        label: isChildService ? "Age" : "Pet's Age",
                        hintText: isChildService ? "Enter age" : "Enter pet's age",
                        icon: Icons.cake_outlined,
                        isRequired: true,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _needsController,
                        label: isChildService ? "Special Needs" : "Special Care",
                        hintText: isChildService ? "Any special requirements or needs" : "Special care instructions",
                        icon: Icons.medical_services_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),

                      // Schedule Section
                      _buildSectionHeader("Schedule"),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _dateController,
                        label: "Date",
                        hintText: "Select date",
                        icon: Icons.calendar_today_outlined,
                        isRequired: true,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _startTimeController,
                              label: "Start Time",
                              hintText: "Select start time",
                              icon: Icons.access_time_outlined,
                              isRequired: true,
                              readOnly: true,
                              onTap: () => _selectTime(context, _startTimeController),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _endTimeController,
                              label: "End Time",
                              hintText: "Select end time",
                              icon: Icons.access_time_outlined,
                              isRequired: true,
                              readOnly: true,
                              onTap: () => _selectTime(context, _endTimeController),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Location & Notes Section
                      _buildSectionHeader("Location & Notes"),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _addressController,
                        label: "Service Address",
                        hintText: "Enter full address where service is needed",
                        icon: Icons.location_on_outlined,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _notesController,
                        label: "Additional Notes",
                        hintText: "Any additional information or instructions...",
                        icon: Icons.note_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 40),

                      // Find Babysitters Button
                      _buildSubmitButton(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool isRequired = false,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isRequired)
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            readOnly: readOnly,
            keyboardType: keyboardType,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.green,
                  width: 2,
                ),
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.grey[600],
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: isRequired
                ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _proceedToAgentSelection,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          shadowColor: Colors.green.withOpacity(0.3),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 20),
            SizedBox(width: 8),
            Text(
              'Find Available Babysitters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  void _proceedToAgentSelection() {
    if (!_formKey.currentState!.validate()) return;

    // Calculate estimated amount based on service type and duration
    final estimatedAmount = _calculateEstimatedAmount();

    // Prepare order data
    final orderData = {
      'serviceType': widget.serviceType,
      'serviceName': widget.serviceType == 'child_babysitting'
          ? 'Child Babysitting'
          : 'Animal Babysitting',
      'childName': _nameController.text,
      'age': _ageController.text,
      'specialNeeds': _needsController.text,
      'date': _dateController.text,
      'startTime': _startTimeController.text,
      'endTime': _endTimeController.text,
      'address': _addressController.text,
      'notes': _notesController.text,
      'estimatedHours': _calculateEstimatedHours(),
      'totalAmount': estimatedAmount,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgentSelectionScreen(
          serviceType: widget.serviceType,
          orderData: orderData,
          orderAmount: estimatedAmount,
        ),
      ),
    );
  }

  double _calculateEstimatedAmount() {
    // Base price varies by service type
    double basePrice = widget.serviceType == 'child_babysitting' ? 4000.0 : 3000.0;
    final hours = _calculateEstimatedHours();
    return basePrice * hours;
  }

  double _calculateEstimatedHours() {
    // Simple calculation - in real app, parse the time difference
    // For now, return a default of 4 hours
    return 4.0;
  }
}

/// 6. Booking Summary Screen
class BookingSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String serviceType;
  final Agent selectedAgent;

  const BookingSummaryScreen({
    super.key,
    required this.orderData,
    required this.serviceType,
    required this.selectedAgent,
  });

  @override
  Widget build(BuildContext context) {
    final isChildService = serviceType == 'child_babysitting';
    final totalAmount = orderData['totalAmount'] ?? 0.0;
    final estimatedHours = orderData['estimatedHours'] ?? 4.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Booking Summary",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green[50]!,
                    Colors.white,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      isChildService ? Icons.child_friendly : Icons.pets,
                      color: Colors.green[700]!,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isChildService ? "Child Babysitting" : "Animal Babysitting",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Review your booking details",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Babysitter Information Card
                    _buildInfoCard(
                      title: "Babysitter Information",
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: selectedAgent.profileImage.isNotEmpty
                                ? NetworkImage('https://runpro9ja-backend.onrender.com${selectedAgent.profileImage}')
                                : null,
                            child: selectedAgent.profileImage.isEmpty
                                ? const Icon(Icons.person, color: Colors.grey, size: 25)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedAgent.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${selectedAgent.yearsOfExperience} years experience',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.amber[600], size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${selectedAgent.rating} • ${selectedAgent.completedJobs} jobs',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₦${selectedAgent.price.toStringAsFixed(0)}/hr',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Available',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Booking Details Card
                    _buildInfoCard(
                      title: "Booking Details",
                      child: Column(
                        children: [
                          _buildDetailRow(
                            "Service Type",
                            isChildService ? "Child Babysitting" : "Animal Babysitting",
                          ),
                          _buildDetailRow(
                            isChildService ? "Child's Name" : "Pet's Name",
                            orderData['childName'] ?? 'Not specified',
                          ),
                          _buildDetailRow("Age", orderData['age'] ?? 'Not specified'),
                          if (orderData['specialNeeds'] != null && orderData['specialNeeds'].isNotEmpty)
                            _buildDetailRow("Special Needs", orderData['specialNeeds']),
                          _buildDetailRow("Date", orderData['date'] ?? 'Not specified'),
                          _buildDetailRow(
                              "Time",
                              "${orderData['startTime'] ?? ''} - ${orderData['endTime'] ?? ''}"
                          ),
                          _buildDetailRow("Address", orderData['address'] ?? 'Not specified'),
                          if (orderData['notes'] != null && orderData['notes'].isNotEmpty)
                            _buildDetailRow("Notes", orderData['notes']),
                          const SizedBox(height: 12),
                          const Divider(),
                          _buildDetailRow("Estimated Hours", "${estimatedHours.toStringAsFixed(1)} hours"),
                          _buildDetailRow(
                            "Total Cost",
                            "₦${totalAmount.toStringAsFixed(2)}",
                            isBold: true,
                            valueColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Proceed to Payment Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    shadowColor: Colors.green.withOpacity(0.3),
                  ),
                  onPressed: () {
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Proceed to Payment",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
                color: valueColor ?? Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}