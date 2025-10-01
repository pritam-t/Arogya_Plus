// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;
//
// class NotificationHelper {
//   NotificationHelper._();
//
//   static final NotificationHelper getInstance = NotificationHelper._();
//
//   final FlutterLocalNotificationsPlugin _notificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   // Initialize notification system
//   Future<void> init() async {
//     // Initialize timezone
//     tz.initializeTimeZones();
//
//     // Android initialization settings
//     const AndroidInitializationSettings androidSettings =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     // iOS initialization settings
//     const DarwinInitializationSettings iosSettings =
//     DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     // Combined initialization settings
//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//
//     // Initialize the plugin
//     await _notificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: _onNotificationTap,
//     );
//
//     // Request permissions for iOS
//     await _requestIOSPermissions();
//
//     // Request permissions for Android 13+
//     await _requestAndroidPermissions();
//   }
//
//   // Request iOS permissions
//   Future<void> _requestIOSPermissions() async {
//     await _notificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         IOSFlutterLocalNotificationsPlugin>()
//         ?.requestPermissions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   }
//
//   // Request Android permissions (for Android 13+)
//   Future<void> _requestAndroidPermissions() async {
//     final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
//     _notificationsPlugin.resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>();
//
//     await androidImplementation?.requestNotificationsPermission();
//   }
//
//   // Handle notification tap
//   void _onNotificationTap(NotificationResponse response) {
//     // Handle notification tap - navigate to specific screen if needed
//     // You can use response.payload to pass data
//     print('Notification tapped: ${response.payload}');
//   }
//
//   // Schedule a medication notification
//   Future<void> scheduleMedicationNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduleTime,
//   }) async {
//     // Convert DateTime to TZDateTime
//     final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
//       scheduleTime,
//       tz.local,
//     );
//
//     // Android notification details
//     const AndroidNotificationDetails androidDetails =
//     AndroidNotificationDetails(
//       'medication_channel',
//       'Medication Reminders',
//       channelDescription: 'Notifications for medication reminders',
//       importance: Importance.high,
//       priority: Priority.high,
//       playSound: true,
//       enableVibration: true,
//       icon: '@mipmap/ic_launcher',
//     );
//
//     // iOS notification details
//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
//
//     // Combined notification details
//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//
//     // Schedule the notification
//     await _notificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       scheduledDate,
//       notificationDetails,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       payload: 'medication_$id',
//     );
//   }
//
//   // Schedule repeating daily notification at specific time
//   Future<void> scheduleDailyNotification({
//     required int id,
//     required String title,
//     required String body,
//     required int hour,
//     required int minute,
//   }) async {
//     // Create time for today
//     final now = DateTime.now();
//     var scheduledDate = DateTime(
//       now.year,
//       now.month,
//       now.day,
//       hour,
//       minute,
//     );
//
//     // If the time has passed today, schedule for tomorrow
//     if (scheduledDate.isBefore(now)) {
//       scheduledDate = scheduledDate.add(const Duration(days: 1));
//     }
//
//     final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
//       scheduledDate,
//       tz.local,
//     );
//
//     const AndroidNotificationDetails androidDetails =
//     AndroidNotificationDetails(
//       'medication_channel',
//       'Medication Reminders',
//       channelDescription: 'Notifications for medication reminders',
//       importance: Importance.high,
//       priority: Priority.high,
//       playSound: true,
//       enableVibration: true,
//     );
//
//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
//
//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//
//     // Schedule daily notification
//     await _notificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       scheduledTZDate,
//       notificationDetails,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       matchDateTimeComponents: DateTimeComponents.time,
//       payload: 'medication_$id',
//     );
//   }
//
//   // Schedule notification on specific days of week
//   Future<void> scheduleWeeklyNotification({
//     required int id,
//     required String title,
//     required String body,
//     required int hour,
//     required int minute,
//     required List<int> weekdays, // 1 = Monday, 7 = Sunday
//   }) async {
//     // Cancel existing notification first
//     await cancelNotification(id);
//
//     // Schedule for each weekday
//     for (int i = 0; i < weekdays.length; i++) {
//       final uniqueId = id * 10 + i; // Create unique ID for each day
//       final now = DateTime.now();
//
//       // Find next occurrence of this weekday
//       var scheduledDate = _findNextWeekday(now, weekdays[i], hour, minute);
//
//       final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
//         scheduledDate,
//         tz.local,
//       );
//
//       const AndroidNotificationDetails androidDetails =
//       AndroidNotificationDetails(
//         'medication_channel',
//         'Medication Reminders',
//         channelDescription: 'Notifications for medication reminders',
//         importance: Importance.high,
//         priority: Priority.high,
//         playSound: true,
//         enableVibration: true,
//       );
//
//       const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       );
//
//       const NotificationDetails notificationDetails = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );
//
//       await _notificationsPlugin.zonedSchedule(
//         uniqueId,
//         title,
//         body,
//         scheduledTZDate,
//         notificationDetails,
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//         matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
//         payload: 'medication_$id',
//       );
//     }
//   }
//
//   // Helper function to find next occurrence of a weekday
//   DateTime _findNextWeekday(DateTime from, int desiredWeekday, int hour, int minute) {
//     var scheduledDate = DateTime(from.year, from.month, from.day, hour, minute);
//
//     while (scheduledDate.weekday != desiredWeekday || scheduledDate.isBefore(from)) {
//       scheduledDate = scheduledDate.add(const Duration(days: 1));
//     }
//
//     return scheduledDate;
//   }
//
//   // Cancel a specific notification
//   Future<void> cancelNotification(int id) async {
//     await _notificationsPlugin.cancel(id);
//
//     // Cancel all related notifications (for weekly schedules)
//     for (int i = 0; i < 7; i++) {
//       await _notificationsPlugin.cancel(id * 10 + i);
//     }
//   }
//
//   // Cancel all notifications
//   Future<void> cancelAllNotifications() async {
//     await _notificationsPlugin.cancelAll();
//   }
//
//   // Get pending notifications
//   Future<List<PendingNotificationRequest>> getPendingNotifications() async {
//     return await _notificationsPlugin.pendingNotificationRequests();
//   }
//
//   // Show immediate notification (for testing)
//   Future<void> showImmediateNotification({
//     required int id,
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidDetails =
//     AndroidNotificationDetails(
//       'medication_channel',
//       'Medication Reminders',
//       channelDescription: 'Notifications for medication reminders',
//       importance: Importance.high,
//       priority: Priority.high,
//       playSound: true,
//       enableVibration: true,
//     );
//
//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
//
//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//
//     await _notificationsPlugin.show(
//       id,
//       title,
//       body,
//       notificationDetails,
//       payload: 'medication_$id',
//     );
//   }
// }