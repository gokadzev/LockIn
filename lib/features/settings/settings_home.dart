import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/core/services/notification_service.dart';
import 'package:lockin/features/dashboard/dashboard_provider.dart';
import 'package:lockin/features/goals/goal_provider.dart';
import 'package:lockin/features/habits/habit_provider.dart';
import 'package:lockin/features/journal/journal_provider.dart';
import 'package:lockin/features/sessions/session_provider.dart';
import 'package:lockin/features/settings/backup_restore_util.dart';
import 'package:lockin/features/settings/engagement_time_provider.dart';
import 'package:lockin/features/tasks/task_provider.dart';
import 'package:lockin/themes/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsHome extends ConsumerStatefulWidget {
  const SettingsHome({super.key});

  @override
  ConsumerState<SettingsHome> createState() => _SettingsHomeState();
}

class _SettingsHomeState extends ConsumerState<SettingsHome> {
  String? _status;

  Future<void> _backup() async {
    final jsonData = await BackupRestoreUtil.exportAllData();
    final filePath = await BackupRestoreUtil.saveBackupFile(jsonData);
    setState(() => _status = 'Backup saved to: $filePath');
  }

  Future<void> _restore() async {
    try {
      final dir = Directory('/storage/emulated/0/Download/LockinBackup');
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();
      if (files.isEmpty) {
        setState(() => _status = 'No backup file found.');
        return;
      }
      final file = files.last;
      final data = await BackupRestoreUtil.importBackupFile(file);
      await BackupRestoreUtil.restoreAllData(data);
      // Invalidate all major providers to refresh UI
      ref
        ..invalidate(dashboardStatsProvider)
        ..invalidate(tasksListProvider)
        ..invalidate(habitsListProvider)
        ..invalidate(goalsListProvider)
        ..invalidate(sessionsListProvider)
        ..invalidate(journalsListProvider);
      setState(() => _status = 'Restore complete.');
    } catch (e) {
      setState(() => _status = 'Restore failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final engagementTime = ref.watch(engagementTimeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 6),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.settings, size: 44, color: scheme.onSurface),
                      const SizedBox(height: 6),
                      Text(
                        'Settings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // --- Engagement ---
                Card(
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active),
                    title: const Text('Engagement Notification Time'),
                    trailing: TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: engagementTime,
                        );
                        if (picked != null) {
                          ref
                              .read(engagementTimeProvider.notifier)
                              .setTime(picked);
                        }
                      },
                      child: Text(
                        engagementTime.format(context),
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  child: Text(
                    'General',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Backup
                Card(
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.backup),
                    title: const Text('Backup'),
                    subtitle: const Text('Export app data to a JSON backup'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _backup,
                  ),
                ),

                // Restore
                Card(
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('Restore'),
                    subtitle: const Text('Import data from a backup file'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _restore,
                  ),
                ),

                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  child: Text(
                    'System',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Battery optimization
                const Card(
                  elevation: 0,
                  child: ListTile(
                    leading: Icon(Icons.battery_alert),
                    title: Text('Battery Optimization'),
                    subtitle: Text(
                      'Disable optimizations to ensure background tasks run reliably',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.open_in_new),
                      onPressed: openAppSettings,
                    ),
                  ),
                ),

                // Notification health
                Card(
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.health_and_safety),
                    title: const Text('Notification Health'),
                    subtitle: const Text(
                      'Quick check whether notifications are permitted and scheduled items exist.',
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        setState(
                          () =>
                              _status = 'Running notification health check...',
                        );
                        final result = await NotificationService()
                            .healthCheck();
                        if (result.containsKey('error')) {
                          setState(
                            () => _status =
                                'Health check failed: ${result['error']}',
                          );
                          return;
                        }
                        final perm = result['granted'] == true
                            ? 'Granted'
                            : 'Not granted';
                        final pending = result['pendingCount'] ?? 0;
                        final tzInit = result['tzInitialized'] == true
                            ? 'OK'
                            : 'No';
                        setState(
                          () => _status =
                              'Permission: $perm • Pending: $pending • TimeZone: $tzInit',
                        );
                      },
                      child: const Text('Run'),
                    ),
                  ),
                ),

                // Status
                if (_status != null) ...[
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    child: ListTile(
                      leading: Icon(
                        _status!.contains('failed')
                            ? Icons.error_outline
                            : Icons.check_circle_outline,
                      ),
                      title: Text(_status!),
                    ),
                  ),
                ],

                const SizedBox(height: 18),
                const Center(
                  child: Text(
                    'Created by Valeri Gokadze',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
