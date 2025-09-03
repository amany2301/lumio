import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// Notification service for Lumio debug interface
class LumioNotification {
  static const String _channelId = 'lumio_debug_channel';
  static const String _channelName = 'Lumio Debug';
  static const String _channelDescription = 'Lumio debugging interface notification';
  static const int _notificationId = 1001;

  static FlutterLocalNotificationsPlugin? _notifications;
  static bool _isInitialized = false;

  /// Initialize notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    _notifications = FlutterLocalNotificationsPlugin();

    // Request notification permission
    if (await Permission.notification.request().isGranted) {
      // Create notification channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      );

      await _notifications!.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

      _isInitialized = true;
    }
  }

  /// Show Lumio debug notification
  static Future<void> showDebugNotification() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!kDebugMode) return; // Only show in debug mode

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      icon: 'ic_notification', // We'll create this icon
      color: Color(0xFF2196F3), // Blue color for Lumio
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      ),
    );

    await _notifications!.show(
      _notificationId,
      'Lumio Debug',
      'Tap to open debugging interface',
      notificationDetails,
    );
  }

  /// Hide Lumio debug notification
  static Future<void> hideDebugNotification() async {
    if (!_isInitialized) return;

    await _notifications!.cancel(_notificationId);
  }

  /// Update notification with log counts
  static Future<void> updateNotificationWithCounts(Map<String, int> counts) async {
    if (!_isInitialized || !kDebugMode) return;

    final totalLogs = counts.values.fold(0, (sum, count) => sum + count);
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      icon: 'ic_notification',
      color: Color(0xFF2196F3),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      ),
    );

    await _notifications!.show(
      _notificationId,
      'Lumio Debug',
      'Network: ${counts['networkCalls'] ?? 0} | API: ${counts['apiResponses'] ?? 0} | Crashes: ${counts['crashes'] ?? 0} | ANRs: ${counts['anrs'] ?? 0}',
      notificationDetails,
    );
  }

  /// Check if notification is supported
  static bool get isSupported => _isInitialized;

  /// Dispose notification service
  static void dispose() {
    _isInitialized = false;
    _notifications = null;
  }
}
