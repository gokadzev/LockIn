import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lockin/core/utils/timezone_helper.dart';
import 'package:lockin/widgets/lockin_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Notifications',
      channelDescription: 'Notifications for Pomodoro events',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, title, body, details);
  }

  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _tzInitialized = false;
  String? _resolvedTz;

  Future<void> init(BuildContext context) async {
    // Request notification permission on app startup
    final status = await Permission.notification.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      debugPrint('Notification permission denied');
      // Prompt user to open app settings to enable notifications
      if (context.mounted) {
        await showDialog(
          context: context,
          builder: (ctx) => LockinDialog(
            title: const Text('Enable Notifications'),
            content: const Text(
              'To receive notifications, please enable notification permission in your device settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
      return;
    }
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);
    await _initializeTimeZonesOnce();
  }

  Future<void> _initializeTimeZonesOnce() async {
    if (!_tzInitialized) {
      tz.initializeTimeZones();
      String? resolved;
      try {
        resolved = await TimezoneHelper.getLocalTimezone();
        // Some platforms return values that may not exist in the tz database; guard.
        tz.setLocalLocation(tz.getLocation(resolved));
      } catch (e) {
        // Fallback to tz.local.name if the platform channel failed or name is absent
        try {
          final timeZoneName = tz.local.name;
          tz.setLocalLocation(tz.getLocation(timeZoneName));
          resolved = timeZoneName;
        } catch (e2) {
          // As last resort, set UTC
          tz.setLocalLocation(tz.getLocation('UTC'));
          resolved = 'UTC';
          debugPrint('Timezone resolution fallback used: $e2');
        }
      }
      _tzInitialized = true;
      _resolvedTz = resolved;
    }
  }

  Future<void> scheduleHabitNotification({
    required int id,
    required String title,
    required TimeOfDay time,
    required String frequency,
    String? cue,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'habit_reminder',
        'Habit Reminders',
        channelDescription: 'Reminders for your habits',
        importance: Importance.max,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);
      final now = DateTime.now();
      await _initializeTimeZonesOnce();
      if (frequency == 'daily') {
        await _plugin.zonedSchedule(
          id,
          'Habit Reminder',
          title,
          _nextInstanceOfTime(time),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else if (frequency == 'weekly') {
        // Schedule for the same weekday as now by default. _nextInstanceOfWeekday
        // expects a Dart weekday (1=Mon..7=Sun).
        await _plugin.zonedSchedule(
          id,
          'Habit Reminder',
          title,
          _nextInstanceOfWeekday(time, now.weekday),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      } else if (frequency == 'custom' && cue != null) {
        // For custom frequency, schedule for each selected weekday
        // Expect cue entries to be in Dart weekday format (1=Mon..7=Sun) or
        // numeric strings; normalize values to 1..7.
        final weekdays = cue
            .split(',')
            .map((e) => int.tryParse(e))
            .where((e) => e != null)
            .map((e) {
              var v = e!;
              // If caller used 0..6 mapping, convert 0->7 (Sun) and 1..6 -> 1..6
              if (v >= 0 && v <= 6) {
                v = v == 0 ? 7 : v; // convert 0 (Sun) to 7
              }
              // Ensure within 1..7
              if (v < 1) v = 1;
              if (v > 7) v = 7;
              return v;
            })
            .cast<int>()
            .toList();

        for (final weekday in weekdays) {
          await _plugin.zonedSchedule(
            id + weekday,
            'Habit Reminder',
            title,
            _nextInstanceOfWeekday(time, weekday),
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
      } else if (frequency == 'once') {
        // For one-time notifications (engagement notifications)
        await _plugin.zonedSchedule(
          id,
          'Habit Reminder',
          title,
          _nextInstanceOfTime(time),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelHabitNotifications(int baseId, String? cue) async {
    await _plugin.cancel(baseId);

    // Cancel custom weekday notifications if they exist
    if (cue != null) {
      final weekdays = cue
          .split(',')
          .map((e) => int.tryParse(e))
          .where((e) => e != null)
          .map((e) {
            var v = e!;
            if (v >= 0 && v <= 6) {
              v = v == 0 ? 7 : v; // convert 0 (Sun) to 7
            }
            if (v < 1) v = 1;
            if (v > 7) v = 7;
            return v;
          })
          .cast<int>()
          .toList();

      for (final weekday in weekdays) {
        await _plugin.cancel(baseId + weekday);
      }
    }
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfWeekday(TimeOfDay time, int weekday) {
    final now = tz.TZDateTime.now(tz.local);
    // Expect weekday in Dart format (1=Mon..7=Sun). Compute days to add.
    final targetWeekday = weekday;
    var daysToAdd = (targetWeekday - now.weekday) % 7;
    if (daysToAdd == 0) {
      // If it's the same weekday, check if time has passed
      final todayScheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      if (todayScheduled.isAfter(now)) {
        daysToAdd = 0;
      } else {
        daysToAdd = 7;
      }
    }
    final scheduled = now.add(Duration(days: daysToAdd));
    return tz.TZDateTime(
      tz.local,
      scheduled.year,
      scheduled.month,
      scheduled.day,
      time.hour,
      time.minute,
    );
  }

  /// Lightweight health check for notification delivery readiness.
  /// Returns a map with permission state, number of pending notifications and timezone init flag.
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final status = await Permission.notification.status;
      // pendingNotificationRequests returns a list of pending notifications scheduled by the plugin
      final pending = await _plugin.pendingNotificationRequests();
      return {
        'permission': status.toString(),
        'granted': status.isGranted,
        'pendingCount': pending.length,
        'tzInitialized': _tzInitialized,
        'resolvedTz': _resolvedTz,
      };
    } catch (e) {
      debugPrint('Notification health check failed: $e');
      return {'error': e.toString()};
    }
  }
}
