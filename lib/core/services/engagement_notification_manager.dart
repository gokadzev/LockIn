import 'package:flutter/material.dart';
import 'package:lockin/core/services/notification_service.dart';

class EngagementNotificationManager {
  final NotificationService _notificationService = NotificationService();

  Future<void> maybeSendEngagementNotification({
    required int streak,
    required int missedDays,
    required bool didHabitToday,
    required DateTime lastActiveDay,
    required TimeOfDay preferredTime,
    int? ignoredCount,
    int? tasksDone,
    int? habitsCompleted,
    int? goalsProgressPercent,
    bool isUserActive = false,
    String? lastNotificationType,
  }) async {
    final now = DateTime.now();
    // Smart suppression: don't notify if user is active or already did habit today
    if (isUserActive || didHabitToday) return;
    // Adaptive frequency: reduce if ignoredCount is high
    if ((ignoredCount ?? 0) > 3) return;
    // Personalized timing: use preferredTime (should be set from dashboard analysis)
    // Contextual content & multi-feature engagement
    String? title;
    if (tasksDone != null && tasksDone == 0) {
      title = 'Add your first task to get started!';
    } else if (habitsCompleted != null && habitsCompleted == 0) {
      title = 'Mark a habit as done today!';
    } else if (goalsProgressPercent != null && goalsProgressPercent < 50) {
      title = 'Make progress on your goals today!';
    } else if (streak < 3 && !didHabitToday) {
      title = 'Build your streak!';
    } else if (missedDays > 2) {
      title = "Let's get back on track!";
    } else if (streak >= 7) {
      title = 'Amazing streak! Keep it going!';
    }
    // Contextual message
    if (title != null) {
      await _notificationService.scheduleHabitNotification(
        id: now.millisecondsSinceEpoch,
        title: title,
        time: preferredTime,
        frequency: 'once',
      );
    }
  }
}
