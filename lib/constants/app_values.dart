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
