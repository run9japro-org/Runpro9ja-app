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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ProviderScope( // 👈 Riverpod root
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/signup': (context) => SignupScreen(),
        '/login':(context)=> CustomerLoginPage(),
        '/verified': (context) => VerifiedPage(),
        '/main': (context) => MainPage(),
      },onGenerateRoute: (settings) {
      if (settings.name == '/otp') {
        final userId = settings.arguments as String; // ✅ pass userId instead
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
// ✅ Bottom Navigation Page
//
class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    ServiceHistoryScreen(customerService: CustomerService(AuthService()),),
    SupportScreen(),
    ProfileScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // ✅ prevents truncating
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
    ),

    );
  }
}
