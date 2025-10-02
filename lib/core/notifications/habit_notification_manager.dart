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

      // Parse frequency and weekdays
      switch (frequency.toLowerCase()) {
        case 'daily':
          repeatInterval = NotificationRepeatInterval.daily;
          break;
        case 'weekly':
          repeatInterval = NotificationRepeatInterval.weekly;
          break;
        case 'custom':
          repeatInterval = NotificationRepeatInterval.custom;
          weekdays = _parseCustomWeekdays(customWeekdays);
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
      );

      if (result.success) {
        debugPrint('Scheduled habit notification for $habitTitle');
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
        debugPrint('Cancelled habit notifications for $habitId');
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
      return weekdaysString
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .where((i) => i != null && i >= 1 && i <= 7)
          .cast<int>()
          .toList();
    } catch (e) {
      debugPrint('Error parsing weekdays: $e');
      return null;
    }
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
