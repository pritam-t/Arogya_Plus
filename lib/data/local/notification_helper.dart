import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Set to your timezone

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print('Notification tapped: ${response.payload}');
      },
    );

    _isInitialized = true;
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Request notification permission
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        if (!status.isGranted) return false;
      }

      // Request exact alarm permission (Android 12+)
      if (await Permission.scheduleExactAlarm.isDenied) {
        final status = await Permission.scheduleExactAlarm.request();
        if (!status.isGranted) {
          print('⚠️ Exact alarm permission denied. Notifications may not work accurately.');
        }
      }

      return true;
    } else if (Platform.isIOS) {
      final bool? result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    return true;
  }

  // Schedule a medication reminder
  Future<void> scheduleMedicationReminder({
    required int medicationId,
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
    required int reminderMinutesBefore,
    required bool isMorning, // true for morning, false for night
  }) async {
    await initialize();

    // Calculate notification time (subtract reminder minutes)
    final notificationTime = scheduledTime.subtract(Duration(minutes: reminderMinutesBefore));

    // Don't schedule if the time has already passed today
    if (notificationTime.isBefore(DateTime.now())) {
      print('Notification time has passed for today, skipping: $medicationName');
      return;
    }

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(notificationTime, tz.local);

    // Create unique notification ID (medication ID + 0 for morning, 1 for night)
    final int notificationId = medicationId * 10 + (isMorning ? 0 : 1);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Notifications for medication reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification_sound.aiff',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final String timeLabel = isMorning ? 'Morning' : 'Night';
    final String body = reminderMinutesBefore > 0
        ? 'Take $dosage in $reminderMinutesBefore minutes ($timeLabel)'
        : 'Time to take $dosage ($timeLabel)';

    await _notifications.zonedSchedule(
      notificationId,
      '💊 Medication Reminder',
      '$medicationName - $body',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'medication_$medicationId',
    );

    print('Scheduled notification for $medicationName at $scheduledDate');
  }

  // Schedule daily repeating reminder
  Future<void> scheduleDailyMedicationReminder({
    required int medicationId,
    required String medicationName,
    required String dosage,
    required int hour,
    required int minute,
    required int reminderMinutesBefore,
    required bool isMorning,
    List<int>? customDays, // null for everyday, list of weekdays (1-7) for custom
  }) async {
    await initialize();

    // Calculate notification time
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    // If time has passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final notificationTime = scheduledTime.subtract(Duration(minutes: reminderMinutesBefore));
    final int notificationId = medicationId * 10 + (isMorning ? 0 : 1);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Notifications for medication reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final String timeLabel = isMorning ? 'Morning' : 'Night';
    final String body = reminderMinutesBefore > 0
        ? 'Take $dosage in $reminderMinutesBefore minutes ($timeLabel)'
        : 'Time to take $dosage ($timeLabel)';

    if (customDays == null || customDays.isEmpty) {
      // Everyday - use daily schedule
      await _notifications.zonedSchedule(
        notificationId,
        '💊 Medication Reminder',
        '$medicationName - $body',
        tz.TZDateTime.from(notificationTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'medication_$medicationId',
      );
    } else {
      // Custom days - schedule for each specified day
      for (int i = 0; i < 7; i++) {
        final nextDate = scheduledTime.add(Duration(days: i));
        if (customDays.contains(nextDate.weekday)) {
          final notificationDateTime = nextDate.subtract(Duration(minutes: reminderMinutesBefore));
          await _notifications.zonedSchedule(
            notificationId + i * 100, // Unique ID for each day
            '💊 Medication Reminder',
            '$medicationName - $body',
            tz.TZDateTime.from(notificationDateTime, tz.local),
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: 'medication_$medicationId',
          );
        }
      }
    }

    print('Scheduled daily notification for $medicationName');
  }

  // Cancel specific medication notification
  Future<void> cancelMedicationNotification(int medicationId, bool isMorning) async {
    final int notificationId = medicationId * 10 + (isMorning ? 0 : 1);
    await _notifications.cancel(notificationId);

    // Cancel custom day notifications too
    for (int i = 0; i < 7; i++) {
      await _notifications.cancel(notificationId + i * 100);
    }
  }

  // Cancel all notifications for a medication
  Future<void> cancelAllMedicationNotifications(int medicationId) async {
    await cancelMedicationNotification(medicationId, true); // Morning
    await cancelMedicationNotification(medicationId, false); // Night
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}