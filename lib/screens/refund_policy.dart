import 'package:flutter/material.dart';

class RefundPolicyScreen extends StatelessWidget {
  const RefundPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Refund Policy"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "At RUNPRO 9ja, we strive to deliver exceptional errand and professional service tailored to meet your needs. Your satisfaction is our priority; this refund policy outlines the circumstances under which refunds may be granted and the process for requesting them.",
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            SizedBox(height: 20),

            Text("1. Eligibility for Refund:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              "• Service not Rendered: If a scheduled service was not delivered due to fault or negligence on our part.\n• Service Cancellation: If a customer cancels a prepaid service at least (12 hours) before the scheduled time.\n• Unsatisfactory Service: If you are dissatisfied with a complete service due to poor quality or failure to meet agreed-upon standards, a review and resolution cannot be appealed again.",
            ),
            SizedBox(height: 20),

            Text("2. Non-Refundable Circumstances:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              "Refunds will not be issued under the following circumstances:\n• Late cancellations: Cancelled less than (6 hours) before service time.\n• Completed Services: If the service has been fully rendered and approved by client completion time or signature.\n• Damages or theft: Outside the terms of our policy or negligence of purchasers.\n• Offers, discounts, and non-refundable bundles are final.",
            ),
            SizedBox(height: 20),

            Text("3. How to Request a Refund:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              "To request a refund, please contact within (24 hours) of the incident via the following information:\n• Order number and date of service\n• Full name and phone number\n• Reason for the refund request\n• Any relevant documentation (receipts, photos, etc.)\nContact email: support@runpro9ja.com\nContact number: +234-XXX-XXX-XXXX",
            ),
            SizedBox(height: 20),

            Text("4. Processing Time:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              "Refund requests will be reviewed within (24 hours). If approved, refunds will be processed to the original payment method within (3–5 business days).",
            ),
            SizedBox(height: 20),

            Text("5. Policy Updates:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              "Runpro 9ja reserves the right to update this refund policy at any time. Updates will be posted on our mobile app and website, and continued use of our platform indicates acceptance of these changes.",
            ),
          ],
        ),
      ),
    );
  }
}
