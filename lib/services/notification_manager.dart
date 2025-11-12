// services/notification_manager.dart
import 'package:runpro_9ja/services/notification_service.dart';
import 'package:runpro_9ja/services/local_notification_service.dart';
import 'package:runpro_9ja/models/notification_model.dart';

class NotificationManager {
  final NotificationService _backendService;
  final LocalNotificationService _localService;

  NotificationManager(this._backendService, this._localService);

  // Sync backend notifications with local notifications
  Future<void> syncNotifications() async {
    try {
      print('🔄 [NotificationManager] Starting sync...');

      // Get unread notifications from backend
      final NotificationResponse response = await _backendService.getNotifications(
        page: 1,
        limit: 50,
        isRead: false,
      );

      print('📊 [NotificationManager] Found ${response.notifications.length} unread notifications');

      // Show local notifications for unread backend notifications
      for (final notification in response.notifications) {
        print('📨 [NotificationManager] Processing: ${notification.title}');
        await _showLocalNotificationFromBackend(notification);
      }

      print('✅ [NotificationManager] Sync completed successfully');
    } catch (e) {
      print('❌ [NotificationManager] Error syncing notifications: $e');
    }
  }

  // Convert backend notification to local notification
  Future<void> _showLocalNotificationFromBackend(NotificationModel backendNotification) async {
    try {
      print('🎯 [NotificationManager] Converting backend notification: ${backendNotification.title}');

      // Only show notification if it's recent (last 24 hours)
      final now = DateTime.now();
      final notificationTime = backendNotification.createdAt;
      final difference = now.difference(notificationTime);

      if (difference.inHours > 24) {
        print('⏰ [NotificationManager] Skipping old notification: ${difference.inHours} hours old');
        return;
      }

      print('🔔 [NotificationManager] Notification is recent, showing local notification...');

      // Map backend notification type to local notification
      switch (backendNotification.type) {
        case NotificationType.orderUpdate:
          print('📦 [NotificationManager] Showing order update notification');
          await _localService.showOrderAcceptedNotification(
            orderId: _extractOrderId(backendNotification) ?? 'unknown',
            agentName: _extractAgentName(backendNotification) ?? 'Agent',
            serviceType: _extractServiceType(backendNotification) ?? 'Service',
            amount: _extractAmount(backendNotification) ?? 0.0,
          );
          break;

        case NotificationType.payment:
          print('💳 [NotificationManager] Showing payment notification');
          await _localService.showPaymentSuccessNotification(
            orderId: _extractOrderId(backendNotification) ?? 'unknown',
            amount: _extractAmount(backendNotification) ?? 0.0,
            serviceType: _extractServiceType(backendNotification) ?? 'Service',
          );
          break;

        case NotificationType.agentAssigned:
          print('👤 [NotificationManager] Showing agent assigned notification');
          await _localService.showAgentOnTheWayNotification(
            orderId: _extractOrderId(backendNotification) ?? 'unknown',
            agentName: _extractAgentName(backendNotification) ?? 'Agent',
            serviceType: _extractServiceType(backendNotification) ?? 'Service',
          );
          break;

        case NotificationType.deliveryStatus:
          print('✅ [NotificationManager] Showing delivery status notification');
          await _localService.showOrderCompletedNotification(
            orderId: _extractOrderId(backendNotification) ?? 'unknown',
            serviceType: _extractServiceType(backendNotification) ?? 'Service',
            amount: _extractAmount(backendNotification) ?? 0.0,
          );
          break;

        default:
          print('📢 [NotificationManager] Showing generic notification');
          await _localService.showCustomNotification(
            title: backendNotification.title,
            body: backendNotification.message,
            payload: 'type=${backendNotification.type.name}&orderId=${_extractOrderId(backendNotification)}',
          );
          break;
      }

      print('🎉 [NotificationManager] Successfully showed local notification');

      // ⚠️ REMOVED: Don't mark as read immediately after showing local notification
      // This was causing the notifications to disappear from your NotificationScreen
      // await _backendService.markAsRead(backendNotification.id);

    } catch (e) {
      print('❌ [NotificationManager] Error converting backend notification to local: $e');
      print('📋 [NotificationManager] Notification details: ${backendNotification.toJson()}');
    }
  }

  // Helper methods to extract data from backend notification
  String? _extractOrderId(NotificationModel notification) {
    final orderId = notification.data['orderId']?.toString() ??
        notification.data['order_id']?.toString();
    print('🔍 [NotificationManager] Extracted orderId: $orderId');
    return orderId;
  }

  String? _extractAgentName(NotificationModel notification) {
    final agentName = notification.data['agentName']?.toString() ??
        notification.data['agent_name']?.toString() ??
        notification.data['agent']?.toString();
    print('🔍 [NotificationManager] Extracted agentName: $agentName');
    return agentName;
  }

  String? _extractServiceType(NotificationModel notification) {
    final serviceType = notification.data['serviceType']?.toString() ??
        notification.data['service_type']?.toString() ??
        notification.data['service']?.toString();
    print('🔍 [NotificationManager] Extracted serviceType: $serviceType');
    return serviceType;
  }

  double? _extractAmount(NotificationModel notification) {
    final amount = notification.data['amount'] ??
        notification.data['totalAmount'] ??
        notification.data['price'];

    double? result;
    if (amount is double) result = amount;
    if (amount is int) result = amount.toDouble();
    if (amount is String) result = double.tryParse(amount);

    print('🔍 [NotificationManager] Extracted amount: $result');
    return result;
  }

  // Check for new notifications periodically
  Future<void> checkForNewNotifications() async {
    try {
      print('🔍 [NotificationManager] Checking for new notifications...');
      final unreadCount = await _backendService.getUnreadCount();
      print('📊 [NotificationManager] Unread count: $unreadCount');

      if (unreadCount > 0) {
        await syncNotifications();
      } else {
        print('ℹ️ [NotificationManager] No new notifications found');
      }
    } catch (e) {
      print('❌ [NotificationManager] Error checking for new notifications: $e');
    }
  }

  // ✅ ADD THIS: Test method to simulate backend notifications
  Future<void> testBackendNotification() async {
    print('🧪 [NotificationManager] Testing backend notification conversion...');

    // Create a test notification that matches your backend format
    final testNotification = NotificationModel(
      id: 'test-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user-123',
      title: 'Test Backend Notification',
      message: 'This is a test from the backend to check if local notifications work',
      type: NotificationType.orderUpdate,
      priority: NotificationPriority.medium,
      data: {
        'orderId': 'order-test-123',
        'agentName': 'Test Agent John',
        'serviceType': 'Cleaning Service',
        'amount': 7500.0,
      },
      isRead: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _showLocalNotificationFromBackend(testNotification);
  }
}