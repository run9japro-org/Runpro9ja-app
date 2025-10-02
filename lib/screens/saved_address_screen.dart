import 'package:flutter/material.dart';

class SavedAddressScreen extends StatelessWidget {
  const SavedAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample addresses
    final addresses = [
      "16, New Hall Unilag, off campus road, Akoka",
      "16, New Hall Unilag, off campus road, Akoka",
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Saved Address",
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: addresses.length + 1, // +1 for "Add new address"
        separatorBuilder: (context, index) => const Divider(height: 24, color: Colors.grey),
        itemBuilder: (context, index) {
          if (index < addresses.length) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    addresses[index],
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.green),
                  onPressed: () {
                    // TODO: handle edit address
                  },
                ),
              ],
            );
          } else {
            // Add new address row
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add new address",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.green),
                  onPressed: () {
                    // TODO: handle add new address
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
