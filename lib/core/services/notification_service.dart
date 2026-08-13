import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../models/medicine_model.dart';

/// Service for scheduling and managing local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Stream for foreground notification action events {actionId, payload}
  static final StreamController<Map<String, String?>> _actionController =
      StreamController<Map<String, String?>>.broadcast();
  static Stream<Map<String, String?>> get actionStream => _actionController.stream;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const String _channelId = 'meditrack_reminders_v2';
  static const String _channelName = 'Medicine Reminders';
  static const String _channelDesc = 'Reminders to take your medicines on time.';

  static const String _takenAction = 'TAKEN';
  static const String _snoozeAction = 'SNOOZE';
  static const String _dismissAction = 'DISMISS';

  /// Initialize notifications plugin and timezone data
  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
    );

    // Create notification channel for Android with custom sound
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
      sound: RawResourceNotificationSound('aaj_tak_music'),
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Request permissions
  Future<bool?> requestPermissions() async {
    return await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Schedule all notifications for a medicine
  Future<void> scheduleNotificationsForMedicine(MedicineModel medicine) async {
    if (!medicine.notificationEnabled || medicine.isPaused) return;

    // Cancel existing notifications for this medicine
    await cancelNotificationsForMedicine(medicine.id);

    for (int i = 0; i < medicine.times.length; i++) {
      final timeStr = medicine.times[i];
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final notifId = _getNotifId(medicine.id, i);
      await _scheduleDaily(
        id: notifId,
        medicine: medicine,
        hour: hour,
        minute: minute,
      );
    }
  }

  Future<void> _scheduleDaily({
    required int id,
    required MedicineModel medicine,
    required int hour,
    required int minute,
  }) async {
    // Use Dart's DateTime.now() which always returns correct device local time
    final nowLocal = DateTime.now();
    var scheduledLocal = DateTime(
      nowLocal.year,
      nowLocal.month,
      nowLocal.day,
      hour,
      minute,
    );

    // If time has already passed today, schedule for tomorrow
    if (scheduledLocal.isBefore(nowLocal)) {
      scheduledLocal = scheduledLocal.add(const Duration(days: 1));
    }

    // Convert local time → UTC → TZDateTime for scheduling
    final scheduledUtc = scheduledLocal.toUtc();
    final scheduledTz = tz.TZDateTime.from(scheduledUtc, tz.UTC);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceNotificationSound('aaj_tak_music'),
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        '${medicine.type.emoji} Time to take ${medicine.name} - ${medicine.dosage}',
        htmlFormatBigText: false,
        contentTitle: '💊 Time to Take Medicine',
        summaryText: medicine.mealPreference.displayName,
      ),
      actions: [
        const AndroidNotificationAction(
          _takenAction,
          '✅ Taken',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          _snoozeAction,
          '⏰ Snooze 10 min',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          _dismissAction,
          '✕ Dismiss',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'medicine_reminder',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'aaj_tak_music.mp3',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      '💊 Time to Take Medicine',
      '${medicine.name} · ${medicine.dosage}',
      scheduledTz,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: medicine.id,
    );
  }

  /// Cancel all notifications for a medicine
  Future<void> cancelNotificationsForMedicine(String medicineId) async {
    // Cancel up to 10 time slots per medicine
    for (int i = 0; i < 10; i++) {
      await _plugin.cancel(_getNotifId(medicineId, i));
    }
  }

  /// Schedule a snooze notification (10 minutes from now)
  Future<void> snoozeNotification(MedicineModel medicine) async {
    final snoozeTime = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 10));
    final snoozeId = _getSnoozeId(medicine.id);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceNotificationSound('aaj_tak_music'),
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.zonedSchedule(
      snoozeId,
      '⏰ Snoozed Reminder',
      '${medicine.name} · ${medicine.dosage}',
      snoozeTime,
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: medicine.id,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Show immediate notification (for testing)
  Future<void> showTestNotification(MedicineModel medicine) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceNotificationSound('aaj_tak_music'),
    );

    await _plugin.show(
      0,
      '💊 Time to Take Medicine',
      '${medicine.name} · ${medicine.dosage}',
      NotificationDetails(android: androidDetails),
      payload: medicine.id,
    );
  }

  /// Generate unique notification ID from medicine ID and time index
  int _getNotifId(String medicineId, int timeIndex) {
    return (medicineId.hashCode.abs() % 100000) * 10 + timeIndex;
  }

  int _getSnoozeId(String medicineId) {
    return (medicineId.hashCode.abs() % 100000) * 10 + 9;
  }

  /// Foreground handler — emits to actionStream so listeners can react
  void _onNotificationResponse(NotificationResponse response) {
    _actionController.add({
      'actionId': response.actionId,
      'payload': response.payload,
    });
  }

  /// Background handler — runs in separate isolate when app is killed/backgrounded
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) async {
    tz.initializeTimeZones();

    if (response.actionId == 'SNOOZE') {
      // Schedule a snooze notification 10 minutes from now
      final plugin = FlutterLocalNotificationsPlugin();
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      await plugin.initialize(const InitializationSettings(android: androidInit));

      final snoozeUtc = DateTime.now().toUtc().add(const Duration(minutes: 10));
      final snoozeTz = tz.TZDateTime.from(snoozeUtc, tz.UTC);

      try {
        await plugin.zonedSchedule(
          888888,
          '⏰ Snoozed Reminder',
          response.payload ?? 'Time to take your medicine',
          snoozeTz,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'meditrack_reminders_v2',
              'Medicine Reminders',
              channelDescription: 'Reminders to take your medicines on time.',
              importance: Importance.high,
              priority: Priority.high,
              playSound: true,
              sound: RawResourceNotificationSound('aaj_tak_music'),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (_) {}
    } else if (response.actionId == 'TAKEN') {
      // Store medicine ID — will be processed when app next opens
      if (response.payload != null) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final pending = prefs.getStringList('pending_taken') ?? [];
          if (!pending.contains(response.payload!)) {
            pending.add(response.payload!);
            await prefs.setStringList('pending_taken', pending);
          }
        } catch (_) {}
      }
    }
    // DISMISS: cancelNotification:true already handles this
  }

  /// Returns and clears any medicine IDs marked as taken via background notifications
  static Future<List<String>> getAndClearPendingTaken() async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList('pending_taken') ?? [];
    if (pending.isNotEmpty) await prefs.remove('pending_taken');
    return pending;
  }
}
