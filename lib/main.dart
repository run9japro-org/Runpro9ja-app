import 'dart:io';
import 'package:flutter/material.dart';
import 'package:runpro_9ja/screens/home_screens/carousel_screen.dart';
import 'package:runpro_9ja/screens/home_screens/otp_screen.dart';
import 'package:runpro_9ja/screens/home_screens/profile_screen.dart';
import 'package:runpro_9ja/screens/login_screen.dart';
import 'package:runpro_9ja/screens/service_history_screen.dart';
import 'package:runpro_9ja/screens/home_screens/signup_screen.dart';
import 'package:runpro_9ja/screens/home_screens/splash_screen.dart';
import 'package:runpro_9ja/screens/verified_screen.dart';
import 'package:runpro_9ja/screens/welcome_screen.dart';

// Import new bottom nav pages
import 'package:runpro_9ja/screens/home_screens/home_screen.dart';
import 'package:runpro_9ja/screens/support_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:runpro_9ja/services/customer_services.dart';
import 'auth/Auth_services/auth_service.dart';
import 'firebase_options.dart'; // from flutterfire configure
import 'services/push_notification_service.dart';

// ✅ ADD RECOVERY SERVICES
import 'services/order_recovery_service.dart';
import 'services/app_recovery_handler.dart';

// ✅ ADD NOTIFICATION SERVICES
import 'services/local_notification_service.dart';
import 'services/notification_manager.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ ADD THIS: iPad crash prevention
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase init error: $e');
    // Continue without Firebase if it fails
  }

  // ✅ INITIALIZE NOTIFICATION SERVICES
  await _initializeNotificationServices();

  runApp(
    ProviderScope( // 👈 Riverpod root
      child: MyApp(),
    ),
  );
}

Future<void> _initializeNotificationServices() async {
  try {
    print('🔄 Initializing notification services...');

    // Initialize local notifications with simple callback
    final localNotificationService = LocalNotificationService();
    await localNotificationService.initialize(
      onNotificationTap: (data) {
        print('🔔 Notification tapped in main.dart: $data');
        // The actual navigation will be handled in MainPage
      },
    );

    // Request notification permissions
    final permissionsGranted = await localNotificationService.requestPermissions();
    print('📱 Notification permissions granted: $permissionsGranted');

    print('✅ Notification services initialized successfully');
  } catch (e) {
    print('❌ Error initializing notification services: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: LocalNotificationService.navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/signup': (context) => SignupScreen(),
        '/login': (context) => CustomerLoginPage(),
        '/verified': (context) => VerifiedPage(),
        '/main': (context) => MainPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          final userId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => OtpScreen(userId: userId),
          );
        }
        return null;
      },
    );
  }
}

