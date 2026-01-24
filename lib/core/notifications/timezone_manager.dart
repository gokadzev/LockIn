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

  /// Get the next occurrence of a specific day-of-month and time
  tz.TZDateTime getNextMonthOccurrence(TimeOfDay time, {DateTime? from}) {
    if (!_initialized) {
      throw StateError('TimezoneManager not initialized');
    }

    final base = from != null
        ? tz.TZDateTime.from(from, tz.local)
        : tz.TZDateTime.now(tz.local);

    final day = base.day;
    var scheduled = tz.TZDateTime(
      tz.local,
      base.year,
      base.month,
      day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(base)) {
      final nextMonth = base.month == 12 ? 1 : base.month + 1;
      final nextYear = base.month == 12 ? base.year + 1 : base.year;
      final daysInTargetMonth = _daysInMonth(nextYear, nextMonth);
      final targetDay = day <= daysInTargetMonth ? day : daysInTargetMonth;
      scheduled = tz.TZDateTime(
        tz.local,
        nextYear,
        nextMonth,
        targetDay,
        time.hour,
        time.minute,
      );
    }

    return scheduled;
  }

  /// Get the next occurrence of a specific day-of-month and time
  tz.TZDateTime getNextMonthOccurrenceForDay(
    TimeOfDay time,
    int day, {
    DateTime? from,
  }) {
    if (!_initialized) {
      throw StateError('TimezoneManager not initialized');
    }

    final base = from != null
        ? tz.TZDateTime.from(from, tz.local)
        : tz.TZDateTime.now(tz.local);

    final safeDay = day < 1 ? 1 : day;
    final daysInCurrentMonth = _daysInMonth(base.year, base.month);
    final targetDay = safeDay <= daysInCurrentMonth
        ? safeDay
        : daysInCurrentMonth;

    var scheduled = tz.TZDateTime(
      tz.local,
      base.year,
      base.month,
      targetDay,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(base)) {
      final nextMonth = base.month == 12 ? 1 : base.month + 1;
      final nextYear = base.month == 12 ? base.year + 1 : base.year;
      final daysInTargetMonth = _daysInMonth(nextYear, nextMonth);
      final nextTargetDay = safeDay <= daysInTargetMonth
          ? safeDay
          : daysInTargetMonth;
      scheduled = tz.TZDateTime(
        tz.local,
        nextYear,
        nextMonth,
        nextTargetDay,
        time.hour,
        time.minute,
      );
    }

    return scheduled;
  }

  int _daysInMonth(int year, int month) {
    final beginningNextMonth = month == 12
        ? DateTime(year + 1)
        : DateTime(year, month + 1);
    final lastDay = beginningNextMonth.subtract(const Duration(days: 1));
    return lastDay.day;
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

    final totalMinutes = offset.inMinutes.abs();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes.remainder(60);
    final sign = offset.isNegative ? '-' : '+';

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
