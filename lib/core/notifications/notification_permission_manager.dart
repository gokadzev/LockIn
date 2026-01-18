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
import 'package:lockin/widgets/lockin_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

/// Manages notification permissions
class NotificationPermissionManager {
  factory NotificationPermissionManager() => _instance;
  NotificationPermissionManager._();
  static final NotificationPermissionManager _instance =
      NotificationPermissionManager._();

  PermissionStatus? _lastKnownStatus;

  /// Check current notification permission status
  Future<PermissionStatus> checkPermission() async {
    try {
      final status = await Permission.notification.status;
      _lastKnownStatus = status;
      return status;
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
      return PermissionStatus.denied;
    }
  }

  /// Request notification permission
  Future<PermissionStatus> requestPermission() async {
    try {
      final status = await Permission.notification.request();
      _lastKnownStatus = status;
      return status;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return PermissionStatus.denied;
    }
  }

  /// Check if notifications are enabled
  Future<bool> hasPermission() async {
    final status = await checkPermission();
    return status.isGranted;
  }

  /// Show a dialog prompting user to enable notifications
  Future<bool> showPermissionDialog(BuildContext context) async {
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LockinDialog(
        title: const Text('Enable Notifications'),
        content: const Text(
          'LockIn needs notification permission to remind you about your habits and achievements. '
          'This helps you stay consistent with your goals.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );

    if (result == true) {
      final status = await requestPermission();
      return status.isGranted;
    }

    return false;
  }

  /// Show settings dialog when permission is permanently denied
  Future<void> showSettingsDialog(BuildContext context) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => LockinDialog(
        title: const Text('Notification Permission Required'),
        content: const Text(
          'Notifications are currently disabled. To enable them, please go to your device settings '
          'and grant notification permission to LockIn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Initialize permissions with user-friendly flow
  Future<bool> initializeWithUserConsent(BuildContext context) async {
    final currentStatus = await checkPermission();

    switch (currentStatus) {
      case PermissionStatus.granted:
        return true;

      case PermissionStatus.denied:
        // First time asking - show our dialog first
        if (context.mounted) {
          return showPermissionDialog(context);
        }
        return false;

      case PermissionStatus.permanentlyDenied:
        // User has permanently denied - show settings dialog
        if (context.mounted) {
          await showSettingsDialog(context);
        }
        return false;

      case PermissionStatus.restricted:
        debugPrint('Notifications restricted by device policy');
        return false;

      default:
        return false;
    }
  }

  /// Get user-friendly status message
  String getStatusMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Notifications enabled';
      case PermissionStatus.denied:
        return 'Notifications disabled - tap to enable';
      case PermissionStatus.permanentlyDenied:
        return 'Notifications permanently disabled - check settings';
      case PermissionStatus.restricted:
        return 'Notifications restricted by device policy';
      default:
        return 'Unknown notification status';
    }
  }

  /// Get cached status (use for UI updates without async calls)
  PermissionStatus? get cachedStatus => _lastKnownStatus;

  /// Check if we should show rationale
  bool shouldShowRationale(PermissionStatus status) {
    return status.isDenied || status.isPermanentlyDenied;
  }
}