//
// ✅ Bottom Navigation Page WITH RECOVERY & NOTIFICATIONS
//
class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  bool _recoveryChecked = false;
  final LocalNotificationService _notificationService = LocalNotificationService();
  late final NotificationManager _notificationManager;

  // FIXED: Create fresh instances for each tab to avoid state issues
  final List<Widget> _pages = [
    HomeScreen(),
    ServiceHistoryScreen(customerService: CustomerService(AuthService())),
    SupportScreen(),
    ProfileScreen()
  ];

  void _onItemTapped(int index) {
    print('🎯 Bottom nav tapped: $index');

    // If clicking the same tab that's already active, refresh it
    if (index == _selectedIndex) {
      print('🔄 Refreshing current tab: $index');
      _refreshCurrentTab(index);
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // ADD THIS: Refresh functionality for each tab
  void _refreshCurrentTab(int index) {
    switch (index) {
      case 0: // Home
      // Home screen refresh logic if needed
        break;
      case 1: // Service History
        final serviceHistoryScreen = _pages[1] as ServiceHistoryScreen;
        // You might need to add a refresh method to ServiceHistoryScreen
        break;
      case 2: // Support
      // Support screen refresh logic if needed
        break;
      case 3: // Profile
      // Profile screen refresh logic if needed
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeNotificationManager();
    _checkForRecovery();
    _setupNotificationListener();
    _checkForBackendNotifications();
  }

  // ✅ ADD THIS: Initialize notification manager
  void _initializeNotificationManager() {
    try {
      final notificationService = NotificationService(AuthService());
      _notificationManager = NotificationManager(notificationService, _notificationService);
      print('✅ Notification Manager initialized');
    } catch (e) {
      print('❌ Error initializing Notification Manager: $e');
    }
  }

  // ✅ ADD THIS: Check for backend notifications
  void _checkForBackendNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(seconds: 3));

      if (mounted) {
        print('🔄 Checking for backend notifications...');
        try {
          await _notificationManager.checkForNewNotifications();
          print('✅ Backend notification check completed');
        } catch (e) {
          print('❌ Error checking backend notifications: $e');
        }
      }
    });
  }

  void _checkForRecovery() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        await AppRecoveryHandler.checkForRecoverableSessions(context);
        setState(() {
          _recoveryChecked = true;
        });
      }
    });
  }

  // ✅ UPDATED: Setup notification tap listener with navigation
  void _setupNotificationListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set up the notification tap handler
      LocalNotificationService.onNotificationTapped = _handleNotificationTap;
      print('✅ Notification tap listener setup complete');
    });
  }

  // ✅ ADD THIS: Handle notification taps with navigation
  void _handleNotificationTap(Map<String, String> data) {
    print('🔔 Notification tapped in MainPage: $data');

    final type = data['type'];
    final orderId = data['orderId'];
    final agentName = data['agentName'];
    final serviceType = data['serviceType'];

    // Handle different notification types
    switch (type) {
      case 'order_accepted':
        _navigateToTab(0); // Home tab
        _showNotificationDialog(
          '🎉 Order Accepted!',
          '$agentName accepted your $serviceType order. Order ID: $orderId',
        );
        break;

      case 'order_rejected':
        _navigateToTab(0); // Home tab
        _showNotificationDialog(
          '❌ Order Not Accepted',
          '$agentName was unable to accept your $serviceType order. Please try another agent.',
        );
        break;

      case 'order_completed':
        _navigateToTab(1); // Service History tab
        _showNotificationDialog(
          '✅ Order Completed!',
          'Your $serviceType order has been completed successfully. Thank you for using RunPro!',
        );
        break;

      case 'payment_success':
        _navigateToTab(1); // Service History tab
        _showNotificationDialog(
          '💳 Payment Successful!',
          'Your payment for order $orderId was processed successfully.',
        );
        break;

      case 'payment_failed':
        _navigateToTab(0); // Home tab to retry
        _showNotificationDialog(
          '❌ Payment Failed',
          'Payment for order $orderId failed. Please try again.',
        );
        break;

      case 'agent_on_way':
        _navigateToTab(0); // Home tab for tracking
        _showNotificationDialog(
          '🚗 Agent On The Way',
          '$agentName is on the way to your location for $serviceType service.',
        );
        break;

      case 'agent_arrived':
        _navigateToTab(0); // Home tab for tracking
        _showNotificationDialog(
          '📍 Agent Has Arrived',
          '$agentName has arrived at your location for $serviceType service.',
        );
        break;

      case 'test':
        _showNotificationDialog(
          'Test Notification',
          'This is a test notification from RunPro 9ja!',
        );
        break;

      default:
        _showNotificationDialog(
          'New Notification',
          'You have a new notification from RunPro 9ja.',
        );
        break;
    }
  }

  // ✅ ADD THIS: Navigate to specific tab
  void _navigateToTab(int tabIndex) {
    if (_selectedIndex != tabIndex) {
      setState(() {
        _selectedIndex = tabIndex;
      });
      print('🧭 Navigated to tab: $tabIndex');
    }
  }

  // ✅ ADD THIS: Show dialog with notification info
  void _showNotificationDialog(String title, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
        );
        print('💬 Notification dialog shown: $title');
      }
    });
  }

  // ✅ ADD THESE TEST METHODS
  Future<void> _testBackendNotification() async {
    await _notificationManager.testBackendNotification();
  }

  Future<void> _forceSyncNotifications() async {
    await _notificationManager.syncNotifications();
  }

  Future<void> _testLocalNotification() async {
    await _notificationService.showCustomNotification(
      title: 'Test Local Notification',
      body: 'Tap this notification to test navigation',
      payload: 'type=test&timestamp=${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      // ✅ ADD DEBUG BUTTONS
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "Service History"),
        BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: "Customer Support"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}