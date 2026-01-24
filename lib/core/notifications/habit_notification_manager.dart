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
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/notifications/notification_service.dart';
import 'package:lockin/core/notifications/notification_types.dart';

/// Manages habit-specific notifications
class HabitNotificationManager {
  factory HabitNotificationManager() => _instance;
  HabitNotificationManager._();
  static final HabitNotificationManager _instance =
      HabitNotificationManager._();

  final NotificationService _notificationService = NotificationService();

  /// Skip today's reminder if the habit was completed before reminder time
  Future<void> skipTodayReminderIfCompleted({
    required Habit habit,
    required String habitId,
    DateTime? completedAt,
  }) async {
    final reminderMinutes = habit.reminderMinutes;
    if (reminderMinutes == null) return;

    final completionTime = completedAt ?? DateTime.now();
    final reminderTime = TimeOfDay(
      hour: reminderMinutes ~/ 60,
      minute: reminderMinutes % 60,
    );
    final reminderDateTime = DateTime(
      completionTime.year,
      completionTime.month,
      completionTime.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    // Only skip if completion happened before today's reminder time
    if (!completionTime.isBefore(reminderDateTime)) {
      return;
    }

    // Skip only if this habit is scheduled for today
    if (!_isScheduledForToday(habit, completionTime)) {
      return;
    }

    NotificationRepeatInterval repeatInterval;
    List<int>? weekdays;
    final frequency = habit.frequency.toLowerCase();
    switch (frequency) {
      case 'daily':
        repeatInterval = NotificationRepeatInterval.daily;
        break;
      case 'weekly':
        repeatInterval = NotificationRepeatInterval.weekly;
        break;
      case 'monthly':
        repeatInterval = NotificationRepeatInterval.monthly;
        break;
      case 'custom':
        repeatInterval = NotificationRepeatInterval.custom;
        weekdays = _parseCustomWeekdays(habit.cue);
        break;
      default:
        repeatInterval = NotificationRepeatInterval.daily;
    }

    // Cancel existing reminders, then reschedule from next occurrence
    await cancelHabitReminders(habitId, customWeekdays: habit.cue);

    // Calculate when to reschedule based on frequency
    final DateTime scheduledFrom;
    switch (frequency) {
      case 'weekly':
        // Schedule for same day next week
        scheduledFrom = reminderDateTime.add(const Duration(days: 7));
        break;
      case 'monthly':
        if (_notificationService.timezoneManager.isInitialized) {
          scheduledFrom = _notificationService.timezoneManager
              .getNextMonthOccurrence(
                reminderTime,
                from: reminderDateTime.add(const Duration(minutes: 1)),
              );
        } else {
          scheduledFrom = reminderDateTime.add(const Duration(days: 30));
        }
        break;
      case 'custom':
        // Skip today's occurrence while keeping the reminder time unchanged
        scheduledFrom = reminderDateTime.add(const Duration(days: 1));
        break;
      default: // daily
        // Schedule for tomorrow
        scheduledFrom = reminderDateTime.add(const Duration(days: 1));
    }

    await _notificationService.scheduleHabitNotification(
      habitId: habitId,
      title: 'Habit Reminder',
      body: habit.title,
      time: reminderTime,
      repeatInterval: repeatInterval,
      customWeekdays: weekdays,
      payload: 'habit:$habitId',
      scheduledTime: scheduledFrom,
    );
  }

  /// Schedule notifications for a habit
  Future<bool> scheduleHabitReminder({
    required String habitId,
    required String habitTitle,
    required TimeOfDay reminderTime,
    required String frequency,
    String? customWeekdays,
  }) async {
    try {
      NotificationRepeatInterval repeatInterval;
      List<int>? weekdays;
      DateTime? scheduledTime;

      // Parse frequency and weekdays
      switch (frequency.toLowerCase()) {
        case 'daily':
          repeatInterval = NotificationRepeatInterval.daily;
          break;
        case 'weekly':
          repeatInterval = NotificationRepeatInterval.weekly;
          if (_notificationService.timezoneManager.isInitialized) {
            final weeklyDay =
                _parseWeekday(customWeekdays) ?? DateTime.now().weekday;
            scheduledTime = _notificationService.timezoneManager
                .getNextWeekdayOccurrence(reminderTime, weeklyDay);
          }
          break;
        case 'monthly':
          repeatInterval = NotificationRepeatInterval.monthly;
          if (_notificationService.timezoneManager.isInitialized) {
            scheduledTime = _notificationService.timezoneManager
                .getNextMonthOccurrence(reminderTime);
          }
          break;
        case 'custom':
          repeatInterval = NotificationRepeatInterval.custom;
          weekdays = _parseCustomWeekdays(customWeekdays);
          if (weekdays == null || weekdays.isEmpty) {
            debugPrint('Custom frequency requires at least one weekday');
            return false;
          }
          break;
        default:
          repeatInterval = NotificationRepeatInterval.daily;
      }

      final result = await _notificationService.scheduleHabitNotification(
        habitId: habitId,
        title: 'Habit Reminder',
        body: habitTitle,
        time: reminderTime,
        repeatInterval: repeatInterval,
        customWeekdays: weekdays,
        payload: 'habit:$habitId',
        scheduledTime: scheduledTime,
      );

      if (result.success) {
        return true;
      } else {
        debugPrint('Failed to schedule habit notification: ${result.error}');
        return false;
      }
    } catch (e) {
      debugPrint('Error scheduling habit notification: $e');
      return false;
    }
  }

  /// Cancel all notifications for a habit
  Future<bool> cancelHabitReminders(
    String habitId, {
    String? customWeekdays,
  }) async {
    try {
      final weekdays = _parseCustomWeekdays(customWeekdays);
      final result = await _notificationService.cancelHabitNotifications(
        habitId,
        customWeekdays: weekdays,
      );

      if (result.success) {
        return true;
      } else {
        debugPrint('Failed to cancel habit notifications: ${result.error}');
        return false;
      }
    } catch (e) {
      debugPrint('Error cancelling habit notifications: $e');
      return false;
    }
  }

  /// Schedule notifications for multiple habits with their reminder times
  Future<Map<String, bool>> scheduleMultipleHabitReminders(
    List<Map<String, dynamic>> habitsWithReminders,
  ) async {
    final results = <String, bool>{};

    for (final habitData in habitsWithReminders) {
      final habit = habitData['habit'] as Habit;
      final reminderTime = habitData['reminderTime'] as TimeOfDay?;

      if (reminderTime != null) {
        final success = await scheduleHabitReminder(
          habitId: habit.key.toString(),
          habitTitle: habit.title,
          reminderTime: reminderTime,
          frequency: habit.frequency,
          customWeekdays: habit.cue,
        );
        results[habit.key.toString()] = success;
      }
    }

    return results;
  }

  /// Reschedule a habit's notifications (cancel old, schedule new)
  Future<bool> rescheduleHabitReminder({
    required String habitId,
    required String habitTitle,
    required TimeOfDay reminderTime,
    required String frequency,
    String? customWeekdays,
  }) async {
    // Cancel existing notifications first
    await cancelHabitReminders(habitId, customWeekdays: customWeekdays);

    // Schedule new notifications
    return scheduleHabitReminder(
      habitId: habitId,
      habitTitle: habitTitle,
      reminderTime: reminderTime,
      frequency: frequency,
      customWeekdays: customWeekdays,
    );
  }

  /// Get habit-specific notification status
  Future<Map<String, dynamic>> getHabitNotificationStatus(
    String habitId,
  ) async {
    try {
      final healthCheck = await _notificationService.getHealthCheck();
      final pendingNotifications = await _notificationService
          .getPendingNotifications();

      // Find notifications for this habit
      final habitNotifications = pendingNotifications
          .where(
            (n) => n['payload']?.toString().contains('habit:$habitId') == true,
          )
          .toList();

      return {
        'habitId': habitId,
        'scheduledCount': habitNotifications.length,
        'notifications': habitNotifications,
        'serviceReady': await _notificationService.isReady(),
        'lastError': healthCheck['error'],
      };
    } catch (e) {
      return {'habitId': habitId, 'error': e.toString()};
    }
  }

  /// Parse custom weekdays string into list of integers
  List<int>? _parseCustomWeekdays(String? weekdaysString) {
    if (weekdaysString == null || weekdaysString.isEmpty) {
      return null;
    }

    try {
      final normalized =
          weekdaysString
              .split(',')
              .map((s) => int.tryParse(s.trim()))
              .where((i) => i != null)
              .map((i) {
                final value = i!;
                if (value >= 1 && value <= 7) return value;
                if (value >= 0 && value <= 6) return value + 1;
                return null;
              })
              .whereType<int>()
              .toSet()
              .toList()
            ..sort();
      return normalized;
    } catch (e) {
      debugPrint('Error parsing weekdays: $e');
      return null;
    }
  }

  bool _isScheduledForToday(Habit habit, DateTime date) {
    final frequency = habit.frequency.toLowerCase();
    if (frequency == 'weekly') {
      final weeklyDay = _parseWeekday(habit.cue);
      if (weeklyDay == null) return false;
      return weeklyDay == date.weekday;
    }
    if (frequency != 'custom') return true;

    final weekdays = _parseCustomWeekdays(habit.cue);
    if (weekdays == null || weekdays.isEmpty) return false;
    return weekdays.contains(date.weekday);
  }

  int? _parseWeekday(String? weekdayString) {
    if (weekdayString == null || weekdayString.isEmpty) return null;
    final value = int.tryParse(weekdayString.trim());
    if (value == null) return null;
    if (value >= 1 && value <= 7) return value;
    if (value >= 0 && value <= 6) return value + 1;
    return null;
  }

  /// Convert weekday list to readable string
  String formatWeekdays(List<int>? weekdays) {
    if (weekdays == null || weekdays.isEmpty) {
      return 'No specific days';
    }

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final names = weekdays
        .where((day) => day >= 1 && day <= 7)
        .map((day) => dayNames[day - 1])
        .toList();

    if (names.length == 7) {
      return 'Every day';
    } else if (names.length == 5 &&
        !names.contains('Sat') &&
        !names.contains('Sun')) {
      return 'Weekdays';
    } else {
      return names.join(', ');
    }
  }

  /// Get suggested reminder times based on habit category
  List<TimeOfDay> getSuggestedReminderTimes(String? category) {
    switch (category?.toLowerCase()) {
      case 'morning':
        return [
          const TimeOfDay(hour: 7, minute: 0),
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 9, minute: 0),
        ];
      case 'exercise':
        return [
          const TimeOfDay(hour: 6, minute: 30),
          const TimeOfDay(hour: 18, minute: 0),
          const TimeOfDay(hour: 19, minute: 0),
        ];
      case 'evening':
        return [
          const TimeOfDay(hour: 19, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
          const TimeOfDay(hour: 21, minute: 0),
        ];
      case 'work':
        return [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 17, minute: 0),
        ];
      default:
        return [
          const TimeOfDay(hour: 9, minute: 0),
          const TimeOfDay(hour: 12, minute: 0),
          const TimeOfDay(hour: 18, minute: 0),
        ];
    }
  }
}
