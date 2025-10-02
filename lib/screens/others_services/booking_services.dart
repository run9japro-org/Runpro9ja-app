import 'package:flutter/material.dart';

class OthersScreen extends StatelessWidget {
  const OthersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Booking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1B5E20),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AllServicesScreen(),
    );
  }
}

//////////////////////////////
// 1. All Services Screen
//////////////////////////////
class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All services")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text("Personal Assistance"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoryScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

//////////////////////////////
// 2. Category Screen
//////////////////////////////
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

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
      appBar: AppBar(title: const Text("Category")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories
                  .map(
                    (cat) => OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                          const RecommendedAssistantsScreen()),
                    );
                  },
                  child: Text(cat),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text("Notes",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                "Input any specification you may require of the individual...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////
// 3. Recommended Assistants Screen
//////////////////////////////
class RecommendedAssistantsScreen extends StatelessWidget {
  const RecommendedAssistantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assistants = [
      {
        "name": "Tosin Ajayi",
        "reviews": "13 reviews",
        "image": "assets/tosin.png"
      },
      {
        "name": "Uju Okafor",
        "reviews": "22 reviews",
        "image": "assets/uju.png"
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Recommended Personal Assistance")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assistants.length,
        itemBuilder: (context, index) {
          final a = assistants[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(a["image"]!),
              ),
              title: Text(a["name"]!),
              subtitle: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(a["reviews"]!),
                ],
              ),
              trailing: TextButton(
                onPressed: () {
                  // Navigate to profile
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(
                        name: a["name"]!,
                        image: a["image"]!,
                        reviews: a["reviews"]!,
                      ),
                    ),
                  );
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

//////////////////////////////
// 4. Profile / Booking Preview Screen
//////////////////////////////
class ProfileScreen extends StatelessWidget {
  final String name;
  final String image;
  final String reviews;

  const ProfileScreen(
      {super.key,
        required this.name,
        required this.image,
        required this.reviews});

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
              backgroundImage: AssetImage(image),
            ),
            const SizedBox(height: 10),
            Text(name,
                style: const TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                InfoCard(title: "Age", value: "32"),
                InfoCard(title: "Distance", value: "~40km"),
                InfoCard(title: "Hourly Rate", value: "₦4,000/hr"),
                InfoCard(title: "Time Availability", value: "2-8hrs"),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 5),
                      Text(reviews,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 10),
                    const Text(
                      "I am a professional lady with six years experience in physical and virtual assistance...",
                      style: TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    const Text("Characteristics",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 5),
                    const Text(
                      "• Professional\n• Quick to adapt\n• Good time management\n• Self-motivated",
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const BookingDetailsScreen()),
                          );
                        },
                        child: const Text("Book Now",
                            style: TextStyle(color: Colors.white)),
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
// InfoCard widget
//////////////////////////////
class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

//////////////////////////////
// 5. Booking Details Screen
//////////////////////////////
class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Client’s Information",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            TextField(decoration: const InputDecoration(labelText: "Client’s Name")),
            TextField(decoration: const InputDecoration(labelText: "Location")),
            TextField(decoration: const InputDecoration(labelText: "Organisation Name (if any)")),
            TextField(decoration: const InputDecoration(labelText: "Specific Role")),
            TextField(decoration: const InputDecoration(labelText: "Date")),
            Row(
              children: [
                Expanded(
                    child: TextField(decoration: const InputDecoration(labelText: "Start Time"))),
                const SizedBox(width: 10),
                Expanded(
                    child: TextField(decoration: const InputDecoration(labelText: "End Time"))),
              ],
            ),
            TextField(decoration: const InputDecoration(labelText: "Address")),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BookingSummaryScreen()),
                );
              },
              child: const Text("Verify Information",
                  style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}

//////////////////////////////
// 6. Booking Summary Screen
//////////////////////////////
class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Name: Uju Okafor"),
            const Text("Location: Fola Agoro, Bariga, Lagos"),
            const Text("Job Title: Proxy Site Contractor"),
            const Text("Daily Rate: ₦1500/hr"),
            const Text("Contract Duration: 1 month"),
            const Text("Total Cost: ₦130,000.00",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20)),
                onPressed: () {},
                child: const Text("Proceed to Payment",
                    style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
