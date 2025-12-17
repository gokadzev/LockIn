import 'package:flutter/material.dart';
import 'package:lockin/core/notifications/notification_id_manager.dart';
import 'package:lockin/core/notifications/notification_permission_manager.dart';
import 'package:lockin/core/notifications/notification_platform.dart';
import 'package:lockin/core/notifications/notification_types.dart';
import 'package:lockin/core/notifications/timezone_manager.dart';
import 'package:permission_handler/permission_handler.dart';

/// Main notification service that provides a clean API for the app
class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._();
  static final NotificationService _instance = NotificationService._();

  final NotificationPlatform _platform = NotificationPlatform();
  final NotificationPermissionManager _permissionManager =
      NotificationPermissionManager();
  final NotificationIdManager _idManager = NotificationIdManager();
  final TimezoneManager _timezoneManager = TimezoneManager();

  bool _initialized = false;

  /// Initialize the notification service
  Future<bool> initialize(BuildContext context) async {
    if (_initialized) return true;

    try {
      // Initialize timezone first
      final timezoneSuccess = await _timezoneManager.initialize();
      if (!timezoneSuccess) {
        debugPrint(
          'Warning: Timezone initialization failed, notifications may not work correctly',
        );
      }

      // Check/request permissions
      if (!context.mounted) {
        debugPrint('Context no longer mounted during initialization');
        return false;
      }

      final hasPermission = await _permissionManager.initializeWithUserConsent(
        context,
      );
      if (!hasPermission) {
        debugPrint('Notification permission denied');
        return false;
      }

      // Initialize platform
      final platformResult = await _platform.initialize();
      if (!platformResult.success) {
        debugPrint('Platform initialization failed: ${platformResult.error}');
        return false;
      }

      _initialized = true;
      debugPrint('NotificationService initialized successfully');
      return true;
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
      return false;
    }
  }

  /// Show an immediate notification
  Future<NotificationResult> showInstantNotification({
    required String title,
    required String body,
    NotificationChannel channel = NotificationChannel.engagement,
    NotificationPriority priority = NotificationPriority.normal,
    String? payload,
  }) async {
    if (!_initialized) {
      return NotificationResult.failure('Service not initialized');
    }

    final hasPermission = await _permissionManager.hasPermission();
    if (!hasPermission) {
      return NotificationResult.failure('No notification permission');
    }

    final data = InstantNotificationData(
      id: _idManager.generateDynamicId(),
      title: title,
      body: body,
      channel: channel,
      priority: priority,
      payload: payload,
    );

    return _platform.showNotification(data);
  }

  /// Schedule a habit notification
  Future<NotificationResult> scheduleHabitNotification({
    required String habitId,
    required String title,
    required String body,
    required TimeOfDay time,
    NotificationRepeatInterval repeatInterval =
        NotificationRepeatInterval.daily,
    List<int>? customWeekdays,
    String? payload,
  }) async {
    if (!_initialized) {
      return NotificationResult.failure('Service not initialized');
    }

    final hasPermission = await _permissionManager.hasPermission();
    if (!hasPermission) {
      return NotificationResult.failure('No notification permission');
    }

    final scheduledTime = _timezoneManager.getNextOccurrence(time);
    final data = HabitNotificationData(
      id: _idManager.getHabitId(habitId),
      title: title,
      body: body,
      scheduledTime: scheduledTime.toLocal(),
      habitId: habitId,
      repeatInterval: repeatInterval,
      customWeekdays: customWeekdays,
      payload: payload,
    );

    return _platform.scheduleNotification(data);
  }

  /// Schedule a pomodoro notification
  Future<NotificationResult> showPomodoroNotification({
    required String title,
    required String body,
    required String sessionType,
    String? sessionId,
    String? payload,
  }) async {
    if (!_initialized) {
      return NotificationResult.failure('Service not initialized');
    }

    final hasPermission = await _permissionManager.hasPermission();
    if (!hasPermission) {
      return NotificationResult.failure('No notification permission');
    }

    final data = PomodoroNotificationData(
      id: _idManager.getPomodoroId(sessionId),
      title: title,
      body: body,
      sessionType: sessionType,
      payload: payload,
    );

    return _platform.showNotification(data);
  }

  /// Schedule an engagement notification
  Future<NotificationResult> scheduleEngagementNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String engagementType,
    Map<String, dynamic>? metadata,
    String? payload,
  }) async {
    if (!_initialized) {
      return NotificationResult.failure('Service not initialized');
    }

    final hasPermission = await _permissionManager.hasPermission();
    if (!hasPermission) {
      return NotificationResult.failure('No notification permission');
    }

    final data = EngagementNotificationData(
      id: _idManager.getEngagementId(engagementType),
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      engagementType: engagementType,
      metadata: metadata,
      payload: payload,
    );

    return _platform.scheduleNotification(data);
  }

  /// Cancel a habit's notifications
  Future<NotificationResult> cancelHabitNotifications(
    String habitId, {
    List<int>? customWeekdays,
  }) async {
    final baseId = _idManager.getHabitId(habitId);
    final idsToCancel = [baseId];

    // Add custom weekday IDs if they exist
    if (customWeekdays != null) {
      for (final weekday in customWeekdays) {
        idsToCancel.add(
          NotificationIdManager.weeklyInstanceId(baseId, weekday),
        );
      }
    }

    final result = await _platform.cancelNotifications(idsToCancel);
    if (result.success) {
      _idManager.removeHabitId(habitId);
    }
    return result;
  }

  /// Cancel a single notification
  Future<NotificationResult> cancelNotification(int id) async {
    return _platform.cancelNotification(id);
  }

  /// Cancel all notifications
  Future<NotificationResult> cancelAllNotifications() async {
    final result = await _platform.cancelAllNotifications();
    if (result.success) {
      _idManager.clearHabitIds();
    }
    return result;
  }

  /// Get health check information
  Future<Map<String, dynamic>> getHealthCheck() async {
    try {
      final permissionStatus = await _permissionManager.checkPermission();
      final pendingNotifications = await _platform.getPendingNotifications();

      return {
        'initialized': _initialized,
        'permission': _permissionManager.getStatusMessage(permissionStatus),
        'permissionGranted': permissionStatus == PermissionStatus.granted,
        'pendingCount': pendingNotifications.length,
        'timezone': _timezoneManager.getDebugInfo(),
        'idManager': _idManager.getDebugInfo(),
        'error': null,
      };
    } catch (e) {
      return {'initialized': _initialized, 'error': e.toString()};
    }
  }

  /// Get pending notifications
  Future<List<Map<String, dynamic>>> getPendingNotifications() async {
    try {
      final pending = await _platform.getPendingNotifications();
      return pending
          .map(
            (notification) => {
              'id': notification.id,
              'title': notification.title,
              'body': notification.body,
              'payload': notification.payload,
            },
          )
          .toList();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }

  /// Check if service is ready to send notifications
  Future<bool> isReady() async {
    if (!_initialized) return false;
    return _permissionManager.hasPermission();
  }

  /// Get user-friendly status message
  Future<String> getStatusMessage() async {
    if (!_initialized) return 'Service not initialized';

    final hasPermission = await _permissionManager.hasPermission();
    if (!hasPermission) return 'Permission required';

    final pending = await _platform.getPendingNotifications();
    return 'Ready (${pending.length} scheduled)';
  }

  // Getters for managers (for advanced usage)
  NotificationPermissionManager get permissionManager => _permissionManager;
  NotificationIdManager get idManager => _idManager;
  TimezoneManager get timezoneManager => _timezoneManager;
}
