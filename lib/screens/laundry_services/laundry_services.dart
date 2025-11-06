import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/payment_screens/payment_screen.dart';
import 'package:runpro_9ja/services/customer_services.dart';
import 'package:runpro_9ja/models/customer_models.dart';
import '../../auth/Auth_services/auth_service.dart';
import '../../models/agent_model.dart';
import '../../utils/service_mapper.dart';
import '../agents_screen/available_agent_screen.dart';
import 'laundry_waiting_screen.dart';

class CleaningServices extends StatelessWidget {
  const CleaningServices({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cleaning Services',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1B5E20),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const CleaningServiceScreen(),
    );
  }
}

//////////////////////////////
// 1. Main Cleaning Service Screen
//////////////////////////////
class CleaningServiceScreen extends StatelessWidget {
  const CleaningServiceScreen({super.key});

  final List<Map<String, String>> services = const [
    {
      "title": "Home Cleaning",
      "description": "Professional home cleaning services",
    },
    {
      "title": "Laundry Service",
      "description": "Professional laundry and dry cleaning",
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text("Cleaning Services"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                  service["title"] == "Home Cleaning"
                      ? Icons.cleaning_services
                      : Icons.local_laundry_service,
                  size: 40,
                  color: const Color(0xFF1B5E20)
              ),
              title: Text(service["title"]!),
              subtitle: Text(service["description"]!),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (service["title"] == "Home Cleaning") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeCleaningScreen()),
                  );
                } else if (service["title"] == "Laundry Service") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LaundryServiceHome()),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}

//////////////////////////////
// LAUNDRY SERVICE FLOW - COMPLETE IMPLEMENTATION
//////////////////////////////
class LaundryServiceHome extends StatelessWidget {
  const LaundryServiceHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Laundry Service"),
      ),
      body: const LaundrySelectServicesScreen(),
    );
  }
}

// ------------------ SCREEN 1: Laundry Service Selection ------------------
class LaundrySelectServicesScreen extends StatefulWidget {
  const LaundrySelectServicesScreen({super.key});

  @override
  State<LaundrySelectServicesScreen> createState() => _LaundrySelectServicesScreenState();
}

class _LaundrySelectServicesScreenState extends State<LaundrySelectServicesScreen> {
  final List<Map<String, dynamic>> services = const [
    {
      "title": "Hand wash",
      "icon": Icons.wash,
      "description": "Gentle hand washing for delicate fabrics",
      "basePrice": 1500,
      "serviceCategory": "laundry_hand_wash"
    },
    {
      "title": "Washing machine wash",
      "icon": Icons.local_laundry_service,
      "description": "Machine washing for regular clothes",
      "basePrice": 1000,
      "serviceCategory": "laundry_machine_wash"
    },
    {
      "title": "Iron only",
      "icon": Icons.iron,
      "description": "Professional ironing service",
      "basePrice": 800,
      "serviceCategory": "laundry_ironing"
    },
    {
      "title": "Wash, dry, and fold",
      "icon": Icons.local_laundry_service_outlined,
      "description": "Complete service: wash, dry and neatly folded",
      "basePrice": 2000,
      "serviceCategory": "laundry_wash_dry_fold"
    },
    {
      "title": "Curtain, sheets & bulk items",
      "icon": Icons.inventory,
      "description": "Special handling for large items",
      "basePrice": 3000,
      "serviceCategory": "laundry_bulk_items"
    },
  ];

