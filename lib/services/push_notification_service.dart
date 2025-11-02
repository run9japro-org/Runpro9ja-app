// services/push_notification_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static const String _deviceTokenKey = 'device_token';
  static const String _baseUrl = 'https://runpro9ja-pxqoa.ondigitalocean.app';

  // Initialize push notifications
  static Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    await _requestPermissions();

    // Android settings
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _onNotificationClick(response.payload);
      },
    );

    // Generate device token and register with backend
    await _generateAndRegisterDeviceToken();
  }

  static Future<void> _requestPermissions() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      print('✅ Notification permission granted');
    } else {
      print('❌ Notification permission denied');
    }
  }

  static Future<void> _generateAndRegisterDeviceToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String deviceToken = prefs.getString(_deviceTokenKey) ??
          'device_${DateTime.now().millisecondsSinceEpoch}';

      await prefs.setString(_deviceTokenKey, deviceToken);

      await _registerDeviceWithBackend(deviceToken);

      print('📱 Device token generated: $deviceToken');
    } catch (e) {
      print('❌ Error generating device token: $e');
    }
  }

  static Future<void> _registerDeviceWithBackend(String deviceToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/devices/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'deviceToken': deviceToken,
          'platform': 'mobile',
          'appVersion': '1.0.0',
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Device registered with backend');
      } else {
        print('❌ Failed to register device: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error registering device: $e');
    }
  }

  static void _onNotificationClick(String? payload) {
    if (payload != null) {
      print('📢 Notification clicked with payload: $payload');
      _handleNotificationNavigation(payload);
    }
  }

  static void _handleNotificationNavigation(String payload) {
    try {
      final data = json.decode(payload);
      final type = data['type'];
      final id = data['id'];

      switch (type) {
        case 'order_update':
        // Navigate to order details
          break;
        case 'new_message':
        // Navigate to chat
          break;
        case 'promotion':
        // Navigate to promotions
          break;
        default:
          break;
      }
    } catch (e) {
      print('❌ Error handling notification navigation: $e');
    }
  }

  // Show local notification
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'runpro9ja_channel',
      'RunPro9ja Notifications',
      channelDescription: 'Notifications for RunPro9ja app',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Schedule notification (FIXED VERSION)
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'runpro9ja_reminders',
      'RunPro9ja Reminders',
      channelDescription: 'Scheduled reminders for RunPro9ja',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert to TZDateTime
    final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Clear all notifications
  static Future<void> clearAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get device token
  static Future<String?> getDeviceToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceTokenKey);
  }
}