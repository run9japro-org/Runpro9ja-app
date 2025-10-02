import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/payment_screens/payment_screen.dart';



class LaundryServices extends StatelessWidget {
  const LaundryServices({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cleaning Service',
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
// 1. Cleaning Service Screen
//////////////////////////////
class CleaningServiceScreen extends StatelessWidget {
  const CleaningServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = ["Home Cleaning", "Laundry Service"];

    return Scaffold(
      appBar: AppBar(leading: const Icon(Icons.arrow_back),
        title: const Text("Cleaning service"),),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(services[index]),
              onTap: () {
                if (services[index] == "Home Cleaning") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HomeCleaningScreen()),
                  );
                }
                if(services[index] == "Laundry Service"){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=> const Laundry()),);
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
// 2. Home Cleaning Screen
//////////////////////////////
class HomeCleaningScreen extends StatefulWidget {
  const HomeCleaningScreen({super.key});

  @override
  State<HomeCleaningScreen> createState() => _HomeCleaningScreenState();
}

class _HomeCleaningScreenState extends State<HomeCleaningScreen> {
  int selectedHours = 1;
  int selectedProfessionals = 1;

  final categories = [
    {"title": "Deep cleaning", "image": "assets/deep.png"},
    {"title": "Move in cleaning", "image": "assets/movein.png"},
    {"title": "Move out cleaning", "image": "assets/moveout.png"},
    {"title": "Office Cleaning", "image": "assets/office.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Cleaning")),
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
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Image.asset(cat["image"]!, width: 50),
                      title: Text(cat["title"]!),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfessionalsScreen()),
                        );
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProfessionalsScreen()),
                  );
                },
                child: const Text("Proceed",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////
// 3. Professionals Screen
//////////////////////////////
class ProfessionalsScreen extends StatelessWidget {
  const ProfessionalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final professionals = List.generate(6, (index) {
      return {
        "name": "Samuel Omisade",
        "reviews": "Recommended in your area",
        "image": "assets/pro.png"
      };
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Which professional do you prefer ?")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Top rated professionals in your area",
                style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: professionals.length,
                itemBuilder: (context, index) {
                  final p = professionals[index];
                  return Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(p["image"]!),
                        ),
                        const SizedBox(height: 8),
                        Text(p["name"]!,
                            style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                        Text(p["reviews"]!,
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20)),
                onPressed: () {
                  showImmediateServiceOverlay(context);
                },
                child: const Text("Book Immediate Service Request",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  showScheduledAppointmentOverlay(context);
                },
                child: const Text("Schedule Appointment"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////
// Scheduled Appointment Overlay
//////////////////////////////
void showScheduledAppointmentOverlay(BuildContext context) {
  final addressController = TextEditingController();
  final phoneController = TextEditingController(text: "09045678932");
  final fromTimeController = TextEditingController();
  final toTimeController = TextEditingController();
  final deliveryNoteController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Scheduled Appointments",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: "Address details",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: "Phone number",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Date",
                    border: OutlineInputBorder(),
                  ),
                  onTap: () async {
                    await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: fromTimeController,
                        decoration: const InputDecoration(
                          labelText: "From",
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            fromTimeController.text = time.format(context);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: toTimeController,
                        decoration: const InputDecoration(
                          labelText: "To",
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            toTimeController.text = time.format(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: deliveryNoteController,
                  decoration: const InputDecoration(
                    labelText: "What to deliver",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Payment Offer",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Hourly Rate: ₦2,000.00"),
                const Text("Requested time: ₦2,000.00 × 4"),
                const Text("Total: ₦8,000.00",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Scheduled appointment confirmed")),
                      );
                    },
                    child: const Text("Pay",
                        style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}

//////////////////////////////
// Immediate Service Overlay
//////////////////////////////
void showImmediateServiceOverlay(BuildContext context) {
  final phoneController = TextEditingController(text: "09045678932");
  final addressController = TextEditingController();
  final commentController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Immediate Service Request",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: "Phone number",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: "Address",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: "Comment",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Payment Offer",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Hourly Rate: ₦2,000.00"),
                const Text("Requested time: ₦2,000.00 × 4"),
                const Text("Total: ₦8,000.00",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Immediate request confirmed")),
                      );
                    },
                    child: const Text("Pay",
                        style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}



class Laundry extends StatelessWidget {
  const Laundry({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cleaning Service',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.green,
      ),
      home: const SelectServicesScreen(),
    );
  }
}

// ------------------ SCREEN 1 ------------------
class SelectServicesScreen extends StatelessWidget {
  const SelectServicesScreen({super.key});

  final List<Map<String, dynamic>> services = const [
    {
      "title": "Hand wash",
      "icon": Icons.wash,
    },
    {
      "title": "Washing machine wash",
      "icon": Icons.local_laundry_service,
    },
    {
      "title": "Iron only",
      "icon": Icons.iron,
    },
    {
      "title": "Wash, dry, and fold",
      "icon": Icons.local_laundry_service_outlined,
    },
    {
      "title": "Curtain, sheets & bulk items",
      "icon": Icons.inventory,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Select Services"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: Icon(service["icon"], size: 40, color: Colors.green),
                    title: Text(service["title"],
                        style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 17)),
                    trailing: const Text(
                      "Check Prices",
                      style: TextStyle(color: Colors.green , fontSize: 12),
                    ),
                    onTap: () {
                      // Open Categories Overlay
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => const CategoriesSheet(),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>const DryCleaningScreen()));
                },
                child: const Text(
                  "Proceed",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ------------------ SCREEN 2 ------------------
class CategoriesSheet extends StatelessWidget {
  const CategoriesSheet({super.key});

  final List<Map<String, String>> categories = const [
    {"title": "Shirts", "price": "₦1,000"},
    {"title": "Blouse", "price": "₦1,000"},
    {"title": "T-shirts", "price": "₦1,000"},
    {"title": "Tank tops", "price": "₦1,000"},
    {"title": "Crop tops", "price": "₦1,000"},
    {"title": "Sweaters", "price": "₦1,000"},
    {"title": "Hoodies", "price": "₦1,000"},
    {"title": "Jackets", "price": "₦1,000"},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text("Categories",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final item = categories[index];
                return ListTile(
                  leading: const Icon(Icons.check_box_outline_blank),
                  title: Text(item["title"]!),
                  trailing: Text(item["price"]!,
                      style: const TextStyle(color: Colors.black87)),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// ------------------ SCREEN 3 ------------------
class DryCleaningScreen extends StatefulWidget {
  const DryCleaningScreen({super.key});

  @override
  State<DryCleaningScreen> createState() => _DryCleaningScreenState();
}

class _DryCleaningScreenState extends State<DryCleaningScreen> {
  final List<Map<String, dynamic>> items = [
    {"title": "Shirts", "price": "₦1000 per shirt", "qty": 0},
    {"title": "Trousers", "price": "₦1000 per trouser", "qty": 0},
    {"title": "Duvet", "price": "₦1000 per duvet", "qty": 0},
    {"title": "Curtain", "price": "₦1000 per yard", "qty": 0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dry Cleaning")),
      body: Padding(
        padding: const EdgeInsets.all(19),
        child: Column(
          children: [
            Text("You can select from the different kinds of clothes you’d like us to wash for you."),
            SizedBox(height: 10,),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(items[i]["title"]),
                      subtitle: Text(items[i]["price"]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              setState(() {
                                if (items[i]["qty"] > 0) items[i]["qty"]--;
                              });
                            },
                          ),
                          Text("${items[i]["qty"]}"),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() {
                                items[i]["qty"]++;
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
            const TextField(
              decoration: InputDecoration(
                hintText: "Kindly specify if there’s anything you’d want us to look out for",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
                  );
                },
                child: const Text("Proceed", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ------------------ SCREEN 2 ------------------
class CreateOrderScreen extends StatelessWidget {
  const CreateOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Order")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text("Pickup Information"),
                subtitle: const Text("12/09/25\nBlock 6, Oyo Estate, Alakuko, Lagos."),
                trailing: const Icon(Icons.edit, color: Colors.green),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text("Delivery Information"),
                subtitle: const Text("12/09/25\nBlock 6, Oyo Estate, Alakuko, Lagos."),
                trailing: const Icon(Icons.edit, color: Colors.green),
                onTap: () {},
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderSummaryScreen()),
                  );
                },
                child: const Text("Continue", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ------------------ SCREEN 3 ------------------
class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Summary")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your Information",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text("Name: Jinadu Aswani\nAddress: Block 6, Oyo Estate, Alakuko Lagos\nPhone Number: 08012345678"),
            const Divider(height: 24),
            const Text("Payment",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ListTile(
              title: const Text("Laundry Fee"),
              trailing: const Text("₦10,000"),
            ),
            ListTile(
              title: const Text("Delivery Fee"),
              trailing: const Text("₦1,000"),
            ),
            const Divider(),
            ListTile(
              title: const Text("Total",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Text("₦11,000",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 24),
            const Text("Delivery Method",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text(
                "Drop-off: Block 6, Oyo Estate, Alakuko, Lagos\nClothes will be delivered 3 days after pickup."),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_)=> const PaymentApp()));
                },
                child: const Text("Proceed to Pay", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
