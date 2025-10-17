import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/babysitting_services/babysitting_service.dart';
import 'package:runpro_9ja/screens/hotel_booking_services/hotel_services.dart';
import 'package:runpro_9ja/screens/laundry_services/laundry_services.dart';
import 'package:runpro_9ja/screens/others_services/booking_services.dart';
import 'package:runpro_9ja/screens/professional_services/professional_services.dart';

import '../../auth/Auth_services/auth_service.dart';
import '../../services/customer_services.dart';
import '../errand_services/order_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryGreen = Color(0xFF2E7D32);

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _customerProfile;
  bool _isLoading = true;

  static final List<ServiceItem> _services = [
    ServiceItem('Errand service', 'assets/img_7.png', const ErrandServiceMenu()),
    ServiceItem('Babysitting', 'assets/img_8.png', const BabysittingApp()),
    ServiceItem('Professional service', 'assets/img_9.png', const ProfessionalServiceScreen()),
    ServiceItem('Hotel/accommodation bookings', 'assets/img_10.png', _ComingSoonScreen()),
    ServiceItem('Cleaning and Laundry services', 'assets/img_11.png',const CleaningServices()),
    ServiceItem('Personal assistance/others', 'assets/img_12.png', PersonalAssistanceApp(authService: AuthService(), customerService: CustomerService(AuthService()))),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final authService = AuthService();

      // Get basic user data from token
      final userData = await authService.getUserData();

      // Get customer profile data
      final customerProfile = await authService.getUserProfile();

      setState(() {
        _userData = userData;
        _customerProfile = customerProfile;
        _isLoading = false;
      });

    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });

      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getFirstName() {
    String fullName = '';

    if (_customerProfile != null && _customerProfile!['fullName'] != null) {
      fullName = _customerProfile!['fullName'];
    } else if (_userData != null && _userData!['name'] != null) {
      fullName = _userData!['name'];
    } else {
      return 'Customer';
    }

    // Split the full name and return only the first part
    List<String> nameParts = fullName.split(' ');
    return nameParts.first;
  }

  String _getUserLocation() {
    if (_customerProfile != null) {
      if (_customerProfile!['location'] is String) {
        return _customerProfile!['location'];
      } else if (_customerProfile!['location'] is Map) {
        return _customerProfile!['location']?['city'] ??
            _customerProfile!['location']?['address'] ??
            'Lagos';
      }
    }
    return 'Lagos';
  }

  String _getProfileImage() {
    if (_customerProfile?['profileImage'] != null) {
      String imagePath = _customerProfile!['profileImage'];
      return _getFullImageUrl(imagePath);
    }

    if (_customerProfile?['avatarUrl'] != null) {
      String imagePath = _customerProfile!['avatarUrl'];
      return _getFullImageUrl(imagePath);
    }

    final userName = _getFirstName();
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=26857C&color=ffffff&size=150';
  }

  String _getFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    } else if (imagePath.startsWith('/')) {
      return 'https://runpro9ja-backend.onrender.com$imagePath';
    } else {
      return 'https://runpro9ja-backend.onrender.com/uploads/$imagePath';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 90, 16, 40),
            decoration: const BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                Row(
                  children: [
                    // Profile Picture
                    _isLoading
                        ? _buildLoadingAvatar()
                        : _buildProfileAvatar(),
                    const SizedBox(width: 11),
                    // User Info
                    _buildUserInfo(),
                  ],
                ),
                const SizedBox(height: 30),

                // Search Section
                _buildSearchSection(),
              ],
            ),
          ),

          // Services Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: _services.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, i) {
                  final item = _services[i];
                  return _ServiceCard(
                    item: item,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => item.screen),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingAvatar() {
    return const CircleAvatar(
      radius: 25,
      backgroundColor: Colors.white24,
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: _navigateToProfile,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(_getProfileImage()),
            onBackgroundImageError: (exception, stackTrace) {
              // Fallback handled by default
            },
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(
                Icons.person,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isLoading
              ? _buildLoadingShimmer(120, 20)
              : Text(
            'Welcome ${_getFirstName()}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          _isLoading
              ? _buildLoadingShimmer(60, 14)
              : Text(
            _getUserLocation(),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      children: [
        const Center(
          child: Text(
            "How can we assist you best?",
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Search category',
              prefixIcon: Icon(Icons.search),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Options'),
        content: const Text('Go to your profile '),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class ServiceItem {
  final String title;
  final String asset;
  final Widget screen;
  const ServiceItem(this.title, this.asset, this.screen);
}

class _ServiceCard extends StatelessWidget {
  final ServiceItem item;
  final VoidCallback onTap;
  const _ServiceCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.asset(
                item.asset,
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 130,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error_outline, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Coming Soon Screen for Hotel Booking
class _ComingSoonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Bookings'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hotel,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              'Coming Soon!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Our hotel booking service is under development and will be available soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}