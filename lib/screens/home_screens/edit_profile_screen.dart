import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: () {
              // Save changes
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile image
              Center(
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: AssetImage("assets/img_13.png"),
                ),
              ),
              const SizedBox(height: 25),

              // Name
              buildTextField("Name", "Mariam Hussein"),
              const SizedBox(height: 12),

              // Date of Birth
              buildTextField("Date of Birth", "19/10/2024"),
              const SizedBox(height: 12),

              // Location
              buildTextField(
                  "Location", "No 12, Adekunle street, Yaba Lagos"),
              const SizedBox(height: 12),

              // Phone Number
              buildTextField("Phone Number", "0812045768945"),
              const SizedBox(height: 12),

              // Email Address
              buildTextField("E-mail Address",
                  "MariamHussein419@gmail.com"),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
          const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          decoration: InputDecoration(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.green),
            ),
          ),
        ),
      ],
    );
  }
}
