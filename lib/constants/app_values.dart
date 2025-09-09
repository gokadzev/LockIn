/// App-wide constant values for Lockin Productivity
class AppValues {
  // XP Values
  static const int taskCompletionXP = 10;
  static const int habitCompletionXP = 5;
  static const int milestoneCompletionXP = 15;
  static const int sessionCompletionXP = 10;

  // Pomodoro Settings
  static const int defaultWorkMinutes = 25;
  static const int defaultBreakMinutes = 5;

  // Notification IDs - Use sequential IDs instead of hashCodes
  static const int pomodoroNotificationId = 1001;
  static const int habitReminderBaseId = 2000;
  static const int engagementNotificationId = 3000;

  // Task Priorities
  static const Map<int, String> taskPriorities = {
    3: 'High',
    2: 'Medium',
    1: 'Low',
  };

  // Task Priority Colors

  // Animation Durations
  static const Duration notificationAnimationDuration = Duration(
    milliseconds: 400,
  );
  static const Duration standardAnimationDuration = Duration(milliseconds: 300);

  // Background Task Settings
  static const Duration backgroundTaskFrequency = Duration(hours: 24);
  static const Duration backgroundTaskInitialDelay = Duration(minutes: 1);

  // User Activity Threshold
  static const Duration userActivityThreshold = Duration(hours: 1);
}
