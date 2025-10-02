import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const PaymentApp());
}

class PaymentApp extends StatelessWidget {
  const PaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E8B6D)),
      ),
      home: const PaymentOptionScreen(),
    );
  }
}

class PaymentOptionScreen extends StatefulWidget {
  const PaymentOptionScreen({super.key});

  @override
  State<PaymentOptionScreen> createState() => _PaymentOptionScreenState();
}

class _PaymentOptionScreenState extends State<PaymentOptionScreen> {
  String? selectedOption;

  // Card controllers
  final TextEditingController nameController =
  TextEditingController(text: "Mariam Hussein");
  final TextEditingController cardController =
  TextEditingController(text: "**** **** **** 6754");
  final TextEditingController expiryController =
  TextEditingController(text: "02/26");
  final TextEditingController cvvController =
  TextEditingController(text: "***");

  bool saveCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Option"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Payment Options
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  RadioListTile(
                    value: "card",
                    groupValue: selectedOption,
                    onChanged: (val) {
                      setState(() {
                        selectedOption = val.toString();
                      });
                    },
                    title: const Text("Credit/Debit Card"),
                    secondary:
                    const Icon(Icons.credit_card, color: Color(0xFF2E8B6D)),
                  ),
                  const Divider(height: 1),
                  RadioListTile(
                    value: "bank",
                    groupValue: selectedOption,
                    onChanged: (val) {
                      setState(() {
                        selectedOption = val.toString();
                      });
                    },
                    title: const Text("Bank Transfer"),
                    secondary: const Icon(Icons.account_balance,
                        color: Color(0xFF2E8B6D)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ================= CARD FORM =================
            if (selectedOption == "card") ...[
              const Text(
                "Enter Card Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Card Holder's Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: cardController,
                decoration: const InputDecoration(
                  labelText: "Card Number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expiryController,
                      decoration: const InputDecoration(
                        labelText: "Expiry Date",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: cvvController,
                      decoration: const InputDecoration(
                        labelText: "CVV/CVC",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Checkbox(
                    value: saveCard,
                    activeColor: const Color(0xFF2E8B6D),
                    onChanged: (val) {
                      setState(() {
                        saveCard = val ?? false;
                      });
                    },
                  ),
                  const Text("Save card information for next time"),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E8B6D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SuccessScreen()),
                    );
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],

            // ================= BANK TRANSFER =================
            if (selectedOption == "bank") ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Bank Transfer Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDetailRow("Bank Name", "Stanbic IBTC Bank"),
                    const Divider(),
                    buildDetailRow("Account Name", "Runpro9ja"),
                    const Divider(),
                    buildDetailRow("Account Number", "78840984356"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Copy Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: "78840984356"));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Account number copied!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Copy Account Number",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E8B6D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SuccessScreen()),
                    );
                  },
                  child: const Text(
                    "I Have Made Payment",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 15),
              const Text(
                "After sending money, your payment will be verified automatically within a few minutes.",
                style: TextStyle(color: Colors.black54, fontSize: 14),
                textAlign: TextAlign.start,
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(
              value,
              style:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= SUCCESS SCREEN =================
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFE5F6EC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E8B6D),
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Payment Successful !",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Yay !! Your item is on its way",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E8B6D),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text("Back to Home"),
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: () {},
                child: const Text(
                  "View Receipt",
                  style: TextStyle(color: Color(0xFF2E8B6D)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
