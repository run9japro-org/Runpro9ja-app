import 'dart:async';

import 'package:flutter/material.dart';
import '../../auth/Auth_services/auth_service.dart';
import '../../models/agent_model.dart';
import '../../models/customer_models.dart';
import '../../services/customer_services.dart';
import '../payment_screens/payment_screen.dart';
import '../payment_screens/payment_success_screen.dart';
class PersonalAssistanceApp extends StatelessWidget {
  final AuthService authService;
  final CustomerService customerService;

  const PersonalAssistanceApp({
    super.key,
    required this.authService,
    required this.customerService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Assistance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: AllServicesScreen(
        authService: authService,
        customerService: customerService,
      ),
    );
  }
}

//////////////////////////////
// 1. All Services Screen
//////////////////////////////
class AllServicesScreen extends StatelessWidget {
  final AuthService authService;
  final CustomerService customerService;

  const AllServicesScreen({
    super.key,
    required this.authService,
    required this.customerService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:BackButton(),
        title: const Text(
          "Personal Assistance",
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
                      Icons.assistant,
                      size: 40,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Personal Assistance Services",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Choose the type of personal assistance you need",
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
                    // Personal Assistance Card
                    _buildServiceCard(
                      icon: Icons.assistant,
                      title: "Personal Assistance",
                      subtitle: "Professional personal assistance services",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryScreen(
                              authService: authService,
                              customerService: customerService,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Virtual Assistance Card
                    _buildServiceCard(
                      icon: Icons.computer,
                      title: "Virtual Assistance",
                      subtitle: "Remote assistance and support",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryScreen(
                              authService: authService,
                              customerService: customerService,
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

//////////////////////////////
// 2. Category Screen
//////////////////////////////
class CategoryScreen extends StatefulWidget {
  final AuthService authService;
  final CustomerService customerService;

  const CategoryScreen({
    super.key,
    required this.authService,
    required this.customerService,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _notesController = TextEditingController();
  String? _selectedCategory;

  final List<String> categories = const [
    "Companionship",
    "Technological assistance",
    "Pet care",
    "Medication management",
    "Proxy/Delegate",
    "Transportation",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Select Category",
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green[100]!,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.category,
                      color: Colors.green[700]!,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Service Category",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Choose a category and add any special requirements",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Selection
                    const Text(
                      "Select Category *",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                            });
                          },
                          selectedColor: Colors.green,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected ? Colors.green : Colors.grey[300]!,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Special Requirements
                    const Text(
                      "Special Requirements",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Input any specification you may require of the individual...",
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
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Find Assistants Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedCategory != null ? _findAssistants : null,
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
                              'Find Available Assistants',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  void _findAssistants() {
    if (_selectedCategory == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecommendedAssistantsScreen(
          category: _selectedCategory!,
          specialRequirements: _notesController.text.isNotEmpty ? _notesController.text : null,
          authService: widget.authService,
          customerService: widget.customerService,
        ),
      ),
    );
  }
}

//////////////////////////////
// 3. Recommended Assistants Screen
//////////////////////////////
class RecommendedAssistantsScreen extends StatefulWidget {
  final String category;
  final String? specialRequirements;
  final AuthService authService;
  final CustomerService customerService;

  const RecommendedAssistantsScreen({
    super.key,
    required this.category,
    this.specialRequirements,
    required this.authService,
    required this.customerService,
  });

  @override
  State<RecommendedAssistantsScreen> createState() => _RecommendedAssistantsScreenState();
}

class _RecommendedAssistantsScreenState extends State<RecommendedAssistantsScreen> {
  List<Agent> _assistants = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadAssistants();
  }

  Future<void> _loadAssistants() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      // Use your existing method to get personal assistant agents
      final assistants = await widget.authService.getPersonalAssistantAgents();

      setState(() {
        _assistants = assistants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Recommended ${widget.category}",
          style: const TextStyle(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green[100]!,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.people,
                      color: Colors.green[700]!,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${widget.category} Assistants",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Available professionals in your area",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : _error.isNotEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.grey[400], size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load assistants',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadAssistants,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
                  : _assistants.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, color: Colors.grey, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'No assistants available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _assistants.length,
                itemBuilder: (context, index) {
                  final assistant = _assistants[index];
                  return _buildAssistantCard(assistant);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantCard(Agent assistant) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[300],
              backgroundImage: assistant.profileImage.isNotEmpty
                  ? NetworkImage('https://runpro9ja-backend.onrender.com${assistant.profileImage}')
                  : null,
              child: assistant.profileImage.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey, size: 25)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assistant.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${assistant.rating} • ${assistant.completedJobs} jobs',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${assistant.yearsOfExperience} years exp • ${assistant.location?['address'] ?? 'Lagos'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₦${assistant.price.toStringAsFixed(0)}/hr',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(
                          assistant: assistant,
                          category: widget.category,
                          specialRequirements: widget.specialRequirements,
                          authService: widget.authService,
                          customerService: widget.customerService,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////
// 4. Profile Screen
//////////////////////////////
class ProfileScreen extends StatelessWidget {
  final Agent assistant;
  final String category;
  final String? specialRequirements;
  final AuthService authService;
  final CustomerService customerService;

  const ProfileScreen({
    super.key,
    required this.assistant,
    required this.category,
    this.specialRequirements,
    required this.authService,
    required this.customerService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: assistant.profileImage.isNotEmpty
                  ? NetworkImage('https://runpro9ja-backend.onrender.com${assistant.profileImage}')
                  : null,
              child: assistant.profileImage.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 40)
                  : null,
            ),
            const SizedBox(height: 10),
            Text(
              assistant.displayName,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InfoCard(title: "Experience", value: "${assistant.yearsOfExperience} yrs"),
                InfoCard(title: "Distance", value: "~5km"),
                InfoCard(title: "Hourly Rate", value: "₦${assistant.price}/hr"),
                InfoCard(title: "Rating", value: "${assistant.rating}"),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 5),
                      Text(
                        '${assistant.rating} • ${assistant.completedJobs} jobs completed',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Text(
                      assistant.summary,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Services Offered",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(assistant.servicesOffered),
                    const SizedBox(height: 10),
                    const Text(
                      "Areas of Expertise",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    Text(assistant.areasOfExpertise),
                    if (specialRequirements != null && specialRequirements!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Text(
                        "Your Requirements",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        specialRequirements!,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingDetailsScreen(
                                assistant: assistant,
                                category: category,
                                specialRequirements: specialRequirements,
                                authService: authService,
                                customerService: customerService,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Book Now",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

//////////////////////////////
// 5. Booking Details Screen
//////////////////////////////
class BookingDetailsScreen extends StatefulWidget {
  final Agent assistant;
  final String category;
  final String? specialRequirements;
  final AuthService authService;
  final CustomerService customerService;

  const BookingDetailsScreen({
    super.key,
    required this.assistant,
    required this.category,
    this.specialRequirements,
    required this.authService,
    required this.customerService,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
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
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: widget.assistant.profileImage.isNotEmpty
                        ? NetworkImage('https://runpro9ja-backend.onrender.com${widget.assistant.profileImage}')
                        : null,
                    child: widget.assistant.profileImage.isEmpty
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.assistant.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          widget.category,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₦${widget.assistant.price}/hr',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                      fontSize: 16,
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
                      const Text(
                        "Client's Information",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _nameController,
                        label: "Client's Name *",
                        hintText: "Enter your full name",
                        icon: Icons.person_outline,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _locationController,
                        label: "Location *",
                        hintText: "Enter your location",
                        icon: Icons.location_on_outlined,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _organizationController,
                        label: "Organization Name (if any)",
                        hintText: "Enter organization name",
                        icon: Icons.business_outlined,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _roleController,
                        label: "Specific Role *",
                        hintText: "e.g., Personal Assistant, Caregiver, etc.",
                        icon: Icons.work_outline,
                        isRequired: true,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _dateController,
                        label: "Date *",
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
                              label: "Start Time *",
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
                              label: "End Time *",
                              hintText: "Select end time",
                              icon: Icons.access_time_outlined,
                              isRequired: true,
                              readOnly: true,
                              onTap: () => _selectTime(context, _endTimeController),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _addressController,
                        label: "Service Address *",
                        hintText: "Enter full address where service is needed",
                        icon: Icons.home_outlined,
                        isRequired: true,
                      ),
                      const SizedBox(height: 24),

                      if (widget.specialRequirements != null && widget.specialRequirements!.isNotEmpty) ...[
                        const Text(
                          "Special Requirements",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.specialRequirements!,
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Verify Information Button
                      SizedBox(
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
                          ),
                          onPressed: _isSubmitting ? null : _createPersonalAssistanceOrder,
                          child: _isSubmitting
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Text(
                            "Create Booking",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool isRequired = false,
    bool readOnly = false,
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
            readOnly: readOnly,
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

  Future<void> _createPersonalAssistanceOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Validate fields
      if (_locationController.text.isEmpty) {
        throw Exception('Please enter your location');
      }
      if (_addressController.text.isEmpty) {
        throw Exception('Please enter the service address');
      }

      // Calculate total amount
      final estimatedHours = _calculateEstimatedHours();
      final totalAmount = widget.assistant.price * estimatedHours;

      print('🔄 Creating personal assistance order...');

      // Call the API
      final CustomerOrder order = await widget.customerService.createPersonalAssistanceOrder(
        category: widget.category,
        specificRole: _roleController.text,
        clientName: _nameController.text,
        generalLocation: _locationController.text,
        serviceAddress: _addressController.text,
        date: _dateController.text,
        startTime: _startTimeController.text,
        endTime: _endTimeController.text,
        totalAmount: totalAmount,
        specialRequirements: widget.specialRequirements,
        organization: _organizationController.text,
        requestedAgentId: widget.assistant.id,
      );

      // SIMPLE APPROACH: Create booking data directly
      final Map<String, dynamic> bookingData = {
        '_id': order.id ?? 'mock_${DateTime.now().millisecondsSinceEpoch}',
        'agent': {
          'displayName': widget.assistant.displayName,
          'profileImage': widget.assistant.profileImage,
        },
        'category': widget.category,
        'totalAmount': totalAmount,
        'date': _dateController.text,
        'startTime': _startTimeController.text,
        'endTime': _endTimeController.text,
        'status': order.status ?? 'pending',
        'createdAt': order.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'requestedAgentId': widget.assistant.id,
      };

      print('✅ Booking data created: $bookingData');

      // Navigate to Booking Status Screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingStatusScreen(
              bookingData: bookingData,
              authService: widget.authService,
              customerService: widget.customerService,
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Personal assistance order error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create booking: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }


  double _calculateEstimatedHours() {
    // Simple calculation - in real app, parse the time difference
    // For now, return a default of 4 hours
    return 4.0;
  }
}

//////////////////////////////
// Helper Widgets
//////////////////////////////
class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}


//////////////////////////////
// 6. Booking Status Screen (Fixed - With Scrolling)
//////////////////////////////
class BookingStatusScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  final AuthService authService;
  final CustomerService customerService;

  const BookingStatusScreen({
    super.key,
    required this.bookingData,
    required this.authService,
    required this.customerService,
  });

  @override
  State<BookingStatusScreen> createState() => _BookingStatusScreenState();
}

class _BookingStatusScreenState extends State<BookingStatusScreen> {
  Map<String, dynamic>? _booking;
  bool _isLoading = false;
  bool _isRefreshing = false;
  int _refreshCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeBooking();
  }

  void _initializeBooking() {
    setState(() {
      _booking = widget.bookingData;
    });
  }

  Future<void> _refreshStatus() async {
    setState(() {
      _isRefreshing = true;
      _refreshCount++;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isRefreshing = false;

        // Simulate different status changes based on refresh count
        if (_refreshCount == 1) {
          // First refresh - agent is viewing
          _showAgentViewingMessage();
        } else if (_refreshCount == 2) {
          // Second refresh - agent accepts
          _simulateAgentAcceptance();
        } else if (_refreshCount >= 3) {
          // Keep it accepted
          _simulateAgentAcceptance();
        }
      });
    }
  }

  void _showAgentViewingMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_booking?['agent']?['displayName'] ?? 'Agent'} is reviewing your booking...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _simulateAgentAcceptance() {
    setState(() {
      _booking = {
        ..._booking!,
        'status': 'accepted',
        'acceptedAt': DateTime.now().toIso8601String(),
      };
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_booking?['agent']?['displayName'] ?? 'Agent'} has accepted your booking!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _simulateAgentRejection() {
    setState(() {
      _booking = {
        ..._booking!,
        'status': 'rejected',
        'rejectionReason': 'Agent is unavailable at the requested time',
        'rejectedAt': DateTime.now().toIso8601String(),
      };
    });
  }

  void _navigateToPayment() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          orderId: _booking!['_id'],
          amount: _booking!['totalAmount']?.toDouble() ?? 0.0,
          agentId: _booking!['agentId'] ?? _booking!['requestedAgentId'],
        ),
      ),
    );
  }

  void _showManualStatusOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check Booking Status'),
        content: const Text(
          'Since real-time status updates are not available, you can:\n\n'
              '1. Use the refresh button to check for updates\n'
              '2. Wait for the agent to contact you directly\n'
              '3. Check your email for updates\n'
              '4. Contact customer support\n\n'
              'For demo purposes, you can simulate different scenarios.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateAgentAcceptance();
            },
            child: const Text('Simulate Acceptance'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateAgentRejection();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Simulate Rejection'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = _booking?['status'] ?? 'pending';
    final agentName = _booking?['agent']?['displayName'] ?? 'Agent';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getStatusColor(currentStatus).withOpacity(0.1),
                      Colors.white,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Status icon with refresh animation
                    _buildStatusIcon(currentStatus),
                    const SizedBox(height: 20),
                    Text(
                      _getStatusTitle(currentStatus),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getStatusSubtitle(currentStatus, agentName),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (currentStatus == 'pending' || currentStatus == 'pending_agent_response' || currentStatus == 'requested') ...[
                      const SizedBox(height: 8),
                      Text(
                        'Refresh count: $_refreshCount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Content Section
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Status Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          if (_isLoading) ...[
                            const CircularProgressIndicator(
                              color: Colors.green,
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Processing your booking...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ] else if (_booking != null) ...[
                            _buildStatusTimeline(currentStatus),
                            const SizedBox(height: 20),
                            _buildBookingDetails(),
                            const SizedBox(height: 16),

                            // Refresh info - ALWAYS SHOW FOR ANY STATUS
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info, color: Colors.blue[600], size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _refreshCount == 0
                                          ? 'Tap "Check Status" to see if the agent has responded'
                                          : 'Keep checking for updates',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons - ALWAYS SHOW CHECK STATUS BUTTON
                  if (!_isLoading && _booking != null)
                    _buildActionButtons(currentStatus),

                  const SizedBox(height: 20), // Extra space at bottom for scrolling
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String currentStatus) {
    return _isRefreshing
        ? SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          // Rotating refresh icon
          Center(
            child: AnimatedRotation(
              turns: _isRefreshing ? 1 : 0,
              duration: const Duration(seconds: 1),
              child: Icon(
                Icons.refresh,
                size: 40,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    )
        : Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: _getStatusColor(currentStatus).withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getStatusIcon(currentStatus),
        size: 40,
        color: _getStatusColor(currentStatus),
      ),
    );
  }

  Widget _buildStatusTimeline(String currentStatus) {
    final steps = [
      _TimelineStep(
        status: 'pending',
        title: 'Booking Created',
        subtitle: 'Your request has been submitted',
        icon: Icons.check_circle,
      ),
      _TimelineStep(
        status: 'accepted',
        title: 'Agent Review',
        subtitle: 'Agent is reviewing your request',
        icon: Icons.person,
      ),
      _TimelineStep(
        status: 'payment',
        title: 'Make Payment',
        subtitle: 'Complete payment to confirm',
        icon: Icons.payment,
      ),
      _TimelineStep(
        status: 'confirmed',
        title: 'Booking Confirmed',
        subtitle: 'Service scheduled and confirmed',
        icon: Icons.assignment_turned_in,
      ),
    ];

    return Column(
      children: steps.map((step) {
        final isCompleted = _isStepCompleted(step.status, currentStatus);
        final isActive = step.status == currentStatus;

        return _buildTimelineStep(
          icon: step.icon,
          title: step.title,
          subtitle: step.subtitle,
          isCompleted: isCompleted,
          isActive: isActive,
        );
      }).toList(),
    );
  }

  bool _isStepCompleted(String stepStatus, String currentStatus) {
    final statusOrder = ['pending', 'accepted', 'payment', 'confirmed', 'completed'];
    final currentIndex = statusOrder.indexOf(currentStatus);
    final stepIndex = statusOrder.indexOf(stepStatus);
    return stepIndex <= currentIndex;
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green
                  : isActive
                  ? Colors.orange
                  : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        _buildDetailRow('Booking ID', '#${_booking!['_id']?.substring(0, 8) ?? 'N/A'}'),
        _buildDetailRow('Service', _booking!['category'] ?? 'Personal Assistance'),
        _buildDetailRow('Date', _booking!['date'] ?? 'Not specified'),
        _buildDetailRow('Time', '${_booking!['startTime']} - ${_booking!['endTime']}'),
        _buildDetailRow('Amount', '₦${_booking!['totalAmount']?.toStringAsFixed(2) ?? '0.00'}'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String currentStatus) {
    // ALWAYS SHOW CHECK STATUS BUTTON REGARDLESS OF STATUS
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isRefreshing ? null : _refreshStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: _isRefreshing
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 20),
                SizedBox(width: 8),
                Text(
                  'Check Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Show additional buttons based on status
        if (currentStatus == 'accepted')
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _navigateToPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Proceed to Payment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        else if (currentStatus == 'rejected' || currentStatus == 'cancelled')
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Find Another Agent',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _booking = {
                        ..._booking!,
                        'status': 'pending',
                      };
                      _refreshCount = 0;
                    });
                  },
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _showCancelOptions,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Cancel Booking',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        const SizedBox(height: 8),
        TextButton(
          onPressed: _showManualStatusOptions,
          child: const Text(
            'Manual Status Options',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Since real-time cancellation is not available, you can:\n\n'
              '1. Contact the agent directly to cancel\n'
              '2. Call customer support\n'
              '3. Wait for the agent to respond\n\n'
              'For demo purposes, you can simulate cancellation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Contact Support'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateLocalCancellation();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Simulate Cancel (Demo)'),
          ),
        ],
      ),
    );
  }

  void _simulateLocalCancellation() {
    setState(() {
      _booking = {
        ..._booking!,
        'status': 'cancelled',
        'cancellationReason': 'Cancelled by user',
        'cancelledAt': DateTime.now().toIso8601String(),
      };
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Booking Cancelled'),
        content: const Text(
          'Your booking has been marked as cancelled locally.\n\n'
              'Note: In a real scenario, you would need to contact the agent or support team to confirm cancellation.',
        ),
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

  // Helper methods for status display
  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      case 'cancelled': return Colors.orange;
      case 'completed': return Colors.blue;
      default: return Colors.orange; // pending and all other statuses
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'accepted': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      case 'cancelled': return Icons.cancel;
      case 'completed': return Icons.assignment_turned_in;
      default: return Icons.pending_actions; // pending and all other statuses
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'accepted': return 'Booking Accepted!';
      case 'rejected': return 'Booking Declined';
      case 'cancelled': return 'Booking Cancelled';
      case 'completed': return 'Service Completed';
      default: return 'Waiting for Agent'; // pending and all other statuses
    }
  }

  String _getStatusSubtitle(String status, String agentName) {
    switch (status) {
      case 'accepted': return '$agentName has accepted your booking. Proceed to payment.';
      case 'rejected': return '$agentName is unable to accept your booking at this time.';
      case 'cancelled': return 'This booking has been cancelled.';
      case 'completed': return 'Your service has been successfully completed.';
      default: return 'Tap "Check Status" to see if $agentName has responded.'; // pending and all other statuses
    }
  }
}

class _TimelineStep {
  final String status;
  final String title;
  final String subtitle;
  final IconData icon;

  const _TimelineStep({
    required this.status,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}