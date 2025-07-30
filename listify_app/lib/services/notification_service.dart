import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notifications;
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/todo_item.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;
  NotificationService._internal();

  final notifications.FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      notifications.FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Initialize the notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Android initialization settings
      const notifications.AndroidInitializationSettings initializationSettingsAndroid =
          notifications.AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const notifications.DarwinInitializationSettings initializationSettingsIOS =
          notifications.DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const notifications.InitializationSettings initializationSettings =
          notifications.InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      bool? initialized = await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = initialized ?? false;
      return _isInitialized;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize notifications: $e');
      }
      return false;
    }
  }

  // Handle notification tap
  void _onNotificationTapped(notifications.NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      // Handle notification tap - you can navigate to specific task
      if (kDebugMode) {
        print('Notification tapped with payload: $payload');
      }
      // TODO: Add navigation logic here if needed
    }
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      // Check if already granted
      PermissionStatus status = await Permission.notification.status;
      if (status.isGranted) return true;

      // Request permission
      status = await Permission.notification.request();
      
      // For iOS, also request through the plugin
      if (status.isGranted) {
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                notifications.IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }

      return status.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to request notification permissions: $e');
      }
      return false;
    }
  }

  // Schedule a notification for a todo item
  Future<bool> scheduleNotification(TodoItem item) async {
    if (!_isInitialized) {
      bool initialized = await initialize();
      if (!initialized) return false;
    }

    if (item.fullNotificationDateTime == null) return false;

    try {
      final scheduledDate = item.fullNotificationDateTime!;
      
      // Don't schedule if the time has already passed
      if (scheduledDate.isBefore(DateTime.now())) {
        return false;
      }

      // Convert to timezone aware datetime
      final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      // Create notification details
      const notifications.AndroidNotificationDetails androidPlatformChannelSpecifics =
          notifications.AndroidNotificationDetails(
        'todo_reminders',
        'Todo Reminders',
        channelDescription: 'Notifications for todo item deadlines',
        importance: notifications.Importance.high,
        priority: notifications.Priority.high,
        ticker: 'Todo Reminder',
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF09090B),
        enableVibration: true,
        playSound: true,
      );

      const notifications.DarwinNotificationDetails iOSPlatformChannelSpecifics =
          notifications.DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      const notifications.NotificationDetails platformChannelSpecifics = notifications.NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Generate notification content
      String title = '📋 Task Reminder';
      String body = item.title;
      
      if (item.description.isNotEmpty) {
        body += '\n${item.description}';
      }

      // Add priority indicator
      String priorityIcon = _getPriorityIcon(item.priority);
      title = '$priorityIcon $title';

      // Schedule the notification
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        item.id.hashCode, // Use hash of ID as unique notification ID
        title,
        body,
        tzScheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: notifications.AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            notifications.UILocalNotificationDateInterpretation.absoluteTime,
        payload: item.id,
      );

      if (kDebugMode) {
        print('Scheduled notification for ${item.title} at $scheduledDate');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to schedule notification: $e');
      }
      return false;
    }
  }

  // Cancel a notification for a todo item
  Future<bool> cancelNotification(String itemId) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(itemId.hashCode);
      
      if (kDebugMode) {
        print('Cancelled notification for item: $itemId');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cancel notification: $e');
      }
      return false;
    }
  }

  // Cancel all notifications
  Future<bool> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      
      if (kDebugMode) {
        print('Cancelled all notifications');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to cancel all notifications: $e');
      }
      return false;
    }
  }

  // Get pending notifications
  Future<List<notifications.PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get pending notifications: $e');
      }
      return [];
    }
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    PermissionStatus status = await Permission.notification.status;
    return status.isGranted;
  }

  // Helper method to get priority icon
  String _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.high:
        return '🔴';
      case Priority.medium:
        return '🟡';
      case Priority.low:
        return '🟢';
    }
  }

  // Show immediate notification (for testing)
  Future<void> showImmediateNotification(String title, String body) async {
    if (!_isInitialized) {
      await initialize();
    }

    const notifications.AndroidNotificationDetails androidPlatformChannelSpecifics =
        notifications.AndroidNotificationDetails(
      'todo_reminders',
      'Todo Reminders',
      channelDescription: 'Notifications for todo item deadlines',
      importance: notifications.Importance.high,
      priority: notifications.Priority.high,
    );

    const notifications.DarwinNotificationDetails iOSPlatformChannelSpecifics =
        notifications.DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notifications.NotificationDetails platformChannelSpecifics = notifications.NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
} 