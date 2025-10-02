import 'package:flutter/material.dart';
import 'package:lockin/core/utils/timezone_helper.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Manages timezone initialization and utilities
class TimezoneManager {
  factory TimezoneManager() => _instance;
  TimezoneManager._();
  static final TimezoneManager _instance = TimezoneManager._();

  bool _initialized = false;
  String? _currentTimezone;
  tz.Location? _location;

  bool get isInitialized => _initialized;
  String? get currentTimezone => _currentTimezone;
  tz.Location? get location => _location;

  /// Initialize timezones with proper error handling
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // Initialize timezone database
      tz.initializeTimeZones();

      // Get platform timezone
      String platformTimezone;
      try {
        platformTimezone = await TimezoneHelper.getLocalTimezone();
      } catch (e) {
        debugPrint('Failed to get platform timezone: $e');
        platformTimezone = tz.local.name;
      }

      // Validate and set timezone
      try {
        _location = tz.getLocation(platformTimezone);
        tz.setLocalLocation(_location!);
        _currentTimezone = platformTimezone;
      } catch (e) {
        debugPrint(
          'Invalid timezone "$platformTimezone", falling back to UTC: $e',
        );
        _location = tz.getLocation('UTC');
        tz.setLocalLocation(_location!);
        _currentTimezone = 'UTC';
      }

      _initialized = true;
      debugPrint('Timezone initialized: $_currentTimezone');
      return true;
    } catch (e) {
      debugPrint('Failed to initialize timezones: $e');
      return false;
    }
  }

  /// Get the next occurrence of a specific time
  tz.TZDateTime getNextOccurrence(TimeOfDay time, {DateTime? from}) {
    if (!_initialized) {
      throw StateError('TimezoneManager not initialized');
    }

    final base = from != null
        ? tz.TZDateTime.from(from, tz.local)
        : tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      base.year,
      base.month,
      base.day,
      time.hour,
      time.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduled.isBefore(base)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  /// Get the next occurrence of a specific weekday and time
  tz.TZDateTime getNextWeekdayOccurrence(
    TimeOfDay time,
    int weekday, {
    DateTime? from,
  }) {
    if (!_initialized) {
      throw StateError('TimezoneManager not initialized');
    }

    final base = from != null
        ? tz.TZDateTime.from(from, tz.local)
        : tz.TZDateTime.now(tz.local);

    // Calculate days until target weekday (1=Mon, 7=Sun)
    var daysToAdd = (weekday - base.weekday) % 7;

    if (daysToAdd == 0) {
      // Same weekday - check if time has passed
      final todayAtTime = tz.TZDateTime(
        tz.local,
        base.year,
        base.month,
        base.day,
        time.hour,
        time.minute,
      );

      if (todayAtTime.isAfter(base)) {
        return todayAtTime;
      } else {
        daysToAdd = 7; // Schedule for next week
      }
    }

    final targetDate = base.add(Duration(days: daysToAdd));
    return tz.TZDateTime(
      tz.local,
      targetDate.year,
      targetDate.month,
      targetDate.day,
      time.hour,
      time.minute,
    );
  }

  /// Convert DateTime to TZDateTime
  tz.TZDateTime toTZDateTime(DateTime dateTime) {
    if (!_initialized) {
      throw StateError('TimezoneManager not initialized');
    }
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  /// Get current time in local timezone
  tz.TZDateTime now() {
    if (!_initialized) {
      throw StateError('TimezoneManager not initialized');
    }
    return tz.TZDateTime.now(tz.local);
  }

  /// Format timezone for display
  String getFormattedTimezone() {
    if (!_initialized || _currentTimezone == null) {
      return 'Unknown';
    }

    // Format timezone name for user display
    final parts = _currentTimezone!.split('/');
    if (parts.length > 1) {
      return parts.last.replaceAll('_', ' ');
    }
    return _currentTimezone!;
  }

  /// Get timezone offset string (e.g., "+05:30")
  String getTimezoneOffset() {
    if (!_initialized) {
      return '+00:00';
    }

    final now = tz.TZDateTime.now(tz.local);
    final offset = now.timeZoneOffset;

    final hours = offset.inHours;
    final minutes = offset.inMinutes.remainder(60).abs();
    final sign = hours >= 0 ? '+' : '-';

    return '$sign${hours.abs().toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  /// Validate if a timezone string is valid
  static bool isValidTimezone(String timezone) {
    try {
      tz.getLocation(timezone);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'initialized': _initialized,
      'currentTimezone': _currentTimezone,
      'locationName': _location?.name,
      'offset': getTimezoneOffset(),
      'formattedName': getFormattedTimezone(),
    };
  }
}
