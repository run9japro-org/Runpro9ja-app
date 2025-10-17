import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/chat_screens/support_chat_screen.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: "How do I place an order?",
      answer: "To place an order:\n\n1. Select the service you need (errand, delivery, cleaning, etc.)\n2. Fill in the order details and requirements\n3. Set your location and preferred schedule\n4. Review the estimated price\n5. Confirm and submit your order\n\nAn available agent will accept your order shortly.",
    ),
    FAQItem(
      question: "How long does delivery take?",
      answer: "Delivery times vary based on:\n• Distance between pickup and drop-off locations\n• Traffic conditions\n• Order complexity\n• Agent availability\n\nTypically, deliveries within the same area take 30-90 minutes. You can track real-time progress in the Tracking section.",
    ),
    FAQItem(
      question: "How are prices determined?",
      answer: "Our pricing is based on:\n• Service type (errand, delivery, professional services)\n• Distance traveled\n• Time required\n• Service complexity\n• Urgency of request\n\nYou'll see an estimated price before confirming your order. Final pricing may be adjusted based on actual requirements.",
    ),
    FAQItem(
      question: "What if I need to cancel my order?",
      answer: "You can cancel orders depending on the status:\n\n• **Pending/Accepted**: Free cancellation\n• **In Progress**: Partial refund may apply\n• **Completed**: Cannot be canceled\n\nTo cancel, go to Tracking → Select your order → Cancel Order. Refunds are processed within 3-5 business days.",
    ),
    FAQItem(
      question: "How do I track my order in real-time?",
      answer: "To track your order:\n1. Go to the Tracking section in your profile\n2. Enter your order ID or select from recent orders\n3. View real-time location updates\n4. See order status and estimated completion time\n\nFor delivery orders, you can also view the agent's live location on the map.",
    ),
    FAQItem(
      question: "What payment methods do you accept?",
      answer: "We currently accept:\n• Credit/Debit cards (Visa, MasterCard, Verve)\n• Bank transfers\n• USSD payments\n• Digital wallets\n\nAll payments are secure and encrypted. You'll be charged after service completion unless otherwise specified.",
    ),
    FAQItem(
      question: "What areas do you serve?",
      answer: "We currently operate in:\n• Lagos Mainland & Island\n• Abuja\n• Port Harcourt\n• Ibadan\n• Other major cities\n\nService availability may vary by location. Enter your address to check if we serve your area.",
    ),
    FAQItem(
      question: "How do I become a service agent?",
      answer: "To join as a service agent:\n1. Download the RunPro 9ja Agent app\n2. Complete the registration form\n3. Provide required documents\n4. Pass background verification\n5. Complete training\n6. Start accepting orders\n\nRequirements: Valid ID, smartphone, and meeting our service standards.",
    ),
    FAQItem(
      question: "What if I'm not satisfied with the service?",
      answer: "We guarantee customer satisfaction:\n\n1. Contact support within 24 hours of service completion\n2. Provide details of your concern\n3. We'll investigate and work towards resolution\n4. Options may include refund, service redo, or credit\n\nYour feedback helps us maintain quality standards.",
    ),
    FAQItem(
      question: "How do I contact customer support?",
      answer: "You can reach us through:\n\n📞 **Phone**: 01-700-RUNPRO (786776)\n📧 **Email**: support@runpro9ja.com\n💬 **In-app Chat**: Help & Support section\n🕒 **Hours**: 7:00 AM - 10:00 PM daily\n\nWe typically respond within 30 minutes during business hours.",
    ),
    FAQItem(
      question: "Are my personal details secure?",
      answer: "Yes, we take privacy seriously:\n• All personal data is encrypted\n• We don't share your information with third parties\n• Payment details are securely processed\n• Location data is only used for service delivery\n• You can manage privacy settings in your profile",
    ),
    FAQItem(
      question: "What services do you offer?",
      answer: "We provide various on-demand services:\n\n🚚 **Delivery Services**: Package delivery, food delivery\n🛒 **Errand Services**: Grocery shopping, bill payments\n🧹 **Cleaning Services**: Home cleaning, office cleaning\n🔧 **Professional Services**: Plumbing, electrical, repairs\n🎉 **Personal Assistance**: Event planning, personal tasks\n\nCheck the services section for complete listings and pricing.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "FAQ & Help Center",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.help_outline,
                  size: 50,
                  color: const Color(0xFF2E7D32).withOpacity(0.7),
                ),
                const SizedBox(height: 10),
                const Text(
                  "How can we help you?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Find answers to frequently asked questions about our services",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

              ],
            ),
          ),

          // FAQ List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                return _buildFAQItem(_faqs[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.help_outline,
            color: const Color(0xFF2E7D32),
            size: 18,
          ),
        ),
        title: Text(
          faq.question,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faq.answer,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose your preferred contact method:'),
            SizedBox(height: 16),
            Text('📞 Phone: 01-700-RUNPRO'),
            Text('📧 Email: support@runpro9ja.com'),
            Text('🕒 Hours: 7AM - 10PM Daily'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement phone call
              _showComingSoon('Phone Call');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text('Call Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}