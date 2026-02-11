/*
 *     Copyright (C) 2026 Valeri Gokadze
 *
 *     LockIn is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     LockIn is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lockin/core/notifications/notification_id_manager.dart';
import 'package:lockin/core/notifications/notification_types.dart';
import 'package:timezone/timezone.dart' as tz;

/// Result of a notification operation
class NotificationResult {
  const NotificationResult({
    required this.success,
    this.error,
    this.notificationId,
  });
  factory NotificationResult.success([int? id]) {
    return NotificationResult(success: true, notificationId: id);
  }

  factory NotificationResult.failure(String error) {
    return NotificationResult(success: false, error: error);
  }

  final bool success;
  final String? error;
  final int? notificationId;
}

/// Low-level notification platform interface
class NotificationPlatform {
  factory NotificationPlatform() => _instance;
  NotificationPlatform._();
  static final NotificationPlatform _instance = NotificationPlatform._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Initialize the notification platform
  Future<NotificationResult> initialize() async {
    if (_initialized) return NotificationResult.success();

    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initSettings = InitializationSettings(android: androidSettings);

      final result = await _plugin.initialize(
        settings: initSettings,
        // onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (result != true) {
        return NotificationResult.failure(
          'Failed to initialize notification plugin',
        );
      }

      // Create notification channels
      await _createNotificationChannels();

      _initialized = true;
      return NotificationResult.success();
    } catch (e) {
      return NotificationResult.failure('Initialization error: $e');
    }
  }

  /// Show an immediate notification
  Future<NotificationResult> showNotification(
    InstantNotificationData data,
  ) async {
    if (!_initialized) {
      final initResult = await initialize();
      if (!initResult.success) return initResult;
    }

    try {
      final details = _buildNotificationDetails(data.channel, data.priority);
      await _plugin.show(
        id: data.id,
        title: data.title,
        body: data.body,
        notificationDetails: details,
        payload: data.payload,
      );
      return NotificationResult.success(data.id);
    } catch (e) {
      return NotificationResult.failure('Failed to show notification: $e');
    }
  }

  /// Schedule a notification
  Future<NotificationResult> scheduleNotification(
    ScheduledNotificationData data,
  ) async {
    if (!_initialized) {
      final initResult = await initialize();
      if (!initResult.success) return initResult;
    }

    try {
      final details = _buildNotificationDetails(data.channel, data.priority);
      final scheduledDate = tz.TZDateTime.from(data.scheduledTime, tz.local);

      switch (data.repeatInterval) {
        case NotificationRepeatInterval.none:
          await _plugin.zonedSchedule(
            id: data.id,
            title: data.title,
            body: data.body,
            scheduledDate: scheduledDate,
            notificationDetails: details,
            payload: data.payload,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
          break;

        case NotificationRepeatInterval.daily:
          await _plugin.zonedSchedule(
            id: data.id,
            title: data.title,
            body: data.body,
            scheduledDate: scheduledDate,
            notificationDetails: details,
            payload: data.payload,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.time,
          );
          break;

        case NotificationRepeatInterval.weekly:
          await _plugin.zonedSchedule(
            id: data.id,
            title: data.title,
            body: data.body,
            scheduledDate: scheduledDate,
            notificationDetails: details,
            payload: data.payload,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
          break;

        case NotificationRepeatInterval.monthly:
          await _plugin.zonedSchedule(
            id: data.id,
            title: data.title,
            body: data.body,
            scheduledDate: scheduledDate,
            notificationDetails: details,
            payload: data.payload,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
          );
          break;

        case NotificationRepeatInterval.custom:
          if (data.customWeekdays != null) {
            // Schedule for each selected weekday
            for (final weekday in data.customWeekdays!) {
              final weekdayScheduled = _getNextWeekdaySchedule(
                data.scheduledTime,
                weekday,
              );
              final instanceId = NotificationIdManager.weeklyInstanceId(
                data.id,
                weekday,
              );
              await _plugin.zonedSchedule(
                id: instanceId,
                title: data.title,
                body: data.body,
                scheduledDate: weekdayScheduled,
                notificationDetails: details,
                payload: data.payload,
                androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
                matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
              );
            }
          }
          break;
      }

      return NotificationResult.success(data.id);
    } catch (e) {
      return NotificationResult.failure('Failed to schedule notification: $e');
    }
  }

  /// Cancel a notification
  Future<NotificationResult> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id: id);
      return NotificationResult.success(id);
    } catch (e) {
      return NotificationResult.failure('Failed to cancel notification: $e');
    }
  }

  /// Cancel multiple notifications
  Future<NotificationResult> cancelNotifications(List<int> ids) async {
    try {
      for (final id in ids) {
        await _plugin.cancel(id: id);
      }
      return NotificationResult.success();
    } catch (e) {
      return NotificationResult.failure('Failed to cancel notifications: $e');
    }
  }

  /// Cancel all notifications
  Future<NotificationResult> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
      return NotificationResult.success();
    } catch (e) {
      return NotificationResult.failure(
        'Failed to cancel all notifications: $e',
      );
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _plugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Failed to get pending notifications: $e');
      return [];
    }
  }

  /// Get platform-specific notification details
  NotificationDetails _buildNotificationDetails(
    NotificationChannel channel,
    NotificationPriority priority,
  ) {
    final importance = _mapPriorityToImportance(priority);
    final androidPriority = _mapPriorityToAndroidPriority(priority);

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: importance,
      priority: androidPriority,
    );

    return NotificationDetails(android: androidDetails);
  }

  Importance _mapPriorityToImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.normal:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.urgent:
        return Importance.max;
    }
  }

  Priority _mapPriorityToAndroidPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.normal:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.urgent:
        return Priority.max;
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    for (final channel in NotificationChannel.values) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            AndroidNotificationChannel(
              channel.id,
              channel.name,
              description: channel.description,
            ),
          );
    }
  }

  /// Calculate next occurrence of a specific weekday
  tz.TZDateTime _getNextWeekdaySchedule(DateTime baseTime, int weekday) {
    final reference = tz.TZDateTime.from(baseTime, tz.local);
    final currentWeekday = reference.weekday;

    var daysUntilTarget = (weekday - currentWeekday) % 7;
    if (daysUntilTarget == 0) {
      // Same weekday - check if time has passed
      final todayAtTime = tz.TZDateTime(
        tz.local,
        reference.year,
        reference.month,
        reference.day,
        baseTime.hour,
        baseTime.minute,
      );
      if (todayAtTime.isAfter(reference)) {
        return todayAtTime;
      } else {
        daysUntilTarget = 7; // Schedule for next week
      }
    }

    final targetDate = reference.add(Duration(days: daysUntilTarget));
    return tz.TZDateTime(
      tz.local,
      targetDate.year,
      targetDate.month,
      targetDate.day,
      baseTime.hour,
      baseTime.minute,
    );
  }

  // /// Handle notification taps
  // void _onNotificationTapped(NotificationResponse response) {
  //   debugPrint('Notification tapped: ${response.payload}');
  //   // Implement navigation based on payload
  // }
}
