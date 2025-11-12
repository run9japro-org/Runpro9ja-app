// services/app_recovery_handler.dart
import 'package:flutter/material.dart';
import 'order_recovery_service.dart';

class AppRecoveryHandler {
  static Future<void> checkForRecoverableSessions(BuildContext context) async {
    try {
      print('🔄 Checking for recoverable sessions...');

      // Wait a bit for app to initialize
      await Future.delayed(const Duration(seconds: 1));

      final hasRecoverableOrders = await OrderRecoveryService.hasRecoverableOrders();

      if (!hasRecoverableOrders) {
        print('✅ No recoverable sessions found');
        return;
      }

      // Check for agent selection progress first (most recent)
      final agentProgress = await OrderRecoveryService.getAgentSelectionProgress();
      if (agentProgress != null) {
        _showAgentSelectionRecoveryDialog(context, agentProgress);
        return;
      }

      // Check for pending orders
      final pendingOrder = await OrderRecoveryService.getPendingOrder();
      if (pendingOrder != null) {
        _showPendingOrderRecoveryDialog(context, pendingOrder);
        return;
      }

    } catch (e) {
      print('❌ Error checking for recoverable sessions: $e');
    }
  }

  static void _showAgentSelectionRecoveryDialog(
      BuildContext context,
      Map<String, dynamic> progressData
      ) {
    final serviceType = progressData['serviceType'] as String;
    final orderData = progressData['orderData'] as Map<String, dynamic>;
    final orderAmount = progressData['orderAmount'] as double;
    final selectedAgent = progressData['selectedAgent'] as Map<String, dynamic>?;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.autorenew, color: Colors.orange),
              SizedBox(width: 8),
              Text('Continue Your Order?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You were selecting an agent for:',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                '${serviceType.toUpperCase()} • ₦${orderAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (selectedAgent != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Selected: ${selectedAgent['displayName']}',
                  style: TextStyle(fontSize: 14, color: Colors.green[700]),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Would you like to continue where you left off?',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _declineAgentSelectionRecovery(progressData);
              },
              child: const Text('Start New'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _acceptAgentSelectionRecovery(context, progressData);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  static void _showPendingOrderRecoveryDialog(
      BuildContext context,
      Map<String, dynamic> pendingOrder
      ) {
    final serviceCategory = pendingOrder['serviceType']?.toString() ??
        pendingOrder['serviceCategory']?.toString() ??
        'a service';
    final orderAmount = pendingOrder['totalAmount'] ?? pendingOrder['orderAmount'] ?? 0.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.shopping_cart, color: Colors.orange),
              SizedBox(width: 8),
              Text('Continue Your Order?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You were creating an order for:',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                '${serviceCategory.toString().toUpperCase()} • ₦${orderAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Would you like to continue where you left off?',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _declinePendingOrderRecovery(pendingOrder);
              },
              child: const Text('Start New'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _acceptPendingOrderRecovery(context, pendingOrder);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  static void _acceptAgentSelectionRecovery(
      BuildContext context,
      Map<String, dynamic> progressData
      ) {
    final serviceType = progressData['serviceType'] as String;
    final orderData = progressData['orderData'] as Map<String, dynamic>;
    final orderAmount = progressData['orderAmount'] as double;

    print('✅ User accepted agent selection recovery');

    // Import your AgentSelectionScreen here
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => AgentSelectionScreen(
    //       serviceType: serviceType,
    //       orderData: orderData,
    //       orderAmount: orderAmount,
    //       fromRecovery: true,
    //     ),
    //   ),
    // );

    // Show temporary message since we can't import the screen here
    _showTemporaryMessage(context, 'Navigating to agent selection...');
  }

  static void _declineAgentSelectionRecovery(Map<String, dynamic> progressData) {
    // Convert to draft and clear the progress
    OrderRecoveryService.saveDraftOrder({
      ...progressData['orderData'],
      'serviceType': progressData['serviceType'],
      'orderAmount': progressData['orderAmount'],
      'recoveredAt': DateTime.now().toIso8601String(),
      'status': 'draft_declined',
    });

    OrderRecoveryService.clearAgentSelectionProgress();
    print('❌ User declined agent selection recovery - saved as draft');
  }

  static void _acceptPendingOrderRecovery(
      BuildContext context,
      Map<String, dynamic> pendingOrder
      ) {
    print('✅ User accepted pending order recovery');

    // Navigate back to order creation with recovered data
    // This would navigate to the appropriate order creation screen
    // based on the service type in pendingOrder

    _showTemporaryMessage(context, 'Navigating to order creation...');
  }

  static void _declinePendingOrderRecovery(Map<String, dynamic> pendingOrder) {
    // Convert to draft and clear the pending order
    OrderRecoveryService.saveDraftOrder({
      ...pendingOrder,
      'recoveredAt': DateTime.now().toIso8601String(),
      'status': 'draft_declined',
    });
    OrderRecoveryService.clearPendingOrder();
    print('❌ User declined pending order recovery - saved as draft');
  }

  static void _showTemporaryMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );

    // Close the dialog
    Navigator.of(context).pop();
  }
}