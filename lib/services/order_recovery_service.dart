// services/order_recovery_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OrderRecoveryService {
  static const String _pendingOrderKey = 'pending_order';
  static const String _pendingAgentSelectionKey = 'pending_agent_selection';
  static const String _draftOrdersKey = 'draft_orders';

  // Save pending order (order creation phase)
  static Future<void> savePendingOrder(Map<String, dynamic> orderData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recoveryData = {
        ...orderData,
        'savedAt': DateTime.now().toIso8601String(),
        'status': 'draft',
        'recoveryType': 'order_creation',
      };

      await prefs.setString(_pendingOrderKey, json.encode(recoveryData));
      print('💾 Pending order saved: ${orderData['serviceType'] ?? 'unknown'}');
    } catch (e) {
      print('❌ Error saving pending order: $e');
    }
  }

  // Get pending order
  static Future<Map<String, dynamic>?> getPendingOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingOrderJson = prefs.getString(_pendingOrderKey);

      if (pendingOrderJson != null) {
        final orderData = json.decode(pendingOrderJson) as Map<String, dynamic>;

        // Check if order is not too old (2 hours)
        final savedAt = DateTime.parse(orderData['savedAt'] as String);
        final now = DateTime.now();
        final difference = now.difference(savedAt);

        if (difference.inHours < 2) {
          print('🔄 Found recoverable pending order');
          return orderData;
        } else {
          await clearPendingOrder();
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting pending order: $e');
      return null;
    }
  }

  // Clear pending order
  static Future<void> clearPendingOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingOrderKey);
      print('🗑️ Pending order cleared');
    } catch (e) {
      print('❌ Error clearing pending order: $e');
    }
  }

  // Save agent selection progress
  static Future<void> saveAgentSelectionProgress({
    required String serviceType,
    required Map<String, dynamic> orderData,
    required double orderAmount,
    required Map<String, dynamic>? selectedAgent,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressData = {
        'serviceType': serviceType,
        'orderData': orderData,
        'orderAmount': orderAmount,
        'selectedAgent': selectedAgent,
        'savedAt': DateTime.now().toIso8601String(),
        'recoveryType': 'agent_selection',
      };

      await prefs.setString(_pendingAgentSelectionKey, json.encode(progressData));
      print('💾 Agent selection progress saved for: $serviceType');
    } catch (e) {
      print('❌ Error saving agent selection progress: $e');
    }
  }

  // Get agent selection progress
  static Future<Map<String, dynamic>?> getAgentSelectionProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_pendingAgentSelectionKey);

      if (progressJson != null) {
        final progressData = json.decode(progressJson) as Map<String, dynamic>;

        // Check if progress is not too old (2 hours)
        final savedAt = DateTime.parse(progressData['savedAt'] as String);
        final now = DateTime.now();
        final difference = now.difference(savedAt);

        if (difference.inHours < 2) {
          print('🔄 Found recoverable agent selection progress');
          return progressData;
        } else {
          await clearAgentSelectionProgress();
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting agent selection progress: $e');
      return null;
    }
  }

  // Clear agent selection progress
  static Future<void> clearAgentSelectionProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingAgentSelectionKey);
      print('🗑️ Agent selection progress cleared');
    } catch (e) {
      print('❌ Error clearing agent selection progress: $e');
    }
  }

  // Save draft order
  static Future<void> saveDraftOrder(Map<String, dynamic> orderData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = prefs.getString(_draftOrdersKey);
      final List<Map<String, dynamic>> drafts = draftsJson != null
          ? (json.decode(draftsJson) as List).cast<Map<String, dynamic>>()
          : [];

      // Add new draft
      drafts.add({
        ...orderData,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'savedAt': DateTime.now().toIso8601String(),
        'status': 'draft',
      });

      // Keep only recent drafts (last 10)
      final recentDrafts = drafts.length > 10 ? drafts.sublist(drafts.length - 10) : drafts;

      await prefs.setString(_draftOrdersKey, json.encode(recentDrafts));
      print('💾 Draft order saved');
    } catch (e) {
      print('❌ Error saving draft order: $e');
    }
  }

  // Get all draft orders
  static Future<List<Map<String, dynamic>>> getDraftOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = prefs.getString(_draftOrdersKey);

      if (draftsJson != null) {
        final drafts = (json.decode(draftsJson) as List).cast<Map<String, dynamic>>();

        // Filter out expired drafts (24 hours)
        final now = DateTime.now();
        final validDrafts = drafts.where((draft) {
          final savedAt = DateTime.parse(draft['savedAt'] as String);
          return now.difference(savedAt).inHours < 24;
        }).toList();

        // Update storage with only valid drafts
        if (validDrafts.length != drafts.length) {
          await prefs.setString(_draftOrdersKey, json.encode(validDrafts));
        }

        return validDrafts;
      }
      return [];
    } catch (e) {
      print('❌ Error getting draft orders: $e');
      return [];
    }
  }

  // Remove specific draft order
  static Future<void> removeDraftOrder(String draftId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = prefs.getString(_draftOrdersKey);

      if (draftsJson != null) {
        final drafts = (json.decode(draftsJson) as List).cast<Map<String, dynamic>>();
        final updatedDrafts = drafts.where((draft) => draft['id'] != draftId).toList();

        await prefs.setString(_draftOrdersKey, json.encode(updatedDrafts));
        print('🗑️ Draft order removed: $draftId');
      }
    } catch (e) {
      print('❌ Error removing draft order: $e');
    }
  }

  // Check if we have any recoverable orders
  static Future<bool> hasRecoverableOrders() async {
    final pendingOrder = await getPendingOrder();
    final agentProgress = await getAgentSelectionProgress();
    final drafts = await getDraftOrders();

    return pendingOrder != null || agentProgress != null || drafts.isNotEmpty;
  }

  // Clear all recovery data
  static Future<void> clearAllRecoveryData() async {
    await clearPendingOrder();
    await clearAgentSelectionProgress();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftOrdersKey);
    print('🗑️ All recovery data cleared');
  }
}