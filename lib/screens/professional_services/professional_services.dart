import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/professional_services/booking_form_screen.dart';



// -------------------- SCREEN 1 --------------------
class ProfessionalServiceScreen extends StatelessWidget {
  const ProfessionalServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: "Search services by name",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.green[50],
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Intro Text
              const Text(
                "Our professional services encompasses a diverse range of skilled trades, including:",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Service List
              Expanded(
                child: ListView(
                  children: [
                    ServiceTile(
                      icon: Icons.plumbing,
                      title: "Plumber",
                      subtitle:
                      "Skilled in installation, repairs and modification in pipe or water system",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchResultsScreen(),
                          ),
                        );
                      },
                    ),
                    ServiceTile(
                      icon: Icons.electrical_services,
                      title: "Electrician",
                      subtitle: "Experts in electrical installations and repairs",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchResultsScreen(),
                          ),
                        );
                      },
                    ),
                    ServiceTile(
                      icon: Icons.settings,
                      title: "Mechanics",
                      subtitle: "Specialising in vehicle maintenance and repair",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchResultsScreen(),
                          ),
                        );
                      },
                    ),
                    ServiceTile(
                      icon: Icons.chair_alt,
                      title: "Furniture building",
                      subtitle: "Crafting custom pieces tailored to your needs",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchResultsScreen(),
                          ),
                        );
                      },
                    ),
                    ServiceTile(
                      icon: Icons.format_paint,
                      title: "Painters",
                      subtitle:
                      "Deliver high-quality painting and finishing services",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchResultsScreen(),
                          ),
                        );
                      },
                    ),
                    ServiceTile(
                      icon: Icons.checkroom,
                      title: "Fashion designers",
                      subtitle: "Creating unique clothing and accessories",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchResultsScreen(),
                          ),
                        );
                      },
                    ),
                    ServiceTile(
                      icon: Icons.spa,
                      title: "Beauticians",
                      subtitle:
                      "Offering a variety of beauty treatments and services",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchResultsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ServiceTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(icon, color: Colors.green[700]),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 16, color: Colors.grey),
      ),
    );
  }
}

// -------------------- SCREEN 2 --------------------
class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  static const Color primaryGreen = Color(0xFF2E7D32);

  final List<Map<String, dynamic>> professionals = const [
    {
      'name': 'Samuel Adifala',
      'experience': 'Over 8 years experience',
      'price': '₦1500/hr',
      'rating': '4.8',
      'reviews': '54 Ratings',
      'distance': '500m away',
      'image': 'https://i.pravatar.cc/150?img=1',
    },
    {
      'name': 'Sarah Johnson',
      'experience': '5 years experience',
      'price': '₦2000/hr',
      'rating': '4.6',
      'reviews': '34 Ratings',
      'distance': '1km away',
      'image': 'https://i.pravatar.cc/150?img=2',
    },
    {
      'name': 'Michael Smith',
      'experience': '10 years experience',
      'price': '₦2500/hr',
      'rating': '4.9',
      'reviews': '80 Ratings',
      'distance': '2km away',
      'image': 'https://i.pravatar.cc/150?img=3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: const Text(
          "Search Result (6)",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: professionals.length,
        itemBuilder: (context, index) {
          final professional = professionals[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(professional['image']),
                  ),
                  const SizedBox(width: 12),

                  // Professional Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          professional['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          professional['experience'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              professional['price'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 16),
                                    const SizedBox(width: 2),
                                    Text(
                                      professional['rating'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      professional['reviews'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  professional['distance'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(context,MaterialPageRoute(
                                builder: (_) => const BookingFormScreen(),
                              ),
                              );
                            },
                            child: const Text("Book Now",style: TextStyle(color: Colors.white),),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
