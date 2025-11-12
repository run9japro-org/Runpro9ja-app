// services/local_notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

// Import your actual screens
import 'package:runpro_9ja/screens/home_screens/home_screen.dart';
import 'package:runpro_9ja/screens/service_history_screen.dart';
import 'package:runpro_9ja/screens/support_screen.dart';
import 'package:runpro_9ja/screens/home_screens/profile_screen.dart';
import 'package:runpro_9ja/services/customer_services.dart';
import 'package:runpro_9ja/auth/Auth_services/auth_service.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Navigation
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static Function(Map<String, String>)? onNotificationTapped;

  // Notification channels
  static const AndroidNotificationChannel _generalChannel = AndroidNotificationChannel(
    'runpro_general_channel',
    'RunPro General Notifications',
    description: 'General notifications for order updates and messages',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel _orderChannel = AndroidNotificationChannel(
    'runpro_order_channel',
    'RunPro Order Updates',
    description: 'Notifications for order status updates and agent responses',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel _paymentChannel = AndroidNotificationChannel(
    'runpro_payment_channel',
    'RunPro Payment Notifications',
    description: 'Notifications for payment status and transactions',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  Future<void> initialize({
    GlobalKey<NavigatorState>? navigatorKey,
    Function(Map<String, String>)? onNotificationTap,
  }) async {
    try {
      onNotificationTapped = onNotificationTap;
      if (navigatorKey != null) {
        LocalNotificationService.navigatorKey = navigatorKey;
      }

      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        settings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      await _createNotificationChannels();
      print('✅ Local Notification Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing Local Notification Service: $e');
    }
  }

  Future<void> _createNotificationChannels() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_generalChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_orderChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_paymentChannel);
  }

  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    print('📱 Notification tapped: ${response.payload}');
    _handleNotificationTap(response.payload);
  }

  static void _handleNotificationTap(String? payload) {
    if (payload == null) {
      print('⚠️ Notification tapped but no payload found');
      return;
    }

    try {
      final data = Map<String, String>.from(payload.split('&').fold({}, (map, element) {
        final keyValue = element.split('=');
        if (keyValue.length == 2) {
          map[keyValue[0]] = keyValue[1];
        }
        return map;
      }));

      print('🎯 Handling notification tap with data: $data');

      // Direct navigation
      _handleDirectNavigation(data);

      // Callback to MainPage
      if (onNotificationTapped != null) {
        print('🔔 Calling notification handler in MainPage');
        onNotificationTapped!(data);
      }

    } catch (e) {
      print('❌ Error handling notification tap: $e');
    }
  }

  static void _handleDirectNavigation(Map<String, String> data) {
    final type = data['type'];
    final orderId = data['orderId'];
    final context = navigatorKey.currentContext;

    if (context == null) {
      print('❌ No navigation context available');
      return;
    }

    print('🧭 Direct navigation for: $type');

    switch (type) {
      case 'order_accepted':
        _navigateToOrderAccepted(context, data);
        break;
      case 'order_rejected':
        _navigateToOrderRejected(context, data);
        break;
      case 'order_completed':
        _navigateToOrderCompleted(context, data);
        break;
      case 'payment_success':
        _navigateToPaymentSuccess(context, data);
        break;
      case 'payment_failed':
        _navigateToPaymentFailed(context, data);
        break;
      case 'agent_on_way':
        _navigateToAgentOnWay(context, data);
        break;
      case 'agent_arrived':
        _navigateToAgentArrived(context, data);
        break;
      case 'test':
        _showTestDialog(context, data);
        break;
      default:
        _showGenericDialog(context, data);
        break;
    }
  }

  // Navigation methods
  static void _navigateToOrderAccepted(BuildContext context, Map<String, String> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Order Accepted'),
            backgroundColor: Colors.green,
          ),
          body: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 80),
                SizedBox(height: 20),
                Text(
                  'Order Accepted! 🎉',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildInfoRow('Order ID:', data['orderId'] ?? 'N/A'),
                _buildInfoRow('Agent:', data['agentName'] ?? 'N/A'),
                _buildInfoRow('Service:', data['serviceType'] ?? 'N/A'),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Continue', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _navigateToOrderRejected(BuildContext context, Map<String, String> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Order Not Accepted'),
            backgroundColor: Colors.orange,
          ),
          body: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.cancel, color: Colors.orange, size: 80),
                SizedBox(height: 20),
                Text(
                  'Order Not Accepted',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildInfoRow('Order ID:', data['orderId'] ?? 'N/A'),
                _buildInfoRow('Agent:', data['agentName'] ?? 'N/A'),
                _buildInfoRow('Service:', data['serviceType'] ?? 'N/A'),
                SizedBox(height: 20),
                Text(
                  'The agent was unable to accept your order. Please try another agent.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Try Again', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _navigateToOrderCompleted(BuildContext context, Map<String, String> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Order Completed'),
            backgroundColor: Colors.green,
          ),
          body: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified, color: Colors.green, size: 80),
                SizedBox(height: 20),
                Text(
                  'Order Completed! ✅',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildInfoRow('Order ID:', data['orderId'] ?? 'N/A'),
                _buildInfoRow('Service:', data['serviceType'] ?? 'N/A'),
                SizedBox(height: 20),
                Text(
                  'Your service has been completed successfully. Thank you for using RunPro!',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Done', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _navigateToPaymentSuccess(BuildContext context, Map<String, String> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Payment Successful'),
            backgroundColor: Colors.green,
          ),
          body: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.payment, color: Colors.green, size: 80),
                SizedBox(height: 20),
                Text(
                  'Payment Successful! 💳',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildInfoRow('Order ID:', data['orderId'] ?? 'N/A'),
                _buildInfoRow('Service:', data['serviceType'] ?? 'N/A'),
                if (data['amount'] != null) _buildInfoRow('Amount:', '₦${data['amount']}'),
                SizedBox(height: 20),
                Text(
                  'Your payment was processed successfully.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Continue', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _navigateToPaymentFailed(BuildContext context, Map<String, String> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Payment Failed'),
            backgroundColor: Colors.red,
          ),
          body: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error, color: Colors.red, size: 80),
                SizedBox(height: 20),
                Text(
                  'Payment Failed ❌',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildInfoRow('Order ID:', data['orderId'] ?? 'N/A'),
                _buildInfoRow('Service:', data['serviceType'] ?? 'N/A'),
                if (data['amount'] != null) _buildInfoRow('Amount:', '₦${data['amount']}'),
                SizedBox(height: 20),
                Text(
                  'Your payment could not be processed. Please try again.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Try Again', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _navigateToAgentOnWay(BuildContext context, Map<String, String> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Agent On The Way'),
            backgroundColor: Colors.blue,
          ),
          body: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.directions_car, color: Colors.blue, size: 80),
                SizedBox(height: 20),
                Text(
                  'Agent On The Way! 🚗',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildInfoRow('Order ID:', data['orderId'] ?? 'N/A'),
                _buildInfoRow('Agent:', data['agentName'] ?? 'N/A'),
                _buildInfoRow('Service:', data['serviceType'] ?? 'N/A'),
                SizedBox(height: 20),
                Text(
                  'Your agent is on the way to your location.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Track Order', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _navigateToAgentArrived(BuildContext context, Map<String, String> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Agent Arrived'),
            backgroundColor: Colors.green,
          ),
          body: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: Colors.green, size: 80),
                SizedBox(height: 20),
                Text(
                  'Agent Has Arrived! 📍',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildInfoRow('Order ID:', data['orderId'] ?? 'N/A'),
                _buildInfoRow('Agent:', data['agentName'] ?? 'N/A'),
                _buildInfoRow('Service:', data['serviceType'] ?? 'N/A'),
                SizedBox(height: 20),
                Text(
                  'Your agent has arrived at your location.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Continue', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  static void _showTestDialog(BuildContext context, Map<String, String> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Test Notification'),
        content: Text('This is a test notification from RunPro 9ja!\n\nData: $data'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  static void _showGenericDialog(BuildContext context, Map<String, String> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notification'),
        content: Text('You have a new notification.\n\nType: ${data['type']}\nOrder ID: ${data['orderId']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Notification methods (keep all your existing ones)
  Future<void> showOrderAcceptedNotification({
    required String orderId,
    required String agentName,
    required String serviceType,
    required double amount,
  }) async {
    await _showNotification(
      id: _generateId('order_accepted_$orderId'),
      title: '🎉 Order Accepted!',
      body: '$agentName accepted your $serviceType order. Tap to proceed with payment.',
      payload: 'type=order_accepted&orderId=$orderId&agentName=$agentName&serviceType=$serviceType',
      channel: _orderChannel,
    );
  }

  Future<void> showOrderRejectedNotification({
    required String orderId,
    required String agentName,
    required String serviceType,
  }) async {
    await _showNotification(
      id: _generateId('order_rejected_$orderId'),
      title: '❌ Order Not Accepted',
      body: '$agentName was unable to accept your $serviceType order. Try another agent.',
      payload: 'type=order_rejected&orderId=$orderId&agentName=$agentName&serviceType=$serviceType',
      channel: _orderChannel,
    );
  }

  Future<void> showOrderCompletedNotification({
    required String orderId,
    required String serviceType,
    required double amount,
  }) async {
    await _showNotification(
      id: _generateId('order_completed_$orderId'),
      title: '✅ Order Completed!',
      body: 'Your $serviceType order has been completed successfully. Thank you for using RunPro!',
      payload: 'type=order_completed&orderId=$orderId&serviceType=$serviceType',
      channel: _orderChannel,
    );
  }

  Future<void> showPaymentSuccessNotification({
    required String orderId,
    required double amount,
    required String serviceType,
  }) async {
    await _showNotification(
      id: _generateId('payment_success_$orderId'),
      title: '💳 Payment Successful!',
      body: 'Payment of ₦${amount.toStringAsFixed(2)} for $serviceType was successful.',
      payload: 'type=payment_success&orderId=$orderId&amount=$amount&serviceType=$serviceType',
      channel: _paymentChannel,
    );
  }

  Future<void> showPaymentFailedNotification({
    required String orderId,
    required double amount,
    required String serviceType,
    String? reason,
  }) async {
    await _showNotification(
      id: _generateId('payment_failed_$orderId'),
      title: '❌ Payment Failed',
      body: 'Payment of ₦${amount.toStringAsFixed(2)} for $serviceType failed. ${reason ?? 'Please try again.'}',
      payload: 'type=payment_failed&orderId=$orderId&amount=$amount&serviceType=$serviceType',
      channel: _paymentChannel,
    );
  }

  Future<void> showAgentOnTheWayNotification({
    required String orderId,
    required String agentName,
    required String serviceType,
  }) async {
    await _showNotification(
      id: _generateId('agent_way_$orderId'),
      title: '🚗 Agent On The Way',
      body: '$agentName is on the way to your location for $serviceType service.',
      payload: 'type=agent_on_way&orderId=$orderId&agentName=$agentName&serviceType=$serviceType',
      channel: _orderChannel,
    );
  }

  Future<void> showAgentArrivedNotification({
    required String orderId,
    required String agentName,
    required String serviceType,
  }) async {
    await _showNotification(
      id: _generateId('agent_arrived_$orderId'),
      title: '📍 Agent Has Arrived',
      body: '$agentName has arrived at your location for $serviceType service.',
      payload: 'type=agent_arrived&orderId=$orderId&agentName=$agentName&serviceType=$serviceType',
      channel: _orderChannel,
    );
  }

  Future<void> showCustomNotification({
    required String title,
    required String body,
    String? payload,
    String? channelId,
  }) async {
    final channel = channelId == 'payment'
        ? _paymentChannel
        : channelId == 'order'
        ? _orderChannel
        : _generalChannel;

    await _showNotification(
      id: _generateId('custom_${DateTime.now().millisecondsSinceEpoch}'),
      title: title,
      body: body,
      payload: payload,
      channel: channel,
    );
  }

  Future<void> scheduleOrderReminder({
    required String orderId,
    required String serviceType,
    required DateTime scheduleTime,
  }) async {
    await _scheduleNotification(
      id: _generateId('reminder_$orderId'),
      title: '⏰ Order Reminder',
      body: 'Your $serviceType order is scheduled for today.',
      payload: 'type=order_reminder&orderId=$orderId&serviceType=$serviceType',
      scheduledDate: scheduleTime,
      channel: _orderChannel,
    );
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    required AndroidNotificationChannel channel,
  }) async {
    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(body),
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(id, title, body, details, payload: payload);
      print('📲 Local notification shown: $title');
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    required DateTime scheduledDate,
    required AndroidNotificationChannel channel,
  }) async {
    try {
      final tz.TZDateTime scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print('⏰ Scheduled notification: $title at $scheduledTime');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  int _generateId(String seed) {
    return seed.hashCode.abs();
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      return result ?? false;
    } catch (e) {
      print('❌ Error checking notification permission: $e');
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      final bool? iosGranted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return iosGranted ?? true;
    } catch (e) {
      print('❌ Error requesting notification permissions: $e');
      return false;
    }
  }
}