import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'home_screens/forget_password.dart';

class CustomerLoginPage extends StatefulWidget {
  const CustomerLoginPage({Key? key}) : super(key: key);

  @override
  State<CustomerLoginPage> createState() => _CustomerLoginPageState();
}

class _CustomerLoginPageState extends State<CustomerLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _biometricAvailable = false;
  bool _hasStoredCredentials = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _checkStoredCredentials();
      }
    });
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      bool canAuthenticate = await _localAuth.canCheckBiometrics;
      List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();

      setState(() {
        _biometricAvailable = canAuthenticate && availableBiometrics.isNotEmpty;
        _availableBiometrics = availableBiometrics;
      });

      print('🔐 Biometric Available: $_biometricAvailable');
      print('🔐 Available Biometrics: $_availableBiometrics');
    } catch (e) {
      print('❌ Error checking biometric availability: $e');
    }
  }

  Future<void> _checkStoredCredentials() async {
    try {
      final String? storedIdentifier = await _secureStorage.read(key: 'user_identifier');
      final String? storedPassword = await _secureStorage.read(key: 'user_password');

      setState(() {
        _hasStoredCredentials = storedIdentifier != null && storedPassword != null;
      });

      if (_hasStoredCredentials) {
        print('🔐 Stored credentials found');
        // Auto-trigger biometric login after a short delay
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            _authenticateWithBiometrics();
          }
        });
      }
    } catch (e) {
      print('❌ Error checking stored credentials: $e');
    }
  }

  Future<void> _storeCredentials(String identifier, String password) async {
    try {
      await _secureStorage.write(key: 'user_identifier', value: identifier);
      await _secureStorage.write(key: 'user_password', value: password);
      setState(() {
        _hasStoredCredentials = true;
      });
      print('✅ Credentials stored securely');
    } catch (e) {
      print('❌ Error storing credentials: $e');
    }
  }

  Future<void> _removeStoredCredentials() async {
    try {
      await _secureStorage.delete(key: 'user_identifier');
      await _secureStorage.delete(key: 'user_password');
      setState(() {
        _hasStoredCredentials = false;
      });
      print('✅ Credentials removed');
    } catch (e) {
      print('❌ Error removing credentials: $e');
    }
  }



  // FIXED: Correct biometric authentication
  // FIXED: Correct biometric authentication
  Future<void> _authenticateWithBiometrics() async {
    try {
      final bool canAuthenticate =
          await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometric authentication not available on this device.')),
          );
        }
        return;
      }

      // FIXED: Changed 'auth' to '_localAuth'
      // Using your local_auth version's API
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your RunPro 9ja account',
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: false,
      );

      if (authenticated) {
        print('✅ Biometric authentication successful');
        await _loginWithStoredCredentials();
      } else {
        print('❌ Authentication failed or cancelled');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Authentication failed. Try again.')),
          );
        }
      }
    } on PlatformException catch (e) {
      print('❌ Biometric error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Biometric error: ${e.message}')),
        );
      }
    }
  }


  Future<void> _loginWithStoredCredentials() async {
    try {
      final String? storedIdentifier = await _secureStorage.read(key: 'user_identifier');
      final String? storedPassword = await _secureStorage.read(key: 'user_password');

      if (storedIdentifier == null || storedPassword == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No stored credentials found')),
          );
        }
        return;
      }

      setState(() => _isLoading = true);

      final url = Uri.parse("https://runpro9ja-pxqoa.ondigitalocean.app/api/auth/login");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identifier": storedIdentifier,
          "password": storedPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["token"] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("jwtToken", data["token"]);
        print("✅ Auto-login successful");

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        // Auto-login failed, remove stored credentials
        await _removeStoredCredentials();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Auto-login failed")),
          );
        }
      }
    } catch (e) {
      print('❌ Auto-login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Auto-login failed. Please login manually.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("https://runpro9ja-pxqoa.ondigitalocean.app/api/auth/login");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identifier": _identifierController.text.trim(),
          "password": _passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["token"] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("jwtToken", data["token"]);
        print("✅ Login successful");

        // Store credentials for biometric login (if biometric is available)
        if (_biometricAvailable) {
          await _storeCredentials(
            _identifierController.text.trim(),
            _passwordController.text.trim(),
          );
        }

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/main');

      } else {
        String errorMessage = data["message"] ?? "Login failed";
        if (response.statusCode == 404) {
          errorMessage = "User not found";
        } else if (response.statusCode == 401) {
          errorMessage = "Invalid password";
        } else if (response.statusCode == 403) {
          errorMessage = "Account not verified";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      print('❌ Full error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Image.asset('assets/img1.png', width: 100, height: 100),
                const SizedBox(height: 12),

                // Welcome Text
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign in to your customer account",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 30),

                // Biometric Prompt (if available and has stored credentials)
                if (_hasStoredCredentials && _biometricAvailable) ...[
                  _buildBiometricSection(),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  Text(
                    "Or sign in with password",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Email/Phone Field
                TextFormField(
                  controller: _identifierController,
                  decoration: InputDecoration(
                    labelText: "Email or Phone Number",
                    hintText: "Enter your email or phone",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email or phone number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    if (value.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Biometric Toggle & Forgot Password Row
                Row(
                  children: [
                    // Biometric Toggle
                    if (_biometricAvailable) ...[
                      Row(
                        children: [
                          Icon(
                            _hasStoredCredentials
                                ? Icons.fingerprint
                                : Icons.fingerprint_outlined,
                            color: _hasStoredCredentials
                                ? Colors.green.shade700
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Remember me",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Switch(
                            value: _hasStoredCredentials,
                            onChanged: (value) {
                              if (value) {
                                // Only enable if we have credentials entered
                                if (_identifierController.text.isNotEmpty &&
                                    _passwordController.text.isNotEmpty) {
                                  _storeCredentials(
                                    _identifierController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter credentials first'),
                                    ),
                                  );
                                }
                              } else {
                                _removeStoredCredentials();
                              }
                            },
                            activeColor: Colors.green.shade700,
                          ),
                        ],
                      ),
                    ],

                    const Spacer(),

                    // Forgot Password
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.green.shade700,
                      elevation: 2,
                    ),
                    onPressed: _isLoading ? null : _loginCustomer,
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Signup Redirect
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricSection() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              _getBiometricIcon(),
              size: 40,
              color: Colors.green.shade700,
            ),
            const SizedBox(height: 8),
            Text(
              "Quick Login Available",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Use ${_getBiometricTypeText()} to login quickly",
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(_getBiometricIcon(), size: 20),
                label: Text("Login with ${_getBiometricTypeText()}"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading ? null : _authenticateWithBiometrics,
              ),
            ),
            TextButton(
              onPressed: _isLoading ? null : _removeStoredCredentials,
              child: Text(
                "Use password instead",
                style: TextStyle(color: Colors.green.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return Icons.remove_red_eye;
    }
    return Icons.security;
  }

  String _getBiometricTypeText() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return "Face ID";
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return "Fingerprint";
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return "Iris Scan";
    }
    return "Biometric";
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}