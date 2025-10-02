import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/payment_screens/payment_screen.dart';

/// ---------------- BOOKING FORM SCREEN ----------------
class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details", style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Booking Information",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),

              const SizedBox(height: 16),
              _buildInfoTile("Service", "Plumbing Services"),

              const SizedBox(height: 16),
              _buildTextField("Date", _dateController),
              _buildTextField("Time", _timeController),
              _buildTextField("Address", _addressController),

              const SizedBox(height: 16),
              _buildTextField(
                "Mr Wale, my kitchen sink is clogged and the toilet flushing control has stopped working. Can you please come prepared to see a dirty toilet that has refused to flush and a dirty clogged toilet. Come prepared.",
                _notesController,
                maxLines: 4,
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingSummaryScreen(
                          date: _dateController.text,
                          time: _timeController.text,
                          address: _addressController.text,
                          notes: _notesController.text,
                        ),
                      ),
                    );
                  }
                },
                child: const Text("Confirm Booking",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) =>
        value == null || value.isEmpty ? "Please enter this field" : null,
        decoration: InputDecoration(
          hintText: hint, // 👈 put text inside field like the design
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}

/// ---------------- BOOKING SUMMARY SCREEN ----------------
class BookingSummaryScreen extends StatelessWidget {
  final String date;
  final String time;
  final String address;
  final String notes;

  const BookingSummaryScreen({
    super.key,
    required this.date,
    required this.time,
    required this.address,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Details", style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("Booking Information",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),

            const SizedBox(height: 16),
            _buildInfoTile("Service", "Plumbing Services"),
            _buildInfoTile("Date", "$date, $time"),
            _buildInfoTile("Booking ID", "097668"),
            _buildInfoTile("Address", address),

            const SizedBox(height: 16),
            const Text("Notes", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(notes,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),

            const SizedBox(height: 24),
            const Text("Service Provider Information",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),

            const SizedBox(height: 12),
            _buildInfoTile("Name", "Wale Jubril"),
            _buildInfoTile("Location", "Fola Agoro, Bariga, Lagos"),
            _buildInfoTile("Rating", "4.8"),
            _buildInfoTile("Payment offer", "₦1500/hr"),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.chat, color: Colors.green),
                  label: const Text("Chat serviceman"),
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    foregroundColor: Colors.green,
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.call, color: Colors.green),
                  label: const Text("Call Service man"),
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green),
                    foregroundColor: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentOptionScreen()

                  ),
                );
              },
              child: const Text("Proceed to pay",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Flexible(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
