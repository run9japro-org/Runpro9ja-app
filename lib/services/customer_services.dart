// services/customer_service.dart - UPDATED VERSION
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/Auth_services/auth_service.dart';
import '../models/customer_models.dart';

class CustomerService {
  static const String baseUrl = "https://runpro9ja-pxqoa.ondigitalocean.app";
  final AuthService authService;

  CustomerService(this.authService);

  Future<String?> _getToken() async {
    try {
      return await authService.getToken();
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ============ PROFESSIONAL SERVICE METHODS ============

  /// Create a professional service order (Step 1) - UPDATED
  // In your CustomerService class, update the createProfessionalOrder method
  // In your CustomerService, make sure you're sending the serviceCategory correctly
  Future<dynamic> createProfessionalOrder({
    required String serviceCategory,
    required String details,
    required String location,
    String? scheduledDate,
    String? scheduledTime,
    String urgency = 'standard',
    String serviceScale = 'minimum',
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = '$baseUrl/api/orders';
      print('📦 Creating professional order at: $url');

      // Prepare order data - make sure serviceCategory is included
      final orderData = {
        'serviceCategory': serviceCategory, // This should be the ObjectId from ServiceMapper
        'details': details,
        'location': location,
        'urgency': urgency,
        'serviceScale': serviceScale,
        'orderType': 'professional',
        if (scheduledDate != null && scheduledDate.isNotEmpty)
          'scheduledDate': scheduledDate,
        if (scheduledTime != null && scheduledTime.isNotEmpty)
          'scheduledTime': scheduledTime,
      };

      print('📝 Order data being sent: $orderData');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(orderData),
      );

      print('📊 Create order response status: ${response.statusCode}');
      print('📊 Create order response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Order creation successful');
        return responseData;
      } else {
        throw Exception('Failed to create professional order: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating professional order: $e');
      rethrow;
    }
  }
// In your CustomerService class
  Future<void> assignAgentToOrder({
    required String orderId,
    required String agentId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = '$baseUrl/api/orders/$orderId/assign-agent';
      print('👤 Assigning agent to order: $url');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'agentId': agentId,
        }),
      );

