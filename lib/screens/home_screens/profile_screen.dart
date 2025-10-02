import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/saved_address_screen.dart';
import 'package:runpro_9ja/screens/tracking_order_screen.dart';

import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Profile header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration:  BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),

            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage("assets/img_13.png"), // replace with NetworkImage if needed
                ),
                const SizedBox(height: 8),
                const Text(
                  "Mariam Hussein",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // Profile options
          Expanded(
            child: ListView(
              children: [

                SizedBox(height: 9,),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.green),
                  title: const Text("Edit Profile"),
                  trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
                    }

                ),
                SizedBox(height: 5,),
                ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.green),
                  title: const Text("Tracking information"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  TrackingPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.green),
                  title: const Text("Saved addresses"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SavedAddressScreen()
                    ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.green),
                  title: const Text("Notification"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.green),
                  title: const Text("Log out"),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.green),
                  title: const Text("Privacy and Cancellation Policy"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
