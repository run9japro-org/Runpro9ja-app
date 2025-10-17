import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackingService {
  static const String baseUrl = 'https://runpro9ja-pxqoa.ondigitalocean.app/api';
  static const Duration apiTimeout = Duration(seconds: 30);
  static WebSocketChannel? _channel;

  // Helper method to get authentication token
  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('jwtToken');
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final String? token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication failed: No token found. Please login again.');
      }

      final url = Uri.parse('$baseUrl/api/orders/$orderId');
      print('🌐 Fetching order from: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(apiTimeout);

      print('📨 Order API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 403) {
        throw Exception('Access denied: This order does not belong to your account');
      } else if (response.statusCode == 404) {
        throw Exception('Order not found with ID: $orderId');
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed: Please login again');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout. Please check your connection and try again.');
    } catch (e) {
      print('❌ Error in getOrderDetails: $e');
      rethrow;
    }
  }

  // FIXED: New method to try alternative endpoints for order lookup
  static Future<Map<String, dynamic>> _tryAlternativeOrderEndpoints(String orderId, String token) async {
    print('🔄 Trying alternative endpoints for order: $orderId');

    // Try customer-specific endpoint first
    try {
      final url = Uri.parse('$baseUrl/customers/me/orders/$orderId');
      print('🔧 Trying customer endpoint: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(apiTimeout);

      if (response.statusCode == 200) {
        print('✅ Order found via customer endpoint');
        return json.decode(response.body);
      }
    } catch (e) {
      print('❌ Customer endpoint failed: $e');
    }

    // FIXED: Try orders/my-orders endpoint and filter with proper type safety
    try {
      final url = Uri.parse('$baseUrl/orders/my-orders');
      print('🔧 Trying my-orders endpoint: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dynamic ordersData = data['orders'] ?? data['data'] ?? [];

        // FIX: Proper type checking and safe list handling
        if (ordersData is List) {
          // Convert to List<dynamic> safely
          final List<dynamic> orders = List<dynamic>.from(ordersData);

          // FIX: Safe search with proper type checking
          dynamic foundOrder;
          for (final dynamic order in orders) {
            if (order is Map) {
              final orderIdFromList = order['_id']?.toString();
              if (orderIdFromList == orderId) {
                foundOrder = order;
                break;
              }
            }
          }

          if (foundOrder != null) {
            print('✅ Order found in my-orders list');
            return {
              'order': foundOrder is Map<String, dynamic>
                  ? foundOrder
                  : Map<String, dynamic>.from(foundOrder),
              'foundInList': true
            };
          }
        } else {
          print('❌ Unexpected orders format: ${ordersData.runtimeType}');
        }
      }
    } catch (e) {
      print('❌ My-orders endpoint failed: $e');
    }

    // If all alternatives fail
    throw Exception('Access denied. This order does not belong to your account or you do not have permission to view it.');
  }

  // Enhanced live location with authentication
  static Future<Map<String, dynamic>> getLiveLocation(String orderId) async {
    try {
      final String? token = await _getToken();
      if (token == null) {
        throw Exception('Authentication required. Please login again.');
      }

      final url = Uri.parse('$baseUrl/delivery/$orderId/location');
      print('📍 Fetching live location from: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(apiTimeout);

      print('📍 Location API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('Live location not available for this order yet.');
      } else {
        throw Exception('Failed to load live location: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Location request timeout. Please try again.');
    } catch (e) {
      print('❌ Error getting live location: $e');
      rethrow;
    }
  }

  // FIXED: Enhanced customer orders with authentication and proper type safety
  static Future<List<dynamic>> getCustomerOrders() async {
    try {
      final String? token = await _getToken();
      if (token == null) {
        throw Exception('Authentication required. Please login again.');
      }

      final url = Uri.parse('$baseUrl/orders/my-orders');
      print('📦 Fetching customer orders from: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(apiTimeout);

      print('📦 Orders API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dynamic ordersData = data['orders'] ?? data['data'] ?? [];

        // FIX: Ensure we return a proper List<dynamic>
        if (ordersData is List) {
          final List<dynamic> orders = List<dynamic>.from(ordersData);
          print('✅ Found ${orders.length} customer orders');
          return orders;
        } else {
          print('❌ Unexpected orders format: ${ordersData.runtimeType}');
          return [];
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed: Please login again');
      } else {
        throw Exception('Failed to load customer orders: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout while loading orders.');
    } catch (e) {
      print('❌ Error in getCustomerOrders: $e');
      rethrow;
    }
  }

  // Enhanced service history with authentication
  static Future<Map<String, dynamic>> getServiceHistory({
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final String? token = await _getToken();
      if (token == null) {
        throw Exception('Authentication required. Please login again.');
      }

      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null && status != 'all') {
        queryParams['status'] = status;
      }

      final queryString = Uri(queryParameters: queryParams).query;
      final url = '$baseUrl/customers/me/history${queryString.isNotEmpty ? '?$queryString' : ''}';

      print('📚 Fetching service history from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(apiTimeout);

      print('📚 History API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed: Please login again');
      } else {
        throw Exception('Failed to load service history: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timeout while loading history.');
    } catch (e) {
      print('❌ Error in getServiceHistory: $e');
      rethrow;
    }
  }

  // Enhanced WebSocket connection with proper URL format
  static WebSocketChannel connectToOrderTracking(String orderId, String token) {
    try {
      // Correct WebSocket URL format for your backend
      final wsUrl = 'wss://runpro9ja-backend.onrender.com/ws/orders/$orderId/tracking?token=$token';
      print('🔌 Connecting to WebSocket: $wsUrl');

      _channel = WebSocketChannel.connect(
        Uri.parse(wsUrl),
      );

      print('✅ WebSocket connected successfully');
      return _channel!;
    } catch (e) {
      print('❌ WebSocket connection failed: $e');
      rethrow;
    }
  }

  static void disconnect() {
    _channel?.sink.close();
    _channel = null;
    print('🔌 WebSocket disconnected');
  }

  // Enhanced order status update with authentication
  static Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
    String? note,
  }) async {
    try {
      final String? token = await _getToken();
      if (token == null) {
        throw Exception('Authentication required. Please login again.');
      }

      final url = Uri.parse('$baseUrl/orders/$orderId/status');
      print('🔄 Updating order status at: $url');

      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'status': status,
          'note': note,
        }),
      ).timeout(apiTimeout);

      print('🔄 Status update response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Permission denied: You cannot update this order status');
      } else {
        throw Exception('Failed to update order status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Status update timeout. Please try again.');
    } catch (e) {
      print('❌ Error updating order status: $e');
      rethrow;
    }
  }

  // Enhanced agent location update with authentication
  static Future<Map<String, dynamic>> updateAgentLocation({
    required String orderId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final String? token = await _getToken();
      if (token == null) {
        throw Exception('Authentication required. Please login again.');
      }

      final url = Uri.parse('$baseUrl/delivery/$orderId/location');
      print('📍 Updating agent location at: $url');

      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'lat': latitude,
          'lng': longitude,
        }),
      ).timeout(apiTimeout);

      print('📍 Location update response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Permission denied: You cannot update location for this order');
      } else {
        throw Exception('Failed to update location: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Location update timeout. Please try again.');
    } catch (e) {
      print('❌ Error updating agent location: $e');
      rethrow;
    }
  }

  // New method: Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  // New method: Validate token and get user info
  static Future<Map<String, dynamic>?> validateToken() async {
    try {
      final String? token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/auth/validate'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(apiTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Token validation error: $e');
      return null;
    }
  }
}