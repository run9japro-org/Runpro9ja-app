import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/agent_model.dart';

class AuthService {
  static const String baseUrl = "https://runpro9ja-pxqoa.ondigitalocean.app";

  // Add timeout duration
  static const Duration apiTimeout = Duration(seconds: 30);

  // Network client with reusable configuration
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  // Dispose method for cleanup
  void dispose() {
    _client.close();
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse("$baseUrl/api/auth/register");
      print('🚀 Sending registration request to: $url');

      final response = await _client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      ).timeout(apiTimeout);

      print('📨 Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');

      final result = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'userId': result['userId'] ?? result['_id'],
          'message': result['message'] ?? 'Registration successful'
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Registration failed',
          'statusCode': response.statusCode
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timeout. Please try again.'
      };
    } catch (e) {
      print('🔥 Registration API error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String userId, String otp) async {
    try {
      final url = Uri.parse("$baseUrl/api/auth/verify-otp");
      final response = await _client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "code": otp}),
      ).timeout(apiTimeout);

      final result = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'statusCode': response.statusCode,
        ...result
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'OTP verification timeout'
      };
    } catch (e) {
      print('🔥 OTP verification error: $e');
      return {
        'success': false,
        'message': 'OTP verification failed: ${e.toString()}'
      };
    }
  }

  // Get user data from JWT token
  Future<Map<String, dynamic>?> getUserData() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      // Add padding if needed
      String padded = payload;
      while (padded.length % 4 != 0) {
        padded += '=';
      }
      final decoded = utf8.decode(base64Url.decode(padded));
      final Map<String, dynamic> data = json.decode(decoded);
      return data;
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  // Get customer profile from API
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await get('api/customers/me');
      if (response['statusCode'] == 200) {
        return {
          'success': true,
          'data': response['body']
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch profile',
          'statusCode': response['statusCode']
        };
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return {
        'success': false,
        'message': 'Profile fetch error: ${e.toString()}'
      };
    }
  }

  // Enhanced GET method
  Future<Map<String, dynamic>> get(String path) async {
    try {
      final token = await getToken();
      final normalizedPath = path.startsWith("/") ? path : "/$path";
      final url = Uri.parse('$baseUrl$normalizedPath');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      print("➡️ GET $url");

      final res = await _client.get(url, headers: headers).timeout(apiTimeout);

      print("⬅️ Status: ${res.statusCode}");
      print("⬅️ Response: ${res.body}");

      final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};

      return {
        'statusCode': res.statusCode,
        'body': body,
        'success': res.statusCode == 200,
      };
    } on TimeoutException {
      return {
        'statusCode': 408,
        'body': {'message': 'Request timeout'},
        'success': false,
      };
    } catch (e) {
      print('🔥 GET request error: $e');
      return {
        'statusCode': 500,
        'body': {'message': 'Request failed: ${e.toString()}'},
        'success': false,
      };
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('jwtToken');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Save token method
  Future<bool> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString('jwtToken', token);
    } catch (e) {
      print('Error saving token: $e');
      return false;
    }
  }

  // Logout method
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('jwtToken');
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final response = await _client.get(
        Uri.parse("$baseUrl/api/auth/me"),
      ).timeout(apiTimeout);

      final result = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        ...result
      };
    } catch (e) {
      print('🔥 Fetch profile error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch profile: ${e.toString()}'
      };
    }
  }

  // Helper methods for specific service types
  Future<List<Agent>> getErrandAgents() async {
    return getAvailableAgents(serviceType: 'Errand Service');
  }

  Future<List<Agent>> getDeliveryAgents() async {
    return getAvailableAgents(serviceType: 'delivery');
  }

  Future<List<Agent>> getCleaningAgents() async {
    return getAvailableAgents(serviceType: 'cleaning');
  }

  Future<List<Agent>> getMovingAgents() async {
    return getAvailableAgents(serviceType: 'moving');
  }

  Future<List<Agent>> getPersonalAssistantAgents() async {
    return getAvailableAgents(serviceType: 'personal');
  }

  Future<List<Agent>> getGroceryAgents() async {
    return getAvailableAgents(serviceType: 'Errand Service');
  }

  // Get all agents without filtering
  Future<List<Agent>> getAllAgents() async {
    return getAvailableAgents();
  }

  // Get agents by multiple service types
  Future<Map<String, List<Agent>>> getAgentsByServiceTypes(List<String> serviceTypes) async {
    final results = <String, List<Agent>>{};

    for (final serviceType in serviceTypes) {
      final agents = await getAvailableAgents(serviceType: serviceType);
      results[serviceType] = agents;
    }

    return results;
  }

  // In your AuthService class - update the getAvailableAgents method// In your AuthService - update the getAvailableAgents method
  Future<List<Agent>> getAvailableAgents({String? serviceType, String? categoryId}) async {
    try {
      print('🌐 Fetching available agents from backend...');

      // Build query parameters
      final params = <String, String>{};
      if (serviceType != null && serviceType.isNotEmpty) {
        // Map frontend service types to backend service types
        final mappedServiceType = _mapServiceTypeToBackend(serviceType);
        params['serviceType'] = mappedServiceType;
      }

      final url = Uri.parse('$baseUrl/api/agents/available').replace(
        queryParameters: params.isNotEmpty ? params : null,
      );

      print('🔗 Request URL: $url');
      print('📤 Mapped service type: ${params['serviceType']}');

      final response = await _client.get(url).timeout(apiTimeout);

      print('📥 Agents response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle different response formats
        List<dynamic> agentsList;

        if (data is List) {
          agentsList = data;
        } else if (data is Map && data.containsKey('agents')) {
          agentsList = data['agents'] as List? ?? [];
        } else if (data is Map && data.containsKey('data')) {
          agentsList = data['data']['agents'] as List? ?? [];
        } else {
          agentsList = [];
        }

        print('✅ Found ${agentsList.length} agents for service: $serviceType (mapped to: ${params['serviceType']})');

        // Convert to Agent objects
        final agents = agentsList.map((agentData) {
          try {
            return Agent.fromJson(agentData);
          } catch (e) {
            print('❌ Error parsing agent data: $e');
            print('❌ Problematic agent data: $agentData');
            return null;
          }
        }).where((agent) => agent != null).cast<Agent>().toList();

        return agents;
      } else {
        print('❌ Backend returned error: ${response.statusCode}');
        print('❌ Error response: ${response.body}');
        return _getSampleAgents(serviceType: serviceType);
      }
    } on TimeoutException {
      print('⏰ Timeout fetching agents');
      return _getSampleAgents(serviceType: serviceType);
    } catch (e) {
      print('💥 Error fetching agents from backend: $e');
      return _getSampleAgents(serviceType: serviceType);
    }
  }

  // Add this mapping method to your AuthService
  String _mapServiceTypeToBackend(String frontendServiceType) {
    switch (frontendServiceType.toLowerCase()) {
      case 'grocery':
      case 'errand':
      case 'shopping':
        return 'Errand Service';

      case 'moving':
      case 'movers':
        return 'Moving Service';

      case 'cleaning':
        return 'Cleaning Service';

      case 'delivery':
        return 'Delivery Service';

      case 'laundry':
        return 'Laundry Service';

      case 'plumbing':
        return 'Professional service'; // Matches your backend

      case 'electrical':
        return 'Electrical Service';

      default:
        return frontendServiceType;
    }
  }
  // Update the sample agents to use the proper Agent constructor// Update the _getSampleAgents method in AuthService
  List<Agent> _getSampleAgents({String? serviceType}) {
    final service = serviceType?.toLowerCase() ?? 'general';

    // Sample data that matches your backend structure
    if (service.contains('errand')) {
      return [
        Agent(
          id: '68dec045054aca232b1e4793',
          userId: '68debed0054aca232b1e4785',
          serviceType: 'Errand Service',
          yearsOfExperience: '3',
          availability: 'weekdays_weekends',
          summary: 'Reliable errand runner for all your needs',
          servicesOffered: 'Grocery shopping, Package delivery, Bill payments',
          areasOfExpertise: 'Time management, Multi-tasking',
          rating: 4.5,
          completedJobs: 67,
          isVerified: true,
          profileImage: '/uploads/1760008130452.jpg',
          bio: 'QuickRun Errands - Quick and reliable errand services',
          subCategory: 'Personal Assistant',
          price: 3500,
          responseTime: '10',
          createdAt: DateTime.parse('2024-01-16T14:30:00.614Z'),
          updatedAt: DateTime.parse('2024-01-23T10:15:00.456Z'),
          location: {
            'address': 'Surulere, Lagos',
            'city': 'Lagos',
            'state': 'Lagos'
          },
        ),
      ];
    }

    if (service.contains('moving')) {
      return [
        Agent(
          id: '68dec045054aca232b1e4789',
          userId: '68debed0054aca232b1e4781',
          serviceType: 'Moving Service',
          yearsOfExperience: '5',
          availability: 'weekdays',
          summary: 'Professional mover with 5+ years experience',
          servicesOffered: 'Small moves, Apartment moves, Office relocation',
          areasOfExpertise: 'Furniture handling, Logistics planning',
          rating: 4.8,
          completedJobs: 156,
          isVerified: true,
          profileImage: '/uploads/1760008130448.jpg',
          bio: 'John Moving Pro - Professional mover with 5+ years experience',
          subCategory: 'House Mover',
          certification: 'Moving Professional Certificate',
          price: 8500,
          responseTime: '15',
          createdAt: DateTime.parse('2024-01-15T10:30:00.614Z'),
          updatedAt: DateTime.parse('2024-01-20T14:25:00.456Z'),
          location: {
            'address': 'Lagos Mainland, Lagos',
            'city': 'Lagos',
            'state': 'Lagos'
          },
          vehicleTypes: ['van', 'truck'],
        ),
      ];
    }

    // Add more service types as needed...

    return [];
  }
// In your AuthService - Add the assignAgentToOrder method
  Future<bool> assignAgentToOrder({
    required String orderId,
    required String agentId,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await _client.patch(
        Uri.parse('$baseUrl/api/orders/$orderId/assign-agent'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'agentId': agentId}),
      );

      if (response.statusCode == 200) {
        print('✅ Agent assigned successfully to order: $orderId');
        return true;
      } else {
        print('❌ Failed to assign agent: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('💥 Error assigning agent to order: $e');
      return false;
    }
  }
}

