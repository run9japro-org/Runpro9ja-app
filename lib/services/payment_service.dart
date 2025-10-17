// lib/services/payment_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/Auth_services/auth_service.dart';

class PaymentMethod {
  final String id;
  final String type; // card, bank, wallet
  final String brand; // visa, mastercard, gtbank, etc.
  final String last4;
  final String? expiryMonth;
  final String? expiryYear;
  bool isDefault;
  final String? authorizationCode;
  final DateTime? createdAt;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.brand,
    required this.last4,
    this.expiryMonth,
    this.expiryYear,
    this.isDefault = false,
    this.authorizationCode,
    this.createdAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? 'card',
      brand: json['brand'] ?? '',
      last4: json['last4'] ?? '',
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
      isDefault: json['isDefault'] ?? false,
      authorizationCode: json['authorizationCode'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'brand': brand,
      'last4': last4,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'isDefault': isDefault,
      'authorizationCode': authorizationCode,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  String get displayName {
    switch (type) {
      case 'card':
        return '$brand •••• $last4';
      case 'bank':
        return '$brand •••• $last4';
      case 'wallet':
        return '$brand Wallet';
      default:
        return brand;
    }
  }

  String get expiryDisplay {
    if (expiryMonth != null && expiryYear != null) {
      return '$expiryMonth/${expiryYear!.substring(2)}';
    }
    return '';
  }

  String get iconName {
    switch (type) {
      case 'card':
        return 'credit_card';
      case 'bank':
        return 'account_balance';
      case 'wallet':
        return 'account_balance_wallet';
      default:
        return 'payment';
    }
  }

  String get colorHex {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'FF1A1F71';
      case 'mastercard':
        return 'FFEB001B';
      case 'verve':
        return 'FF690F00';
      case 'gtbank':
        return 'FF660099';
      case 'firstbank':
        return 'FF003366';
      default:
        return 'FF2E7D32';
    }
  }
}
class PaymentService {
  final AuthService authService;
  static const String baseUrl = "https://runpro9ja-pxqoa.ondigitalocean.app";

  PaymentService(this.authService);

  // Initialize payment through YOUR backend
  Future<Map<String, dynamic>> initializePayment({
    required String orderId,
    required double amount,
    required String agentId,
    String method = 'paystack',
  }) async {
    try {
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/create'),
        headers: headers,
        body: json.encode({
          'orderId': orderId,
          'amount': amount,
          'agentId': agentId,
          'method': method,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'payment': data['payment'],
          'authorizationUrl': data['authorizationUrl'],
          'reference': data['payment']['reference'],
        };
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to initialize payment');
      }
    } catch (e) {
      print('❌ Payment initialization error: $e');
      rethrow;
    }
  }

  // Verify payment through YOUR backend (not directly with Paystack)
  Future<Map<String, dynamic>> verifyPayment(String reference) async {
    try {
      final headers = await _getHeaders();

      // Call YOUR backend to verify payment
      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/verify/$reference'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'status': data['status'] ?? 'pending',
          'message': data['message'] ?? 'Payment verification in progress',
          'reference': data['reference'],
        };
      } else {
        throw Exception('Payment verification failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Payment verification error: $e');
      throw Exception('Payment verification error: $e');
    }
  }

  // ========== PAYMENT METHODS CRUD OPERATIONS ==========

  Future<List<PaymentMethod>> getSavedPaymentMethods() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/payment-methods'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> methods = data['paymentMethods'] ?? [];
        return methods.map((method) => PaymentMethod.fromJson(method)).toList();
      } else {
        // Return mock data for development
        return _getMockPaymentMethods();
      }
    } catch (e) {
      print('❌ Error loading payment methods: $e');
      return _getMockPaymentMethods();
    }
  }

  Future<void> savePaymentMethod(Map<String, dynamic> paymentData) async {
    try {
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/api/payment-methods'),
        headers: headers,
        body: json.encode(paymentData),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to save payment method: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error saving payment method: $e');
      // For development, succeed silently
    }
  }

  Future<void> setDefaultPaymentMethod(String methodId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.patch(
        Uri.parse('$baseUrl/api/payment-methods/$methodId/default'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to set default payment method: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error setting default payment method: $e');
    }
  }

  Future<void> deletePaymentMethod(String methodId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse('$baseUrl/api/payment-methods/$methodId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete payment method: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting payment method: $e');
    }
  }

  // ========== HELPER METHODS ==========

  Future<Map<String, String>> _getHeaders() async {
    try {
      final token = await authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      print('❌ Error getting headers: $e');
      rethrow;
    }
  }

  // Mock data for development
  List<PaymentMethod> _getMockPaymentMethods() {
    return [
      PaymentMethod(
        id: '1',
        type: 'card',
        brand: 'Visa',
        last4: '4242',
        expiryMonth: '12',
        expiryYear: '2025',
        isDefault: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      PaymentMethod(
        id: '2',
        type: 'card',
        brand: 'Mastercard',
        last4: '8888',
        expiryMonth: '08',
        expiryYear: '2024',
        isDefault: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }
}