import 'package:flutter/material.dart';

class ServiceHistoryScreen extends StatefulWidget {
  @override
  _ServiceHistoryScreenState createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  String selectedFilter = "All";

  // Dummy service history list
  final List<Map<String, String>> services = [
    {
      "title": "Errand service",
      "desc": "Package delivery at Utiblog",
      "date": "25/03/25 10:00am",
      "price": "₦12,000",
      "status": "Completed",
      "image": "https://via.placeholder.com/150"
    },
    {
      "title": "Babysitting service",
      "desc": "Package delivery at Utiblog",
      "date": "25/03/25 10:00am",
      "price": "₦12,000",
      "status": "Processing",
      "image": "https://via.placeholder.com/150"
    },
    {
      "title": "Errand service",
      "desc": "Package delivery at Utiblog",
      "date": "25/03/25 10:00am",
      "price": "₦12,000",
      "status": "Completed",
      "image": "https://via.placeholder.com/150"
    },
  ];

  void _showFilterOverlay() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption("All"),
              _buildFilterOption("Errand services"),
              _buildFilterOption("Babysitting Service"),
              _buildFilterOption("Laundry Service"),
              _buildFilterOption("Professional Service"),
              _buildFilterOption("Booking Service"),
              _buildFilterOption("Others"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String title) {
    return ListTile(
      title: Text(title),
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          padding: EdgeInsets.only(top: 8), // Added top padding to push content down
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4), // Added extra spacing
              Text("Search your Orders",
                  style: TextStyle(color: Colors.black, fontSize: 16)),
              SizedBox(height: 8), // Increased spacing
              GestureDetector(
                onTap: _showFilterOverlay,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Increased vertical padding
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(selectedFilter,
                            style: TextStyle(color: Colors.black)),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 8, right: 8), // Added padding to action icon
            child: IconButton(
              icon: Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text("Recent History ($selectedFilter)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),
          ...services
              .where((s) =>
          selectedFilter == "All" ||
              s["title"]!.contains(selectedFilter))
              .map((service) => _buildServiceCard(service))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, String> service) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                service["image"]!,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 50,
                    width: 50,
                    color: Colors.grey[300],
                    child: Icon(Icons.error_outline, color: Colors.grey[600]),
                  );
                },
              ),
            ),
            SizedBox(width: 12),

            // Main content - wrapped in Expanded to prevent overflow
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service["title"]!,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text(service["desc"]!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text(service["date"]!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text(service["price"]!,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            SizedBox(width: 8),

            // Status and action section
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 100), // Limit width
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: service["status"] == "Completed"
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(service["status"]!,
                      style: TextStyle(
                        color: service["status"] == "Completed"
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12, // Smaller font for status
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    // TODO: navigate to details page
                  },
                  child: Text("See More",
                      style: TextStyle(color: Colors.blue, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}