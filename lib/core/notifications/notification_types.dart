/// Defines all notification types and channels used in the app
enum NotificationChannel {
  habitReminders(
    'habit_reminders',
    'Habit Reminders',
    'Daily reminders for your habits',
  ),
  pomodoroSession(
    'pomodoro_session',
    'Pomodoro Sessions',
    'Pomodoro timer notifications',
  ),
  engagement(
    'engagement',
    'Engagement',
    'Motivational notifications to keep you engaged',
  ),
  achievements(
    'achievements',
    'Achievements',
    'Celebration of your progress and milestones',
  ),
  streaks(
    'streaks',
    'Streaks',
    'Streak maintenance and milestone notifications',
  );

  const NotificationChannel(this.id, this.name, this.description);

  final String id;
  final String name;
  final String description;
}

enum NotificationPriority { low, normal, high, urgent }

enum NotificationRepeatInterval { none, daily, weekly, custom }

/// Base class for all notification data
abstract class NotificationData {
  const NotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.channel,
    this.priority = NotificationPriority.normal,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final NotificationChannel channel;
  final NotificationPriority priority;
  final String? payload;
}

/// Immediate notification data
class InstantNotificationData extends NotificationData {
  const InstantNotificationData({
    required super.id,
    required super.title,
    required super.body,
    required super.channel,
    super.priority,
    super.payload,
  });
}

/// Scheduled notification data
class ScheduledNotificationData extends NotificationData {
  const ScheduledNotificationData({
    required super.id,
    required super.title,
    required super.body,
    required super.channel,
    required this.scheduledTime,
    this.repeatInterval = NotificationRepeatInterval.none,
    this.customWeekdays,
    super.priority,
    super.payload,
  });

  final DateTime scheduledTime;
  final NotificationRepeatInterval repeatInterval;
  final List<int>? customWeekdays; // 1-7 for Mon-Sun
}

/// Habit-specific notification data
class HabitNotificationData extends ScheduledNotificationData {
  const HabitNotificationData({
    required super.id,
    required super.title,
    required super.body,
    required super.scheduledTime,
    required this.habitId,
    super.repeatInterval = NotificationRepeatInterval.daily,
    super.customWeekdays,
    super.payload,
  }) : super(channel: NotificationChannel.habitReminders);

  final String habitId;
}

/// Pomodoro-specific notification data
class PomodoroNotificationData extends InstantNotificationData {
  const PomodoroNotificationData({
    required super.id,
    required super.title,
    required super.body,
    required this.sessionType,
    super.payload,
  }) : super(
         channel: NotificationChannel.pomodoroSession,
         priority: NotificationPriority.high,
       );

  final String sessionType; // 'work', 'break', 'long_break'
}

/// Engagement notification data
class EngagementNotificationData extends ScheduledNotificationData {
  const EngagementNotificationData({
    required super.id,
    required super.title,
    required super.body,
    required super.scheduledTime,
    required this.engagementType,
    this.metadata,
    super.payload,
  }) : super(
         channel: NotificationChannel.engagement,
         priority: NotificationPriority.normal,
       );

  final String engagementType; // 'streak', 'motivation', 'reminder'
  final Map<String, dynamic>? metadata;
}
