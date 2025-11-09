import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:lockin/core/models/goal.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/models/task.dart';
import 'package:lockin/core/notifications/engagement_notification_manager.dart';
import 'package:lockin/core/services/user_activity_tracker.dart';
import 'package:lockin/core/utils/hive_background_init.dart';
import 'package:workmanager/workmanager.dart';

const String engagementTaskName = 'dailyEngagementTask';
const String habitReminderTaskName = 'habitReminderTask';

/// Background task handler for notifications
@pragma('vm:entry-point')
void notificationBackgroundHandler() {
  Workmanager().executeTask((task, inputData) async {
    try {
      debugPrint('Background task started: $task');

      await initHiveForBackground();
      await _registerHiveAdapters();

      switch (task) {
        case engagementTaskName:
          return await _handleEngagementTask();
        case habitReminderTaskName:
          return await _handleHabitReminderTask();
        default:
          debugPrint('Unknown background task: $task');
          return false;
      }
    } catch (e) {
      debugPrint('Background task error: $e');
      return false;
    }
  });
}

/// Register all Hive adapters needed for background tasks
Future<void> _registerHiveAdapters() async {
  final adapters = <TypeAdapter<dynamic>>[
    TaskAdapter(),
    HabitAdapter(),
    GoalAdapter(),
    MilestoneAdapter(),
  ];

  for (final adapter in adapters) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }
}

/// Handle daily engagement notifications
Future<bool> _handleEngagementTask() async {
  try {
    // Open necessary boxes
    final habitBox = await _openBox<Habit>('habits');
    final taskBox = await _openBox<Task>('tasks');
    final goalBox = await _openBox<Goal>('goals');
    final settingsBox = await _openBox('settings');

    // Get preferred notification time
    final preferredTime = _getPreferredTime(settingsBox);

    // Check if user was recently active
    final isUserActive = await UserActivityTracker.wasActiveWithin(
      const Duration(hours: 2),
    );

    // Get data for analysis
    final habits = habitBox?.values.toList() ?? <Habit>[];
    final tasks = taskBox?.values.toList() ?? <Task>[];
    final goals = goalBox?.values.toList() ?? <Goal>[];

    // Send engagement notification
    final manager = EngagementNotificationManager();
    final success = await manager.sendEngagementNotificationBackground(
      habits: habits,
      tasks: tasks,
      goals: goals,
      preferredTime: preferredTime,
      isUserActive: isUserActive,
    );

    debugPrint('Engagement task completed: $success');
    return success;
  } catch (e) {
    debugPrint('Error in engagement task: $e');
    return false;
  }
}

/// Handle habit reminder notifications (if needed for specific cases)
Future<bool> _handleHabitReminderTask() async {
  try {
    // This could be used for special habit reminders that need background processing
    // For now, most habit reminders are handled by the standard scheduler
    debugPrint('Habit reminder task completed');
    return true;
  } catch (e) {
    debugPrint('Error in habit reminder task: $e');
    return false;
  }
}

/// Safely open a Hive box with error handling
Future<Box<T>?> _openBox<T>(String boxName) async {
  try {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName);
    } else {
      return await Hive.openBox<T>(boxName);
    }
  } catch (e) {
    debugPrint('Error opening box $boxName: $e');
    return null;
  }
}

/// Get preferred notification time from settings
TimeOfDay _getPreferredTime(Box? settingsBox) {
  const defaultTime = TimeOfDay(hour: 9, minute: 0);

  if (settingsBox == null || !settingsBox.containsKey('engagementTime')) {
    return defaultTime;
  }

  try {
    final timeMap = settingsBox.get('engagementTime') as Map?;
    if (timeMap != null &&
        timeMap['hour'] != null &&
        timeMap['minute'] != null) {
      return TimeOfDay(
        hour: timeMap['hour'] as int,
        minute: timeMap['minute'] as int,
      );
    }
  } catch (e) {
    debugPrint('Error parsing preferred time: $e');
  }

  return defaultTime;
}

/// Background task manager for easy setup
class NotificationBackgroundManager {
  factory NotificationBackgroundManager() => _instance;
  NotificationBackgroundManager._();
  static final NotificationBackgroundManager _instance =
      NotificationBackgroundManager._();

  bool _initialized = false;

  /// Initialize background tasks
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      await Workmanager().initialize(notificationBackgroundHandler);

      // Register daily engagement task
      await Workmanager().registerPeriodicTask(
        engagementTaskName,
        engagementTaskName,
        frequency: const Duration(hours: 24),
        initialDelay: const Duration(minutes: 5),
        constraints: Constraints(
          networkType: NetworkType.unmetered,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );

      _initialized = true;
      debugPrint('Background notification tasks initialized');
      return true;
    } catch (e) {
      debugPrint('Error initializing background tasks: $e');
      return false;
    }
  }

  /// Cancel all background tasks
  Future<void> cancelAllTasks() async {
    try {
      await Workmanager().cancelAll();
      _initialized = false;
      debugPrint('All background tasks cancelled');
    } catch (e) {
      debugPrint('Error cancelling background tasks: $e');
    }
  }

  /// Update engagement task frequency
  Future<bool> updateEngagementFrequency(Duration frequency) async {
    try {
      // Cancel existing task
      await Workmanager().cancelByUniqueName(engagementTaskName);

      // Register with new frequency
      await Workmanager().registerPeriodicTask(
        engagementTaskName,
        engagementTaskName,
        frequency: frequency,
        initialDelay: const Duration(minutes: 5),
      );

      debugPrint(
        'Updated engagement task frequency to ${frequency.inHours} hours',
      );
      return true;
    } catch (e) {
      debugPrint('Error updating engagement frequency: $e');
      return false;
    }
  }

  /// Get status of background tasks
  Future<Map<String, dynamic>> getStatus() async {
    return {
      'initialized': _initialized,
      'engagementTaskRegistered': _initialized,
      'lastError': null, // Could track last error if needed
    };
  }
}