      print('📊 Assign agent response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to assign agent: ${response.statusCode}');
      }

      print('✅ Agent assigned successfully');
    } catch (e) {
      print('❌ Error assigning agent: $e');
      rethrow;
    }
  }
  /// NEW: Select agent for minimum scale orders
  Future<Map<String, dynamic>> selectAgentForMinimumScale({
    required String orderId,
    required String agentId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/orders/$orderId/select-agent-minimum'),
        headers: await _getHeaders(),
        body: json.encode({'agentId': agentId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to select agent for minimum scale: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error selecting agent for minimum scale: $e');
      rethrow;
    }
  }

  /// Accept quotation provided by representative (Step 3)
  Future<Map<String, dynamic>> acceptQuotation(String orderId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/orders/$orderId/accept-quotation'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to accept quotation: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error accepting quotation: $e');
      rethrow;
    }
  }

  /// Select agent after quotation acceptance (Step 4)
  Future<Map<String, dynamic>> selectAgentAfterQuotation({
    required String orderId,
    required String agentId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/orders/$orderId/select-agent'),
        headers: await _getHeaders(),
        body: json.encode({'agentId': agentId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to select agent: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error selecting agent: $e');
      rethrow;
    }
  }

  /// Get order details with quotation information
  Future<Map<String, dynamic>> getOrderWithQuotation(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/$orderId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch order details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching order details: $e');
      rethrow;
    }
  }

  // ============ EXISTING METHODS (KEEP THESE) ============

  // Get customer profile
  Future<CustomerProfile> getCustomerProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/customers/me'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CustomerProfile.fromJson(data);
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching customer profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/customers/me'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to load profile: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // If you want to return List<CustomerOrder>, fix it like this:
  Future<List<CustomerOrder>> getCustomerOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/my-orders'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle different response formats
        List<dynamic> ordersData = [];

        if (data['orders'] != null) {
          ordersData = data['orders'];
        } else if (data['data'] != null) {
          ordersData = data['data'];
        } else if (data is List) {
          ordersData = data;
        }

        print('✅ Customer orders loaded: ${ordersData.length} orders');

        // FIX: Safe conversion to CustomerOrder with error handling
        final List<CustomerOrder> orders = [];
        for (final orderJson in ordersData) {
          try {
            if (orderJson is Map<String, dynamic>) {
              orders.add(CustomerOrder.fromJson(orderJson));
            } else if (orderJson is Map) {
              orders.add(CustomerOrder.fromJson(Map<String, dynamic>.from(orderJson)));
            }
          } catch (e) {
            print('❌ Error converting order: $e');
            // Skip invalid orders
          }
        }

        return orders;
      } else {
        throw Exception('Failed to load orders: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching customer orders: $e');
      rethrow;
    }
  }

  // ADD THIS METHOD: Implement logout from ProfileService

  Future<void> logout() async {
    // Implement your logout logic here
    // This depends on your AuthService implementation
    await authService.logout();
  }

  Future<List<CustomerOrder>> getCustomerServiceHistory() async {
    try {
      print('🔄 Fetching service history from: /api/customers/me/history');

      final response = await authService.get('/api/customers/me/history');

      print('📊 Service history response status: ${response['statusCode']}');

      if (response['success'] == true && response['statusCode'] == 200) {
        final data = response['body'];
        List<dynamic> ordersData = data['orders'] ?? data['data'] ?? [];

        print('✅ Service history loaded: ${ordersData.length} orders');
        return ordersData.map((json) => CustomerOrder.fromJson(json)).toList();
      } else {
        print('❌ History endpoint failed, trying orders endpoint...');
        return await _getOrdersFallback();
      }
    } catch (e) {
      print('💥 History endpoint error: $e');
      print('🔄 Falling back to orders endpoint...');
      return await _getOrdersFallback();
    }
  }

  // Fallback method using orders endpoint
  Future<List<CustomerOrder>> _getOrdersFallback() async {
    try {
      print('🔄 Trying fallback: /api/orders/my-orders');
      final response = await authService.get('/api/orders/my-orders');

      if (response['success'] == true && response['statusCode'] == 200) {
        final data = response['body'];
        List<dynamic> ordersData = data['orders'] ?? data['data'] ?? [];

        print('✅ Fallback loaded: ${ordersData.length} orders');
        return ordersData.map((json) => CustomerOrder.fromJson(json)).toList();
      } else {
        print('❌ Fallback also failed, loading sample data');
        return _getSampleOrders();
      }
    } catch (e) {
      print('💥 Fallback error: $e');
      return _getSampleOrders();
    }
  }

  // Sample data for demo
  List<CustomerOrder> _getSampleOrders() {
    print('📋 Loading sample data...');
    return [
      CustomerOrder(
        id: '1',
        serviceCategory: 'Errand Service',
        description: 'Grocery shopping at Shoprite',
        location: 'Lekki, Lagos',
        price: 5000.0,
        status: 'completed',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        scheduledDate: DateTime.now().subtract(const Duration(days: 2)),
        assignedAgent: 'agent123',
        agent: {
          'name': 'John Doe',
          'profileImage': '/uploads/profile.jpg'
        },
        isPublic: true,
        isDirectOffer: false,
      ),
      CustomerOrder(
        id: '2',
        serviceCategory: 'Babysitting Service',
        description: 'Child care for 4 hours',
        location: 'Victoria Island, Lagos',
        price: 12000.0,
        status: 'in-progress',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        scheduledDate: DateTime.now().add(const Duration(hours: 2)),
        assignedAgent: 'agent456',
        agent: {
          'name': 'Jane Smith',
          'profileImage': '/uploads/profile2.jpg'
        },
        isPublic: false,
        isDirectOffer: true,
      ),
      CustomerOrder(
        id: '3',
        serviceCategory: 'Personal Assistance',
        description: 'Daily tasks and errands',
        location: 'Ikeja, Lagos',
        price: 8000.0,
        status: 'accepted',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        assignedAgent: 'agent789',
        agent: {
          'name': 'Mike Johnson',
          'profileImage': '/uploads/profile3.jpg'
        },
        isPublic: true,
        isDirectOffer: false,
      ),
    ];
  }

  // CREATE ORDER METHODS FOR DIFFERENT SERVICE TYPES

  Future<CustomerOrder> createErrandOrder({
    required String errandType,
    required String fromAddress,
    required String toAddress,
    required String itemsDescription,
    required double totalAmount,
    String? receiverName,
    String? receiverPhone,
    String? specialInstructions,
    required String requestedAgentId,
  }) async {
    final orderData = {
      'serviceType': 'errand',
      'errandType': errandType,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'itemsDescription': itemsDescription,
      'totalAmount': totalAmount,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'specialInstructions': specialInstructions,
      'status': 'pending_agent_response',
      'requestedAgent': requestedAgentId,
    };

    // Remove null values
    orderData.removeWhere((key, value) => value == null);

    final result = await _createOrder(orderData);
    return CustomerOrder.fromJson(result['order'] ?? result);
  }

  Future<CustomerOrder> createDeliveryOrder({
    required String fromAddress,
    required String toAddress,
    required String serviceLevel,
    required double totalAmount,
    String? packageDescription,
    String? estimatedDeliveryTime,
    required String requestedAgentId,
  }) async {
    final orderData = {
      'serviceType': 'delivery',
      'deliveryType': 'pickup_delivery',
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'serviceLevel': serviceLevel,
      'totalAmount': totalAmount,
      'packageDescription': packageDescription,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'status': 'pending_agent_response',
      'requestedAgent': requestedAgentId,
    };

    // Remove null values
    orderData.removeWhere((key, value) => value == null);

    final result = await _createOrder(orderData);
    return CustomerOrder.fromJson(result['order'] ?? result);
  }

  Future<CustomerOrder> createMoversOrder({
    required String moveType,
    required String fromAddress,
    required String toAddress,
    required String vehicleType,
    required DateTime moveDate,
    required String timeSlot,
    required double totalAmount,
    String? itemsDescription,
    int? numberOfMovers,
    required String requestedAgentId,
  }) async {
    final orderData = {
      'serviceType': 'movers',
      'moveType': moveType,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'vehicleType': vehicleType,
      'moveDate': moveDate.toIso8601String(),
      'timeSlot': timeSlot,
      'totalAmount': totalAmount,
      'itemsDescription': itemsDescription,
      'numberOfMovers': numberOfMovers,
      'status': 'pending_agent_response',
      'requestedAgent': requestedAgentId,
    };

    // Remove null values
    orderData.removeWhere((key, value) => value == null);

    final result = await _createOrder(orderData);
    return CustomerOrder.fromJson(result['order'] ?? result);
  }

  // Generic order creation
  Future<Map<String, dynamic>> _createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: await _getHeaders(),
        body: json.encode(orderData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create order: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  // Add review to order
  Future<bool> addOrderReview({
    required String orderId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/orders/$orderId/review'),
        headers: await _getHeaders(),
        body: json.encode({
          'rating': rating,
          'comment': comment,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error adding review: $e');
      return false;
    }
  }

  // Get specific order by ID
  Future<CustomerOrder> getOrderById(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/$orderId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CustomerOrder.fromJson(data['order'] ?? data);
      } else {
        throw Exception('Failed to load order: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching order: $e');
      rethrow;
    }
  }

  // Update customer profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/customers/me'),
        headers: await _getHeaders(),
        body: json.encode(profileData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Upload profile image
  Future<bool> uploadProfileImage(String imagePath) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Not authenticated');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/customers/me/upload-photo'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('photo', imagePath));

      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print('Error uploading profile image: $e');
      return false;
    }
  }

  // Get recommended agents
  Future<List<dynamic>> getRecommendedAgents({
    String? serviceType,
    String? categoryId,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (serviceType != null && serviceType.isNotEmpty) {
        queryParams['serviceType'] = serviceType;
      }
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['categoryId'] = categoryId;
      }

      final queryString = Uri(queryParameters: queryParams).query;
      final url = '$baseUrl/api/agents/available${queryString.isNotEmpty ? '?$queryString' : ''}';

      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['agents'] ?? [];
      } else {
        throw Exception('Failed to load recommended agents: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recommended agents: $e');
      rethrow;
    }
  }
}