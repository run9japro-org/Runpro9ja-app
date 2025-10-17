import 'package:flutter/material.dart';

import '../../utils/service_mapper.dart';
import 'booking_form_screen.dart';

class ProfessionalServiceScreen extends StatelessWidget {
  const ProfessionalServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Professional Services'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
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
                      subtitle: "Skilled in installation, repairs and modification in pipe or water system",
                      serviceType: "plumbing",
                      subCategory: "Plumber",
                    ),
                    ServiceTile(
                      icon: Icons.electrical_services,
                      title: "Electrician",
                      subtitle: "Experts in electrical installations and repairs",
                      serviceType: "electrical",
                      subCategory: "Electrician",
                    ),
                    ServiceTile(
                      icon: Icons.settings,
                      title: "Mechanics",
                      subtitle: "Specialising in vehicle maintenance and repair",
                      serviceType: "mechanical",
                      subCategory: "Mechanic",
                    ),
                    ServiceTile(
                      icon: Icons.chair_alt,
                      title: "Furniture building",
                      subtitle: "Crafting custom pieces tailored to your needs",
                      serviceType: "carpentry",
                      subCategory: "Carpenter",
                    ),
                    ServiceTile(
                      icon: Icons.format_paint,
                      title: "Painters",
                      subtitle: "Deliver high-quality painting and finishing services",
                      serviceType: "painting",
                      subCategory: "Painter",
                    ),
                    ServiceTile(
                      icon: Icons.checkroom,
                      title: "Fashion designers",
                      subtitle: "Creating unique clothing and accessories",
                      serviceType: "fashion",
                      subCategory: "Fashion Designer",
                    ),
                    ServiceTile(
                      icon: Icons.spa,
                      title: "Beauticians",
                      subtitle: "Offering a variety of beauty treatments and services",
                      serviceType: "beauty",
                      subCategory: "Beautician",
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
  final String serviceType;
  final String subCategory;

  const ServiceTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.serviceType,
    required this.subCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          // Go directly to booking form to collect details first
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => // Wherever you navigate to ProfessionalBookingForm
              ProfessionalBookingForm(
                serviceType: serviceType, // e.g., 'plumbing'
                serviceName: title, // e.g., 'Professional Plumbing'
                subCategory: subCategory, // e.g., 'Pipe Installation'
                serviceCategoryId: ServiceMapper.getCategoryId(serviceType)!, // This now gets the actual MongoDB ID
              ),
            ),
          );
        },
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