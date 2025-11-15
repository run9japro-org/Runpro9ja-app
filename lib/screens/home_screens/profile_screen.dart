import 'package:flutter/material.dart';
import 'package:runpro_9ja/auth/Auth_services/auth_service.dart';
import 'package:runpro_9ja/screens/chat_screens/support_chat_screen.dart';
import 'package:runpro_9ja/screens/refund_policy.dart';
import 'package:runpro_9ja/screens/saved_address_screen.dart';
import 'package:runpro_9ja/screens/termsandcondition.dart';
import 'package:runpro_9ja/screens/tracking_order_screen.dart';
import '../../models/customer_models.dart';
import '../../services/customer_services.dart';
import 'edit_profile_screen.dart';
import 'faq_screen.dart';
import 'notification_screen.dart';
import '../payment_screens/payment_method_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final CustomerService _customerService = CustomerService(AuthService());
  CustomerProfile? _userProfile;
  List<CustomerOrder> _customerOrders = [];
  bool _isLoading = true;
  bool _ordersLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadCustomerOrders();
  }

  Future<void> _loadCustomerOrders() async {
    try {
      setState(() {
        _ordersLoading = true;
      });
      final dynamic orders = await _customerService.getCustomerOrders();

      print('🔍 Orders loaded: ${orders.length} orders');

      if (mounted) {
        setState(() {
          _customerOrders = orders;
          _ordersLoading = false;
        });
      }

      // Print order IDs for debugging
      for (var order in orders) {
        print('📦 Order ID: ${order.id}, Status: ${order.status}');
      }

    } catch (e) {
      print('❌ Error loading orders: $e');
      if (mounted) {
        setState(() {
          _ordersLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final CustomerProfile profile = await _customerService.getCustomerProfile();

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }

      print('✅ Profile loaded: ${profile.fullName}');

    } catch (e) {
      print('❌ Error loading profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ADD DELETE ACCOUNT METHOD
  Future<void> _deleteAccount() async {
    final bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Account',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This action cannot be undone. All your data will be permanently deleted.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'To confirm, please type:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'DELETE MY ACCOUNT',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Type the confirmation phrase',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // We'll handle validation in the button
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Continue', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      // Show password confirmation dialog
      await _showPasswordConfirmationDialog();
    }
  }

  // ADD PASSWORD CONFIRMATION DIALOG
  Future<void> _showPasswordConfirmationDialog() async {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmationController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Deletion',
            style: TextStyle(color: Colors.red),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please enter your password to confirm account deletion:'),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmationController,
                decoration: const InputDecoration(
                  labelText: 'Type "DELETE MY ACCOUNT"',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (confirmationController.text != 'DELETE MY ACCOUNT') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please type "DELETE MY ACCOUNT" to confirm')),
                  );
                  return;
                }

                if (passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter your password')),
                  );
                  return;
                }

                Navigator.of(context).pop();
                await _performAccountDeletion(
                  passwordController.text,
                  confirmationController.text,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Account', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ADD ACTUAL DELETION METHOD
  Future<void> _performAccountDeletion(String password, String confirmation) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Use AuthService to delete account
      final authService = AuthService();
      final response = await authService.delete('api/customers/me', {
        'password': password,
        'confirmation': confirmation,
      });

      Navigator.of(context).pop(); // Close loading dialog

      if (response['statusCode'] == 200) {
        // Account deleted successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );

        // Logout and navigate to login
        await authService.logout();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        throw Exception(response['body']['message'] ?? 'Failed to delete account');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account: $e')),
      );
    }
  }

  // Get recent order IDs for tracking
  List<String> getRecentOrderIds() {
    return _customerOrders
        .where((order) => order.id.isNotEmpty && _isActiveOrder(order.status))
        .map((order) => order.id)
        .toList();
  }

  // Check if order is active/trackable
  bool _isActiveOrder(String status) {
    final activeStatuses = [
      'requested', 'accepted', 'in-progress', 'agent_selected',
      'quotation_accepted', 'pending_agent_response', 'public',
      'quotation_provided', 'inspection_scheduled', 'inspection_completed'
    ];
    return activeStatuses.contains(status.toLowerCase());
  }

  // Get completed orders
  List<CustomerOrder> getCompletedOrders() {
    return _customerOrders
        .where((order) => order.status.toLowerCase() == 'completed')
        .toList();
  }

  // Enhanced tracking navigation with order data
  void _navigateToTracking() {
    if (_customerOrders.isNotEmpty) {
      final activeOrderIds = getRecentOrderIds();
      if (activeOrderIds.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrackingPage(
              customerOrders: _customerOrders.map((order) => order.toJson()).toList(),
              recentOrderIds: activeOrderIds,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TrackingPage(),
          ),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TrackingPage()),
      );
    }
  }

  // Show order history if available
  void _showOrderHistory() {
    final completedOrders = getCompletedOrders();
    if (completedOrders.isNotEmpty) {
      _showOrderHistoryDialog(completedOrders);
    } else {
      _showunavailable('Order History');
    }
  }

  void _showOrderHistoryDialog(List<CustomerOrder> orders) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order History'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderHistoryItem(order);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistoryItem(CustomerOrder order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: order.statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(order.statusIcon, color: order.statusColor, size: 20),
        ),
        title: Text(
          order.serviceCategory,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${order.formattedPrice} • ${order.statusText}'),
            Text(order.timeAgo, style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pop(context); // Close dialog
          _navigateToOrderDetails(order);
        },
      ),
    );
  }

  void _navigateToOrderDetails(CustomerOrder order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackingPage(
          initialOrderId: order.id,
          customerOrders: _customerOrders.map((o) => o.toJson()).toList(),
        ),
      ),
    );
  }

  // User info getters using CustomerProfile
  String _getUserName() {
    return _userProfile?.fullName ?? 'Customer';
  }

  String _getUserEmail() {
    return _userProfile?.email ?? 'user@email.com';
  }

  String _getUserPhone() {
    return _userProfile?.phone ?? 'Phone number not set';
  }

  String _getUserLocation() {
    // You might want to add location field to CustomerProfile
    return 'Lagos'; // Default for now
  }

  String _getProfileImage() {
    if (_userProfile?.profileImage != null) {
      return _getFullImageUrl(_userProfile!.profileImage!);
    }

    // Fallback to generated avatar
    final userName = _getUserName();
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=26857C&color=ffffff&size=150';
  }

  String _getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    } else if (imagePath.startsWith('/')) {
      return 'https://runpro9ja-pxqoa.ondigitalocean.app$imagePath';
    } else {
      return 'https://runpro9ja-pxqoa.ondigitalocean.app/uploads/$imagePath';
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Navigate to login screen
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
    if (result == true) {
      _loadUserProfile(); // Reload profile after update
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }
  void _showunavailable(String feature){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("No order yet ") ,
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  // Navigate to FAQ Screen
  void _navigateToFAQ() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FAQScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,

      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF2E7D32)),
            SizedBox(height: 16),
            Text(
              'Loading your profile...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Profile header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Profile avatar with edit indicator
                GestureDetector(
                  onTap: _navigateToEditProfile,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 42,
                          backgroundImage: NetworkImage(_getProfileImage()),
                          onBackgroundImageError: (exception, stackTrace) {
                            setState(() {}); // triggers fallback UI from _getProfileImage()
                          },
                        ),
                      ),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF26857C),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // User name
                Text(
                  _getUserName(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // User email
                Text(
                  _getUserEmail(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // User phone
                Text(
                  _getUserPhone(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // User location
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _getUserLocation(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                // Verification badge (you can add this field to CustomerProfile)
                if (_userProfile != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Profile options
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Personal Section
                  _buildSectionHeader('Personal'),
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: _navigateToEditProfile,
                  ),
                  _buildProfileOption(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Locations',
                    subtitle: 'Manage your frequently used locations',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SavedLocationsScreen()),
                      );
                    },
                  ),

                  // Orders Section
                  const SizedBox(height: 24),
                  _buildSectionHeader('Orders & Tracking'),
                  _buildProfileOption(
                    icon: Icons.local_shipping_outlined,
                    title: 'Tracking Information',
                    subtitle: _ordersLoading
                        ? 'Loading orders...'
                        : 'Track your ${getRecentOrderIds().length} active orders',
                    onTap: _navigateToTracking,
                  ),
                  _buildProfileOption(
                    icon: Icons.history,
                    title: 'Order History',
                    subtitle: 'View your ${getCompletedOrders().length} completed orders',
                    onTap: _showOrderHistory,
                  ),

                  // Support Section
                  const SizedBox(height: 24),
                  _buildSectionHeader('Support'),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    title: 'FAQ & Help Center',
                    subtitle: 'Find answers to common questions',
                    onTap: _navigateToFAQ,
                  ),
                  _buildProfileOption(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Refund Policy',
                    subtitle: 'Read our Refund policy',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RefundPolicyScreen()),
                    ),
                  ),
                  _buildProfileOption(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      subtitle: 'Read our terms and conditions',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),
                      )
                  ),

                  // Preferences Section
                  const SizedBox(height: 24),
                  _buildSectionHeader('Preferences'),
                  _buildProfileOption(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Manage your notification preferences',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationScreen()),
                      )
                  ),
                  _buildProfileOption(
                    icon: Icons.payment_outlined,
                    title: 'Payment Methods',
                    subtitle: 'Manage your payment options',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
                    ),
                  ),

                  // Account Section
                  const SizedBox(height: 24),
                  _buildSectionHeader('Account'),
                  // ADD DELETE ACCOUNT OPTION
                  _buildProfileOption(
                    icon: Icons.delete_outline,
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account and data',
                    isDelete: true,
                    onTap: _deleteAccount,
                  ),
                  _buildProfileOption(
                    icon: Icons.logout,
                    title: 'Log Out',
                    subtitle: 'Sign out of your account',
                    isLogout: true,
                    onTap: _handleLogout,
                  ),

                  // Debug info (remove in production)
                  if (_userProfile == null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange[700]),
                              const SizedBox(width: 8),
                              const Text(
                                'Debug Information',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'User profile is null. Check your API response.',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
    bool isDelete = false, // ADD THIS PARAMETER
  }) {
    Color? iconColor;
    Color? textColor;

    if (isDelete) {
      iconColor = Colors.red;
      textColor = Colors.red;
    } else if (isLogout) {
      iconColor = Colors.red;
      textColor = Colors.red;
    } else {
      iconColor = const Color(0xFF2E7D32);
      textColor = Colors.black87;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (isDelete || isLogout) ? Colors.red[50] : const Color(0xFF2E7D32).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: (isDelete || isLogout) ? Colors.red : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}