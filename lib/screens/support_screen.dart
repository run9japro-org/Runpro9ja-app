import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/livechat_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  Widget _buildSupportTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Live Chat
          _buildSupportTile(
            icon: Icons.chat,
            title: "Live chat",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LiveChatPage()),
              );
            },
          ),
          const Divider(),

          // Phone Numbers
          _buildSupportTile(
            icon: Icons.phone,
            title: "08056478567",
          ),
          _buildSupportTile(
            icon: Icons.phone,
            title: "08056478567",
          ),
          const Divider(),

          // Instagram
          _buildSupportTile(
            icon: Icons.camera_alt,
            title: "@runpro9ja_official",
          ),
          // Twitter
          _buildSupportTile(
            icon: Icons.alternate_email,
            title: "@runpro9ja_help",
          ),
          // Facebook
          _buildSupportTile(
            icon: Icons.facebook,
            title: "Runpro9ja",
          ),
          const Divider(),

          // Email
          _buildSupportTile(
            icon: Icons.email,
            title: "Contactcenter@runpro9ja.com",
          ),
        ],
      ),

    );
  }
}
