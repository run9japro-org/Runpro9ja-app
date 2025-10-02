import 'package:flutter/material.dart';

class HotelListScreen extends StatelessWidget {
  final List<String> hotels = List.generate(6, (_) => 'Sheraton Hotel');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booking Services')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search preferred destinations, hotel name, or accommodation',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: hotels.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/img_15.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(hotels[index], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.orange),
                        Text(' 5.0  •  '),
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        Text(' Ikeja, Lagos'),
                      ],
                    ),
                    trailing: Icon(Icons.favorite_border),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HotelDetailScreen()),
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class HotelDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              Image.asset('assets/img_16.png', height: 250, width: double.infinity, fit: BoxFit.cover),
              Positioned(
                left: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sheraton Hotel',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('12k Reviews', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  'Experience the epitome of luxury at the 5-star Sheraton hotel, perfectly situated in the heart of Lagos...',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Text("Popular Amenities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: [
                    Chip(avatar: Icon(Icons.pool, size: 18), label: Text('Pool')),
                    Chip(avatar: Icon(Icons.fitness_center, size: 18), label: Text('Gym')),
                    Chip(avatar: Icon(Icons.wifi, size: 18), label: Text('Free WiFi')),
                    Chip(avatar: Icon(Icons.restaurant, size: 18), label: Text('Restaurant')),
                  ],
                ),
                SizedBox(height: 20),
                Text("Room Types", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(child: Image.asset('assets/img_17.png', height: 120, fit: BoxFit.cover)),
                    SizedBox(width: 10),
                    Expanded(child: Image.asset('assets/img_18.png', height: 120, fit: BoxFit.cover)),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                  child: Text("Go to Booking Page"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookingScreen()),
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Image.asset('assets/img_16.jpg',
              height: 280, width: double.infinity, fit: BoxFit.cover),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Sheraton Hotel', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text('12k Reviews'),
              SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [Icon(Icons.location_on, size: 18), Text(' Ikeja, Lagos')]),
                  Row(children: [Icon(Icons.bed, size: 18), Text(' 3 Bedroom')]),
                  Row(children: [Icon(Icons.king_bed, size: 18), Text(' 3 Beds')]),
                  Row(children: [Icon(Icons.work, size: 18), Text(' Large working space')]),
                ],
              ),
              SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.wifi), Text(' WiFi'), SizedBox(width: 12),
                  Icon(Icons.balcony), Text(' Balcony view'), SizedBox(width: 12),
                  Icon(Icons.soap), Text(' Toiletries'),
                ],
              ),
              SizedBox(height: 20),

              Text(
                'Experience the epitome of luxury at the 5-star Sheraton hotel...',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),

              Text("Popular Amenities", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                children: [
                  Chip(label: Text('WiFi')),
                  Chip(label: Text('Balcony view')),
                  Chip(label: Text('Toiletries')),
                ],
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('₦60,000.00 / night', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                    onPressed: () {},
                    child: Text('Book Now'),
                  ),
                ],
              )
            ]),
          )
        ],
      ),
    );
  }
}
