// screens/support_screen.dart
import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/home_screens/faq_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/Auth_services/auth_service.dart';
import 'chat_screens/support_chat_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final AuthService _authService = AuthService();
  String? _authToken;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      _authToken = await _authService.getToken();
      final userData = await _authService.getUserData();
      if (userData != null) {
        _currentUserId = userData['id'] ?? userData['_id'] ?? 'current_user';
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showError("Could not open phone dialer");
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      query: Uri(queryParameters: {'subject': 'RunPro 9ja Support'}).query,
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showError("No email app found");
    }
  }

  Future<void> _launchSocial(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showError("Could not open link. Please make sure the app is installed.");
    }
  }

  // Specific social media launchers with proper URLs
  Future<void> _launchInstagram() async {
    await _launchSocial("https://www.instagram.com/runpro9ja");
  }

  Future<void> _launchTwitter() async {
    await _launchSocial("https://twitter.com/runpro9ja");
  }

  Future<void> _launchFacebook() async {
    await _launchSocial("https://www.facebook.com/profile.php?id=61582049373295");
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildSupportTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.green).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor ?? Colors.green),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        )
            : null,
        trailing: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.green,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Support Center",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green[700]!,
                    Colors.green[500]!,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "How can we help you?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Our support team is here to assist you",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Quick Help Section
            _buildSectionHeader('Quick Help'),
            _buildSupportTile(
              icon: Icons.chat_bubble_outline,
              title: "Live Chat Support",
              subtitle: "Chat with our support team in real-time",
              iconColor: Colors.blue,
              onTap: () {
                if (_authToken == null) {
                  _showLoginRequired();
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupportChatScreen(
                      authToken: _authToken!,
                      currentUserId: _currentUserId ?? 'current_user',
                    ),
                  ),
                );
              },
            ),

            _buildSupportTile(
              icon: Icons.help_outline,
              title: "FAQs & Help Center",
              subtitle: "Find answers to common questions",
              iconColor: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FAQScreen()),
                );
              },
            ),

            // Contact Section
            _buildSectionHeader('Contact Us'),
            _buildSupportTile(
              icon: Icons.phone,
              title: "Call Support",
              subtitle: "Speak directly with our team",
              iconColor: Colors.green,
              onTap: () => _showCallOptions(context),
            ),

            _buildSupportTile(
              icon: Icons.email,
              title: "Email Support",
              subtitle: "Send us an email",
              iconColor: Colors.red,
              onTap: () => _launchEmail("run9japro@gmail.com"),
            ),

            // Social Media Section - NOW WORKING!
            _buildSectionHeader('Follow Us'),
            _buildSupportTile(
              icon: Icons.camera_alt,
              title: "Instagram",
              subtitle: "@Runpro9ja",
              iconColor: Colors.pink,
              onTap: _launchInstagram,
            ),

            _buildSupportTile(
              icon: Icons.alternate_email,
              title: "Twitter",
              subtitle: "@runpro9ja",
              iconColor: Colors.blue,
              onTap: _launchTwitter,
            ),

            _buildSupportTile(
              icon: Icons.facebook,
              title: "Facebook",
              subtitle: "RunproNaija",
              iconColor: Colors.blue[800]!,
              onTap: _launchFacebook,
            ),

            // App Info
            _buildSectionHeader('App Information'),
            _buildSupportTile(
              icon: Icons.info_outline,
              title: "About RunPro 9ja",
              subtitle: "Version 1.0.0",
              iconColor: Colors.grey,
              onTap: () {
                _showAboutDialog(context);
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showCallOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Call Support",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildCallOption(
                context,
                phoneNumber: "08054835559",
                label: "Primary Support Line",
              ),
              const SizedBox(height: 12),
              _buildCallOption(
                context,
                phoneNumber: "07010936585",
                label: "Secondary Support Line",
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCallOption(BuildContext context, {required String phoneNumber, required String label}) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.phone, color: Colors.green),
        ),
        title: Text(
          phoneNumber,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(label),
        trailing: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.call,
            color: Colors.white,
            size: 20,
          ),
        ),
        onTap: () => _launchPhone(phoneNumber),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.green),
            SizedBox(width: 8),
            Text("About RunPro 9ja"),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "RunPro 9ja - Your trusted service marketplace",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text("Version: 1.0.0"),
            SizedBox(height: 8),
            Text("Build: 2024.01.01"),
            SizedBox(height: 12),
            Text(
              "Connecting customers with reliable service providers across Nigeria.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }


  void _showLoginRequired() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please login to access live chat support'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}