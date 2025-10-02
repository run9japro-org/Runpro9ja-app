import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/babysitting_services/babysitting_service.dart';
import 'package:runpro_9ja/screens/hotel_booking_services/hotel_services.dart';
import 'package:runpro_9ja/screens/laundry_services/laundry_services.dart';
import 'package:runpro_9ja/screens/others_services/booking_services.dart';
import 'package:runpro_9ja/screens/professional_services/professional_services.dart';

import '../errand_services/order_detail_screen.dart';

class ServiceItem {
  final String title;
  final String asset;
  final Widget screen; // NEW: target screen
  const ServiceItem(this.title, this.asset, this.screen);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primaryGreen = Color(0xFF2E7D32);

  static final List<ServiceItem> _services = [
    ServiceItem('Errand service', 'assets/img_7.png', const ErrandServiceMenu()),
    ServiceItem('Babysitting', 'assets/img_8.png', const BabysittingApp()),
    ServiceItem('Professional service', 'assets/img_9.png', const ProfessionalServiceScreen()),
    ServiceItem('Hotel/accommodation bookings', 'assets/img_10.png',  HotelListScreen()),
    ServiceItem('Cleaning and Laundry services', 'assets/img_11.png', const LaundryServices()),
    ServiceItem('Personal assistance/others', 'assets/img_12.png', const OthersScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ✅ Green Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 90, 16, 40),
            decoration: const BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with profile + text
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage("assets/img_13.png"),
              ),
              const SizedBox(width: 11),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Welcome Mariam',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Lagos',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),

          // ✅ Search bar under header
          Column(
            children: [
              Center(
                child: Text(
                  "How can we assist you best?",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search category',
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    ),

          // ✅ Service grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: _services.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, i) {
                  final item = _services[i];
                  return _ServiceCard(
                    item: item,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => item.screen),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceItem item;
  final VoidCallback onTap;
  const _ServiceCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.asset(
                item.asset,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
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

// ------------------ PLACEHOLDER SCREENS ------------------





class HotelScreen extends StatelessWidget {
  const HotelScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Hotel/Accommodation")));
}

class CleaningScreen extends StatelessWidget {
  const CleaningScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Cleaning & Laundry")));
}


