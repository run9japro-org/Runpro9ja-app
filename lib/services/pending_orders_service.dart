// services/pending_orders_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PendingOrdersService {
  static const String _pendingOrdersKey = 'pending_orders';
  static const String _waitingForAgentKey = 'waiting_for_agent';

  // Save order that's waiting for agent acceptance
  static Future<void> saveWaitingForAgentOrder({
    required String orderId,
    required String serviceType,
    required Map<String, dynamic> orderData,
    required double amount,
    required String agentId,
    required String agentName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingOrder = {
        'orderId': orderId,
        'serviceType': serviceType,
        'orderData': orderData,
        'amount': amount,
        'agentId': agentId,
        'agentName': agentName,
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'waiting_for_agent',
        'canPay': false, // Can't pay until agent accepts
      };

      await prefs.setString(_waitingForAgentKey, json.encode(pendingOrder));
      print('💾 Saved order waiting for agent: $orderId');
    } catch (e) {
      print('❌ Error saving waiting order: $e');
    }
  }

  // Get order waiting for agent
  static Future<Map<String, dynamic>?> getWaitingForAgentOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orderJson = prefs.getString(_waitingForAgentKey);

      if (orderJson != null) {
        final orderData = json.decode(orderJson) as Map<String, dynamic>;

        // Check if order is not too old (24 hours)
        final createdAt = DateTime.parse(orderData['createdAt'] as String);
        final now = DateTime.now();
        final difference = now.difference(createdAt);

        if (difference.inHours < 24) {
          print('🔄 Found order waiting for agent: ${orderData['orderId']}');
          return orderData;
        } else {
          await clearWaitingForAgentOrder();
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting waiting order: $e');
      return null;
    }
  }

  // Update order status when agent accepts
  static Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    bool canPay = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orderJson = prefs.getString(_waitingForAgentKey);

      if (orderJson != null) {
        final orderData = json.decode(orderJson) as Map<String, dynamic>;

        if (orderData['orderId'] == orderId) {
          orderData['status'] = status;
          orderData['canPay'] = canPay;
          orderData['updatedAt'] = DateTime.now().toIso8601String();

          await prefs.setString(_waitingForAgentKey, json.encode(orderData));
          print('📝 Updated order status: $orderId -> $status');
        }
      }
    } catch (e) {
      print('❌ Error updating order status: $e');
    }
  }

  // Clear waiting order
  static Future<void> clearWaitingForAgentOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_waitingForAgentKey);
      print('🗑️ Cleared waiting for agent order');
    } catch (e) {
      print('❌ Error clearing waiting order: $e');
    }
  }

  // Check if we can proceed to payment
  static Future<bool> canProceedToPayment(String orderId) async {
    try {
      final order = await getWaitingForAgentOrder();
      if (order != null && order['orderId'] == orderId) {
        return order['canPay'] == true;
      }
      return false;
    } catch (e) {
      print('❌ Error checking payment eligibility: $e');
      return false;
    }
  }
}