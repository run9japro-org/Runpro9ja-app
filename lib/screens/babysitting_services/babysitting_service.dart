import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/payment_screens/payment_screen.dart';


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
        leading: const Icon(Icons.arrow_back),
        title: const Text("Babysitting Service"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FilterScreen()));
              },
              child: const Text("Child babysitting"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.grey),
              ),
              onPressed: () {},
              child: const Text("Animal Babysitting"),
            ),
          ],
        ),
      ),
    );
  }
}

/// 2. Filter Screen
class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        title: const Text("Filter Search by"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const TextField(decoration: InputDecoration(labelText: "Distance (km from me)")),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: TextField(decoration: InputDecoration(labelText: "Price/hr from"))),
                SizedBox(width: 10),
                Expanded(child: TextField(decoration: InputDecoration(labelText: "to"))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: TextField(decoration: InputDecoration(labelText: "Timeframe from"))),
                SizedBox(width: 10),
                Expanded(child: TextField(decoration: InputDecoration(labelText: "to"))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (index) => const Icon(Icons.star_border, color: Colors.amber)),
            ),
            const SizedBox(height: 12),
            const Text("Experience"),
            RadioListTile(value: 1, groupValue: 0, onChanged: (_) {}, title: const Text("Less than a year")),
            RadioListTile(value: 2, groupValue: 0, onChanged: (_) {}, title: const Text("1 to 3 years")),
            RadioListTile(value: 3, groupValue: 0, onChanged: (_) {}, title: const Text("3 to 5 years")),
            const SizedBox(height: 12),
            const Text("Age Range"),
            RadioListTile(value: 1, groupValue: 0, onChanged: (_) {}, title: const Text("24 to 30 years")),
            RadioListTile(value: 2, groupValue: 0, onChanged: (_) {}, title: const Text("30 to 45 years")),
            RadioListTile(value: 3, groupValue: 0, onChanged: (_) {}, title: const Text("45 and above")),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BabysitterListScreen()));
              },
              child: const Text("Find a Babysitter"),
            )
          ],
        ),
      ),
    );
  }
}

/// 3. Babysitter List Screen
class BabysitterListScreen extends StatelessWidget {
  const BabysitterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recommended Trusted Babysitters near you")),
      body: ListView.builder(
        itemCount: 6,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundImage: AssetImage("assets/profile.jpg")),
              title: const Text("Tosin Ajayi"),
              subtitle: Row(
                children: const [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  SizedBox(width: 4),
                  Text("24 reviews"),
                ],
              ),
              trailing: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BabysitterDetailScreen()));
                },
                child: const Text("View"),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 4. Babysitter Detail Screen
class BabysitterDetailScreen extends StatelessWidget {
  const BabysitterDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.green,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: const [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage("assets/profile.jpg"),
                ),
                SizedBox(height: 8),
                Text("Tosin Ajayi", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Babysitter in Lagos", style: TextStyle(color: Colors.white70)),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("Age 32", style: TextStyle(color: Colors.white)),
                    Text("~40km", style: TextStyle(color: Colors.white)),
                    Text("#4,000/hr", style: TextStyle(color: Colors.white)),
                    Text("2-8hrs", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: const [
                  Text("22 reviews", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                      "I love working with children. All I ever want is to care for them as if they were my own..."
                  ),
                  SizedBox(height: 16),
                  Text("Characteristics", style: TextStyle(fontWeight: FontWeight.bold)),
                  ListTile(leading: Icon(Icons.check), title: Text("Good English")),
                  ListTile(leading: Icon(Icons.check), title: Text("Work with kids with down syndrome")),
                  ListTile(leading: Icon(Icons.check), title: Text("Knowledge of first aid")),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingDetailsScreen()));
              },
              child: const Text("Book Now"),
            ),
          )
        ],
      ),
    );
  }
}

/// 5. Booking Details Screen
class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ageController = TextEditingController();
    final TextEditingController needsController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController startTimeController = TextEditingController();
    final TextEditingController endTimeController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        title: const Text("Booking Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Booking Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            const Align(alignment: Alignment.centerRight, child: Text("Babysitting service")),
            const SizedBox(height: 16),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Child's Name")),
            TextField(controller: ageController, decoration: const InputDecoration(labelText: "Age")),
            TextField(controller: needsController, decoration: const InputDecoration(labelText: "Special Needs (if any)")),
            TextField(controller: dateController, decoration: const InputDecoration(labelText: "Date")),
            Row(
              children: [
                Expanded(child: TextField(controller: startTimeController, decoration: const InputDecoration(labelText: "Start Time"))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: endTimeController, decoration: const InputDecoration(labelText: "End Time"))),
              ],
            ),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: "Address")),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Notes"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingSummaryScreen()),
                );
              },
              child: const Text("Confirm Booking"),
            )
          ],
        ),
      ),
    );
  }
}

/// 6. Booking Summary Screen
class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        title: const Text("Booking Summary"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Babysitter's Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 10),
                  Text("Name: Kanayo Kanayo"),
                  Text("Location: Fola Agoro, Bariga, Lagos"),
                  Text("Hourly rate: ₦1500/hr"),
                  Text("Total cost: ₦13,000.00"),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentApp()),
              );
              },
              child: const Text("Proceed to Payment"),
            )
          ],
        ),
      ),
    );
  }
}