  Map<String, int> selectedServices = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Choose your laundry service",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final isSelected = selectedServices.containsKey(service["title"]);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: isSelected ? const Color(0xFF1B5E20).withOpacity(0.1) : null,
                child: ListTile(
                  leading: Icon(service["icon"] as IconData, size: 40, color: const Color(0xFF1B5E20)),
                  title: Text(
                    service["title"],
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  subtitle: Text(service["description"]),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "₦${service["basePrice"]}",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                      ),
                      const Text("base", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => LaundryCategoriesSheet(
                        serviceType: service["title"],
                        basePrice: service["basePrice"],
                        serviceCategory: service["serviceCategory"],
                        onServiceAdded: (itemCount, totalPrice) {
                          setState(() {
                            selectedServices[service["title"]] = totalPrice;
                          });
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (selectedServices.isNotEmpty) _buildSelectedServicesSummary(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: selectedServices.isNotEmpty ? () {
                _proceedToDryCleaning();
              } : null,
              child: const Text(
                "Continue to Dry Cleaning",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSelectedServicesSummary() {
    final totalAmount = selectedServices.values.fold(0, (sum, price) => sum + price);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Selected Services:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...selectedServices.entries.map((entry) =>
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Text("₦${entry.value}"),
                ],
              )
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("₦$totalAmount", style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  void _proceedToDryCleaning() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LaundryDryCleaningScreen(
        selectedServices: selectedServices,
      )),
    );
  }
}

// ------------------ Laundry Categories Bottom Sheet ------------------
class LaundryCategoriesSheet extends StatefulWidget {
  final String serviceType;
  final int basePrice;
  final String serviceCategory;
  final Function(int itemCount, int totalPrice) onServiceAdded;

  const LaundryCategoriesSheet({
    super.key,
    required this.serviceType,
    required this.basePrice,
    required this.serviceCategory,
    required this.onServiceAdded,
  });

  @override
  State<LaundryCategoriesSheet> createState() => _LaundryCategoriesSheetState();
}

class _LaundryCategoriesSheetState extends State<LaundryCategoriesSheet> {
  final Map<String, int> selectedItems = {};

  final List<Map<String, dynamic>> categories = [
    {"title": "Shirts", "price": 1000, "icon": Icons.check_box_outline_blank},
    {"title": "Blouse", "price": 1000, "icon": Icons.check_box_outline_blank},
    {"title": "T-shirts", "price": 1000, "icon": Icons.check_box_outline_blank},
    {"title": "Tank tops", "price": 1000, "icon": Icons.check_box_outline_blank},
    {"title": "Crop tops", "price": 1000, "icon": Icons.check_box_outline_blank},
    {"title": "Sweaters", "price": 1500, "icon": Icons.check_box_outline_blank},
    {"title": "Hoodies", "price": 1500, "icon": Icons.check_box_outline_blank},
    {"title": "Jackets", "price": 2000, "icon": Icons.check_box_outline_blank},
  ];

  void _updateQuantity(String item, int quantity) {
    setState(() {
      if (quantity > 0) {
        selectedItems[item] = quantity;
      } else {
        selectedItems.remove(item);
      }
    });
  }

  int get totalPrice {
    int itemsTotal = selectedItems.entries.fold<int>(0, (sum, entry) {
      final item = categories.firstWhere((cat) => cat["title"] == entry.key);
      return sum + (item["price"] as int) * entry.value;
    });
    return widget.basePrice + itemsTotal;
  }

  int get totalItems {
    return selectedItems.values.fold(0, (sum, quantity) => sum + quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${widget.serviceType} - Categories",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(),

          if (selectedItems.isNotEmpty) ...[
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Selected Items:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...selectedItems.entries.map((entry) {
                      final item = categories.firstWhere((cat) => cat["title"] == entry.key);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${entry.key} (x${entry.value})"),
                          Text("₦${(item["price"] as int) * entry.value}"),
                        ],
                      );
                    }),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Service Fee:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("₦${widget.basePrice}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("₦$totalPrice", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final item = categories[index];
                final quantity = selectedItems[item["title"]] ?? 0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Icon(item["icon"] as IconData, color: const Color(0xFF1B5E20)),
                    title: Text(item["title"]!),
                    subtitle: Text("₦${item["price"]} per item"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: quantity > 0 ? () {
                            _updateQuantity(item["title"], quantity - 1);
                          } : null,
                        ),
                        Text("$quantity", style: const TextStyle(fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1B5E20)),
                          onPressed: () {
                            _updateQuantity(item["title"], quantity + 1);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          if (selectedItems.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  widget.onServiceAdded(totalItems, totalPrice);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Added ${selectedItems.length} items to ${widget.serviceType}"),
                      backgroundColor: const Color(0xFF1B5E20),
                    ),
                  );
                },
                child: const Text(
                  "Add to Order",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ------------------ SCREEN 2: Laundry Dry Cleaning ------------------
class LaundryDryCleaningScreen extends StatefulWidget {
  final Map<String, int> selectedServices;

  const LaundryDryCleaningScreen({
    super.key,
    required this.selectedServices,
  });

  @override
  State<LaundryDryCleaningScreen> createState() => _LaundryDryCleaningScreenState();
}

class _LaundryDryCleaningScreenState extends State<LaundryDryCleaningScreen> {
  final List<Map<String, dynamic>> items = [
    {"title": "Shirts", "price": 1000, "qty": 0},
    {"title": "Trousers", "price": 1000, "qty": 0},
    {"title": "Duvet", "price": 1000, "qty": 0},
    {"title": "Curtain", "price": 1000, "qty": 0},
    {"title": "Suits", "price": 2500, "qty": 0},
    {"title": "Dresses", "price": 1500, "qty": 0},
  ];

  final TextEditingController specialInstructionsController = TextEditingController();

  int get totalDryCleaningItems {
    return items.fold<int>(0, (sum, item) => sum + (item["qty"] as int));
  }

  int get totalDryCleaningAmount {
    return items.fold<int>(0, (sum, item) => sum + ((item["price"] as int) * (item["qty"] as int)));
  }

  int get totalLaundryAmount {
    return widget.selectedServices.values.fold(0, (sum, price) => sum + price);
  }

  int get totalAmount {
    return totalLaundryAmount + totalDryCleaningAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dry Cleaning"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dry Cleaning Services",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select from the different kinds of clothes you'd like us to dry clean for you.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // Selected Services Summary
            if (widget.selectedServices.isNotEmpty) ...[
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Selected Laundry Services:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...widget.selectedServices.entries.map((entry) =>
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              Text("₦${entry.value}"),
                            ],
                          )
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Subtotal:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("₦$totalLaundryAmount", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.dry_cleaning, color: Color(0xFF1B5E20)),
                      title: Text(
                        items[index]["title"],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text("₦${items[index]["price"]} per item"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                if (items[index]["qty"] > 0) {
                                  items[index]["qty"]--;
                                }
                              });
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "${items[index]["qty"]}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1B5E20)),
                            onPressed: () {
                              setState(() {
                                items[index]["qty"]++;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              "Special Instructions",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: specialInstructionsController,
              decoration: const InputDecoration(
                hintText: "Any special instructions or things we should look out for...",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Order Summary
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (totalLaundryAmount > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Laundry Services:"),
                          Text("₦$totalLaundryAmount"),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (totalDryCleaningAmount > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Dry Cleaning:"),
                          Text("₦$totalDryCleaningAmount"),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("₦$totalAmount", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                        ),
                        onPressed: (totalLaundryAmount + totalDryCleaningAmount) > 0 ? () {
                          _proceedToServiceType();
                        } : null,
                        child: const Text("Continue to Service Type", style: TextStyle(color: Colors.white)),
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

  void _proceedToServiceType() {
    final orderData = {
      'selectedServices': widget.selectedServices,
      'dryCleaningItems': items.where((item) => item["qty"] > 0).toList(),
      'specialInstructions': specialInstructionsController.text,
      'totalAmount': totalAmount,
    };

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LaundryServiceTypeSelection(
        orderData: orderData,
      )),
    );
  }
}

// ------------------ Laundry Service Type Selection ------------------
// Update the Laundry Service Type Selection to include agent selection
class LaundryServiceTypeSelection extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const LaundryServiceTypeSelection({
    super.key,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Type"),
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
            const Text(
              "Choose Service Type",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "How would you like to schedule your laundry service?",
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
                subtitle: const Text("Pickup within the next 2 hours"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showLaundryImmediateServiceOverlay(context);
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
                  "Schedule Pickup",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: const Text("Schedule for a specific date and time"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showLaundryScheduledServiceOverlay(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLaundryImmediateServiceOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LaundryImmediateServiceOverlay(
        orderData: orderData,
        serviceType: 'immediate',
      ),
    );
  }

  void _showLaundryScheduledServiceOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => LaundryScheduledServiceOverlay(
        orderData: orderData,
        serviceType: 'scheduled',
      ),
    );
  }
}

// Updated Laundry Immediate Service Overlay
class LaundryImmediateServiceOverlay extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final String serviceType;

  const LaundryImmediateServiceOverlay({
    super.key,
    required this.orderData,
    required this.serviceType,
  });

  @override
  State<LaundryImmediateServiceOverlay> createState() => _LaundryImmediateServiceOverlayState();
}

class _LaundryImmediateServiceOverlayState extends State<LaundryImmediateServiceOverlay> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();

  bool _isSubmitting = false;

  // REMOVE the callback approach - just navigate to agent selection
  Future<void> _proceedToAgentSelection() async {
    if (_isSubmitting) return;

    // Validate input
    if (addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter pickup address')),
      );
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Prepare order data for agent selection
      final agentSelectionData = {
        ...widget.orderData,
        'address': addressController.text.trim(),
        'phone': phoneController.text.trim(),
        'instructions': instructionsController.text.trim(),
        'serviceType': 'immediate',
        'location': addressController.text.trim(),
        'description': _buildOrderDescription(),
      };

      // Close the bottom sheet
      Navigator.pop(context);

      // Navigate to agent selection WITHOUT callback
      // Let AgentSelectionScreen handle everything
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AgentSelectionScreen(
            serviceType: 'laundry',
            orderData: agentSelectionData,
            orderAmount: widget.orderData['totalAmount'].toDouble(),
            // NO onAgentSelected callback! Let the screen handle navigation
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _buildOrderDescription() {
    final selectedServices = widget.orderData['selectedServices'] as Map<String, int>;
    final dryCleaningItems = widget.orderData['dryCleaningItems'] as List;

    final description = StringBuffer();
    description.writeln('Immediate Laundry Service');
    description.writeln('');

    if (selectedServices.isNotEmpty) {
      description.writeln('Selected Services:');
      selectedServices.forEach((service, price) {
        description.writeln('- $service: ₦$price');
      });
      description.writeln('');
    }

    if (dryCleaningItems.isNotEmpty) {
      description.writeln('Dry Cleaning Items:');
      for (var item in dryCleaningItems.where((item) => item["qty"] > 0)) {
        description.writeln('- ${item["title"]} (x${item["qty"]}): ₦${(item["price"] as int) * (item["qty"] as int)}');
      }
      description.writeln('');
    }

    if (instructionsController.text.isNotEmpty) {
      description.writeln('Special Instructions:');
      description.writeln(instructionsController.text);
      description.writeln('');
    }

    description.writeln('Pickup within 2 hours');
    description.writeln('Total Amount: ₦${widget.orderData['totalAmount']}');

    return description.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Immediate Laundry Service",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Pickup Address *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: instructionsController,
              decoration: const InputDecoration(
                labelText: "Special Instructions (Optional)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            const Text(
              "Service Details:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text("• Pickup within 2 hours"),
            const Text("• Professional laundry service"),
            const Text("• Delivery in 1-2 days"),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _isSubmitting ? null : _proceedToAgentSelection,
                child: _isSubmitting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  "Continue to Agent Selection",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Updated Laundry Scheduled Service Overlay
class LaundryScheduledServiceOverlay extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final String serviceType;

  const LaundryScheduledServiceOverlay({
    super.key,
    required this.orderData,
    required this.serviceType,
  });

  @override
  State<LaundryScheduledServiceOverlay> createState() => _LaundryScheduledServiceOverlayState();
}

// FIXED: LaundryScheduledServiceOverlay - Remove callback pattern
class _LaundryScheduledServiceOverlayState extends State<LaundryScheduledServiceOverlay> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool _isSubmitting = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
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
        selectedTime = picked;
        timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _proceedToAgentSelection() async {
    if (_isSubmitting) return;

    // Validate input
    if (addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter pickup address')),
      );
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup date')),
      );
      return;
    }

    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup time')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final agentSelectionData = {
        ...widget.orderData,
        'address': addressController.text.trim(),
        'phone': phoneController.text.trim(),
        'instructions': instructionsController.text.trim(),
        'serviceType': 'scheduled',
        'scheduledDate': selectedDate!.toIso8601String(),
        'scheduledTime': selectedTime!.format(context),
        'location': addressController.text.trim(),
        'description': _buildOrderDescription(),
      };

      // Close the bottom sheet
      Navigator.pop(context);

      // Navigate to agent selection WITHOUT callback
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AgentSelectionScreen(
            serviceType: 'laundry',
            orderData: agentSelectionData,
            orderAmount: widget.orderData['totalAmount'].toDouble(),
            // NO onAgentSelected callback!
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _buildOrderDescription() {
    final selectedServices = widget.orderData['selectedServices'] as Map<String, int>;
    final dryCleaningItems = widget.orderData['dryCleaningItems'] as List;

    final description = StringBuffer();
    description.writeln('Scheduled Laundry Service');
    description.writeln('Pickup Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}');
    description.writeln('Pickup Time: ${selectedTime!.format(context)}');
    description.writeln('');

    if (selectedServices.isNotEmpty) {
      description.writeln('Selected Services:');
      selectedServices.forEach((service, price) {
        description.writeln('- $service: ₦$price');
      });
      description.writeln('');
    }

    if (dryCleaningItems.isNotEmpty) {
      description.writeln('Dry Cleaning Items:');
      for (var item in dryCleaningItems.where((item) => item["qty"] > 0)) {
        description.writeln('- ${item["title"]} (x${item["qty"]}): ₦${(item["price"] as int) * (item["qty"] as int)}');
      }
      description.writeln('');
    }

    if (instructionsController.text.isNotEmpty) {
      description.writeln('Special Instructions:');
      description.writeln(instructionsController.text);
      description.writeln('');
    }

    description.writeln('Total Amount: ₦${widget.orderData['totalAmount']}');

    return description.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Schedule Laundry Service",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Pickup Address *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number *",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: "Pickup Date *",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
                prefixIcon: Icon(Icons.event),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: "Pickup Time *",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
                prefixIcon: Icon(Icons.schedule),
              ),
              readOnly: true,
              onTap: () => _selectTime(context),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: instructionsController,
              decoration: const InputDecoration(
                labelText: "Special Instructions (Optional)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: (selectedDate != null &&
                    selectedTime != null &&
                    !_isSubmitting)
                    ? _proceedToAgentSelection
                    : null,
                child: _isSubmitting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  "Continue to Agent Selection",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
// Update the Laundry Order Summary Screen to use CustomerOrder
class LaundryOrderSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String address;
  final String phone;
  final String instructions;
  final String serviceType;
  final Agent selectedAgent;
  final CustomerOrder customerOrder;
  final DateTime? scheduledDate;
  final TimeOfDay? scheduledTime;

  const LaundryOrderSummaryScreen({
    super.key,
    required this.orderData,
    required this.address,
    required this.phone,
    required this.instructions,
    required this.serviceType,
    required this.selectedAgent,
    required this.customerOrder,
    this.scheduledDate,
    this.scheduledTime,
  });

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
          Text(
            value,
            style: isBold ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16) : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedServices = orderData['selectedServices'] as Map<String, int>;
    final dryCleaningItems = orderData['dryCleaningItems'] as List;
    final totalAmount = orderData['totalAmount'] as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Summary"),
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
            const Text(
              "Laundry Order Summary",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Order ID
            _buildDetailRow("Order ID:", customerOrder.id),
            const SizedBox(height: 10),

            // Selected Agent
            _buildDetailRow("Assigned Agent:", selectedAgent.displayName),
            const SizedBox(height: 10),

            // Service Type
            _buildDetailRow("Service Type:",
                serviceType == 'immediate' ? "Immediate Service" : "Scheduled Service"),

            if (scheduledDate != null && scheduledTime != null) ...[
              const SizedBox(height: 10),
              _buildDetailRow("Pickup Date:",
                  "${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}"),
              const SizedBox(height: 10),
              _buildDetailRow("Pickup Time:", scheduledTime!.format(context)),
            ],

            const SizedBox(height: 10),
            _buildDetailRow("Pickup Address:", address),
            const SizedBox(height: 10),
            _buildDetailRow("Phone:", phone),

            if (instructions.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildDetailRow("Instructions:", instructions),
            ],

            const SizedBox(height: 20),
            const Text(
              "Service Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Selected Services
            if (selectedServices.isNotEmpty) ...[
              ...selectedServices.entries.map((entry) =>
                  _buildDetailRow("${entry.key}:", "₦${entry.value}")
              ),
            ],

            // Dry Cleaning Items
            if (dryCleaningItems.isNotEmpty) ...[
              ...dryCleaningItems.where((item) => item["qty"] > 0).map((item) =>
                  _buildDetailRow("${item["title"]} (x${item["qty"]}):",
                      "₦${(item["price"] as int) * (item["qty"] as int)}")
              ),
            ],

            const Spacer(),

            // Payment Summary
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildPaymentRow("Subtotal:", "₦$totalAmount"),
                    _buildPaymentRow("Delivery Fee:", "₦1,000"),
                    const Divider(),
                    _buildPaymentRow("Total Amount:", "₦${totalAmount + 1000}", isBold: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Proceed to Payment Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PaymentScreen(
                      orderId: customerOrder.id,
                      amount: totalAmount + 1000,
                      agentId: selectedAgent.id,
                    )),
                  );
                },
                child: const Text(
                  "Proceed to Payment",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Home Cleaning Screen (Missing Implementation)
class HomeCleaningScreen extends StatefulWidget {
  const HomeCleaningScreen({super.key});

  @override
  State<HomeCleaningScreen> createState() => _HomeCleaningScreenState();
}

class _HomeCleaningScreenState extends State<HomeCleaningScreen> {
  int selectedHours = 1;
  int selectedProfessionals = 1;
  String? selectedCategory;

  final categories = [
    {"title": "Deep cleaning", "image": "assets/img_19.png"},
    {"title": "Move in cleaning", "image": "assets/img_20.png"},
    {"title": "Move out cleaning", "image": "assets/img_21.png"},
    {"title": "Office Cleaning", "image": "assets/img_22png"},
  ];

  double get totalAmount {
    return (2000 * selectedHours * selectedProfessionals).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Cleaning"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("How many hours do you need your professional to stay?",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: List.generate(
                7,
                    (index) {
                  final value = index + 1;
                  return ChoiceChip(
                    label: Text("$value"),
                    selected: selectedHours == value,
                    onSelected: (_) {
                      setState(() => selectedHours = value);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text("How many professional do you need?",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: List.generate(
                7,
                    (index) {
                  final value = index + 1;
                  return ChoiceChip(
                    label: Text("$value"),
                    selected: selectedProfessionals == value,
                    onSelected: (_) {
                      setState(() => selectedProfessionals = value);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text("Cleaning Categories",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = selectedCategory == cat["title"];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isSelected ? const Color(0xFF1B5E20).withOpacity(0.1) : null,
                    child: ListTile(
                      leading: Image.asset(cat["image"]!, width: 50),
                      title: Text(cat["title"]!),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF1B5E20)) : null,
                      onTap: () {
                        setState(() {
                          selectedCategory = cat["title"];
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: selectedCategory != null ? () {
                  _proceedToAgentSelection();
                } : null,
                child: const Text("Proceed to Agents",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToAgentSelection() {
    final orderData = {
      'serviceType': 'cleaning',
      'selectedHours': selectedHours,
      'selectedProfessionals': selectedProfessionals,
      'selectedCategory': selectedCategory,
      'hourlyRate': 2000,
      'subtotal': totalAmount,
      'totalAmount': totalAmount,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgentSelectionScreen(
          serviceType: 'cleaning',
          orderData: orderData,
          orderAmount: totalAmount,
          onAgentSelected: (agent, orderData) {
            // Handle home cleaning agent selection
            _navigateToHomeCleaningServiceType(agent, orderData);
          },
        ),
      ),
    );
  }

  void _navigateToHomeCleaningServiceType(Agent agent, Map<String, dynamic> orderData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HomeCleaningServiceTypeSelection(
          selectedAgent: agent,
          orderData: orderData,
        ),
      ),
    );
  }
}


//////////////////////////////
// HOME CLEANING SERVICE TYPE SELECTION (IMMEDIATE/SCHEDULED)
//////////////////////////////
class HomeCleaningServiceTypeSelection extends StatefulWidget {
  final Agent selectedAgent;
  final Map<String, dynamic> orderData;

  const HomeCleaningServiceTypeSelection({
    super.key,
    required this.selectedAgent,
    required this.orderData,
  });

  @override
  State<HomeCleaningServiceTypeSelection> createState() => _HomeCleaningServiceTypeSelectionState();
}

class _HomeCleaningServiceTypeSelectionState extends State<HomeCleaningServiceTypeSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Type"),
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
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: widget.selectedAgent.profileImage.isNotEmpty
                          ? NetworkImage('https://runpro9ja-backend.onrender.com${widget.selectedAgent.profileImage}')
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
                            '₦${widget.selectedAgent.price.toStringAsFixed(0)}/hr • ${widget.selectedAgent.distance.toStringAsFixed(1)} km away',
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
              "How would you like to schedule your cleaning service?",
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
                  _showHomeCleaningImmediateServiceOverlay(context);
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
                  "Schedule Appointment",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: const Text("Book for a specific date and time"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showHomeCleaningScheduledServiceOverlay(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHomeCleaningImmediateServiceOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => HomeCleaningImmediateServiceOverlay(
        selectedAgent: widget.selectedAgent,
        orderData: widget.orderData,
        serviceType: 'immediate',
      ),
    );
  }

  void _showHomeCleaningScheduledServiceOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => HomeCleaningScheduledServiceOverlay(
        selectedAgent: widget.selectedAgent,
        orderData: widget.orderData,
        serviceType: 'scheduled',
      ),
    );
  }
}
//////////////////////////////
// HOME CLEANING SCHEDULED SERVICE OVERLAY - FIXED VERSION
//////////////////////////////
class HomeCleaningScheduledServiceOverlay extends StatefulWidget {
  final Agent selectedAgent;
  final Map<String, dynamic> orderData;
  final String serviceType;

  const HomeCleaningScheduledServiceOverlay({
    super.key,
    required this.selectedAgent,
    required this.orderData,
    required this.serviceType,
  });

  @override
  State<HomeCleaningScheduledServiceOverlay> createState() => _HomeCleaningScheduledServiceOverlayState();
}

class _HomeCleaningScheduledServiceOverlayState extends State<HomeCleaningScheduledServiceOverlay> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final CustomerService _customerService = CustomerService(AuthService());

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool _isSubmitting = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
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
        selectedTime = picked;
        timeController.text = picked.format(context);
      });
    }
  }
//1
  Future<void> _createOrder() async {
    if (_isSubmitting || selectedDate == null || selectedTime == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // FIX: Use ServiceMapper to get the ObjectId for 'cleaning'
      final serviceCategory = ServiceMapper.getCategoryId('cleaning');
      if (serviceCategory == null) {
        throw Exception('No service category found for cleaning service');
      }

      final customerOrder = await _customerService.createProfessionalOrder(
        serviceCategory: serviceCategory, // Use the ObjectId from ServiceMapper
        details: _buildOrderDetails(),
        location: addressController.text,
        scheduledDate: selectedDate!.toIso8601String(),
        scheduledTime: selectedTime!.format(context),
        urgency: 'medium',
      );

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HomeCleaningOrderRecap(
          serviceType: widget.serviceType,
          selectedAgent: widget.selectedAgent,
          orderData: {
            ...widget.orderData,
            'address': addressController.text,
            'phone': phoneController.text,
            'instructions': instructionsController.text,
            'scheduledDate': selectedDate,
            'scheduledTime': selectedTime,
            'orderId': customerOrder.id,
          },
          customerOrder: customerOrder,
        )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating order: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String _buildOrderDetails() {
    final details = StringBuffer();
    details.writeln('Scheduled Home Cleaning Service Order Details:');
    details.writeln('Service Date: ${selectedDate!.toIso8601String()}');
    details.writeln('Service Time: ${selectedTime!.format(context)}');
    details.writeln('Cleaning Category: ${widget.orderData['selectedCategory']}');
    details.writeln('Hours: ${widget.orderData['selectedHours']} hours');
    details.writeln('Professionals: ${widget.orderData['selectedProfessionals']}');
    details.writeln('Hourly Rate: ₦2,000');

    if (instructionsController.text.isNotEmpty) {
      details.writeln('Special Instructions: ${instructionsController.text}');
    }

    details.writeln('Total Amount: ₦${widget.orderData['totalAmount']}');

    return details.toString();
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
            "Schedule Cleaning Service",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: addressController,
            decoration: const InputDecoration(
              labelText: "Service Address",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: "Phone Number",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 15),
          TextField(
            controller: dateController,
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
            controller: timeController,
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
            controller: instructionsController,
            decoration: const InputDecoration(
              labelText: "Special Instructions",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: (selectedDate != null && selectedTime != null && !_isSubmitting)
                  ? _createOrder
                  : null,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "Schedule Service",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////
// UPDATED HOME CLEANING ORDER RECAP SCREEN
//////////////////////////////
class HomeCleaningOrderRecap extends StatelessWidget {
  final String serviceType;
  final Agent selectedAgent;
  final Map<String, dynamic> orderData;
  final CustomerOrder customerOrder;

  const HomeCleaningOrderRecap({
    super.key,
    required this.serviceType,
    required this.selectedAgent,
    required this.orderData,
    required this.customerOrder,
  });

  Widget _buildPaymentRow(String label, String value, {bool isBold = false}) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: isBold ? const TextStyle(fontWeight: FontWeight.bold) : null,
            ),
            Text(
              value,
              style: isBold ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16) : null,
            ),
          ],
        )
    );
    }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(value),
            ),
          ],
        )
    );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Recap"),
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
            const Text(
              "Home Cleaning Order Summary",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Order ID
            _buildDetailRow("Order ID:", customerOrder.id),
            const SizedBox(height: 10),

            // Selected Agent
            _buildDetailRow("Assigned Agent:", selectedAgent.displayName),
            const SizedBox(height: 10),

            // Service Type
            _buildDetailRow("Service Type:",
                serviceType == 'immediate' ? "Immediate Service" : "Scheduled Service"),

            if (orderData['scheduledDate'] != null && orderData['scheduledTime'] != null) ...[
              const SizedBox(height: 10),
              _buildDetailRow("Service Date:",
                  "${orderData['scheduledDate'].day}/${orderData['scheduledDate'].month}/${orderData['scheduledDate'].year}"),
              const SizedBox(height: 10),
              _buildDetailRow("Service Time:", orderData['scheduledTime'].format(context)),
            ],

            const SizedBox(height: 10),
            _buildDetailRow("Service Address:", orderData['address'] ?? ''),
            const SizedBox(height: 10),
            _buildDetailRow("Phone:", orderData['phone'] ?? ''),

            if (orderData['instructions'] != null && orderData['instructions'].isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildDetailRow("Instructions:", orderData['instructions']),
            ],

            const SizedBox(height: 10),
            _buildDetailRow("Cleaning Category:", orderData['selectedCategory'] ?? ''),
            const SizedBox(height: 10),
            _buildDetailRow("Hours:", "${orderData['selectedHours']} hours"),
            const SizedBox(height: 10),
            _buildDetailRow("Professionals:", "${orderData['selectedProfessionals']} professionals"),

            const Spacer(),

            // Payment Summary
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildPaymentRow("Hourly Rate (₦2,000 × ${orderData['selectedHours']} hrs):",
                        "₦${2000 * orderData['selectedHours']}"),
                    _buildPaymentRow("Professionals (×${orderData['selectedProfessionals']}):",
                        "₦${orderData['totalAmount']}"),
                    const Divider(),
                    _buildPaymentRow("Total Amount:", "₦${orderData['totalAmount']}", isBold: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Proceed to Payment Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PaymentScreen(
                      orderId: customerOrder.id,
                      amount: orderData['totalAmount'],
                      agentId: selectedAgent.id,
                    )),
                  );
                },
                child: const Text(
                  "Proceed to Payment",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//////////////////////////////
// HOME CLEANING IMMEDIATE SERVICE OVERLAY - FIXED VERSION
//////////////////////////////
class HomeCleaningImmediateServiceOverlay extends StatefulWidget {
  final Agent selectedAgent;
  final Map<String, dynamic> orderData;
  final String serviceType;

  const HomeCleaningImmediateServiceOverlay({
    super.key,
    required this.selectedAgent,
    required this.orderData,
    required this.serviceType,
  });

  @override
  State<HomeCleaningImmediateServiceOverlay> createState() => _HomeCleaningImmediateServiceOverlayState();
}

class _HomeCleaningImmediateServiceOverlayState extends State<HomeCleaningImmediateServiceOverlay> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final CustomerService _customerService = CustomerService(AuthService());

  bool _isSubmitting = false;

  Future<void> _createOrder() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final serviceCategory = ServiceMapper.getCategoryId('cleaning');
      if (serviceCategory == null) {
        throw Exception('No service category found for cleaning service');
      }

      final customerOrderResponse = await _customerService.createProfessionalOrder(
        serviceCategory: serviceCategory,
        details: _buildOrderDetails(),
        location: addressController.text,
        urgency: 'high',
      );

      // Convert the Map response to CustomerOrder object using the new method
      final customerOrder = CustomerOrder.fromResponse(customerOrderResponse);

      if (customerOrder == null) {
        throw Exception('Could not create order from response: $customerOrderResponse');
      }

      print('✅ Order created successfully with ID: ${customerOrder.id}');

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HomeCleaningOrderRecap(
          serviceType: widget.serviceType,
          selectedAgent: widget.selectedAgent,
          orderData: {
            ...widget.orderData,
            'address': addressController.text,
            'phone': phoneController.text,
            'instructions': instructionsController.text,
            'orderId': customerOrder.id, // Now this will work
          },
          customerOrder: customerOrder, // This is now a CustomerOrder object
        )),
      );
    } catch (e) {
      print('❌ Error creating order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating order: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
  String _buildOrderDetails() {
    final details = StringBuffer();
    details.writeln('Immediate Home Cleaning Service Order Details:');
    details.writeln('Service Type: ${widget.serviceType}');
    details.writeln('Cleaning Category: ${widget.orderData['selectedCategory']}');
    details.writeln('Hours: ${widget.orderData['selectedHours']} hours');
    details.writeln('Professionals: ${widget.orderData['selectedProfessionals']}');
    details.writeln('Hourly Rate: ₦2,000');

    if (instructionsController.text.isNotEmpty) {
      details.writeln('Special Instructions: ${instructionsController.text}');
    }

    details.writeln('Total Amount: ₦${widget.orderData['totalAmount']}');

    return details.toString();
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
            "Immediate Cleaning Service",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: addressController,
            decoration: const InputDecoration(
              labelText: "Service Address",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(
              labelText: "Phone Number",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 15),
          TextField(
            controller: instructionsController,
            decoration: const InputDecoration(
              labelText: "Special Instructions",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          const Text(
            "Service Details:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text("• ${widget.orderData['selectedHours']} hours"),
          Text("• ${widget.orderData['selectedProfessionals']} professionals"),
          Text("• ${widget.orderData['selectedCategory']}"),
          const Text("• Service within 2 hours"),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: _isSubmitting ? null : _createOrder,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "Confirm Immediate Service",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}