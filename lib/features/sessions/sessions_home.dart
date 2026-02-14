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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lockin/constants/app_constants.dart';
import 'package:lockin/core/utils/category_icon.dart';
import 'package:lockin/features/sessions/pomodoro_timer.dart';
import 'package:lockin/features/sessions/session_provider.dart';
import 'package:lockin/widgets/icon_badge.dart';
import 'package:lockin/widgets/info_chip.dart';
import 'package:lockin/widgets/lockin_app_bar.dart';
import 'package:lockin/widgets/lockin_card.dart';

class SessionsHome extends ConsumerWidget {
  const SessionsHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sessionsRaw = ref.watch(sessionsListProvider);
    final sessions = sessionsRaw.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    final notifier = ref.read(sessionsListProvider.notifier);

    return Scaffold(
      appBar: const LockinAppBar(title: 'Focus'),
      body: SingleChildScrollView(
        padding: AppConstants.bodyPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PomodoroTimer(),
            const SizedBox(height: 24),
            Text(
              'Focus Sessions',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Latest sessions first',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ...sessions.isEmpty
                ? [
                    LockinCard(
                      color: scheme.surfaceContainerHigh,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 36,
                              color: scheme.primary,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'No sessions yet',
                              style: textTheme.titleMedium?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Start a Pomodoro to build your focus streak.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
                : sessions.map(
                    (session) => LockinCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const IconBadge(icon: Icons.timer, iconSize: 28),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat.yMMMd().add_jm().format(
                                      session.startTime,
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: scheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Duration: ${session.duration} min',
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 4,
                                    children: [
                                      InfoChip(
                                        icon: categoryToIcon(
                                          (session.category ?? '')
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : session.category,
                                        ),
                                        label:
                                            (session.category ?? '')
                                                .trim()
                                                .isEmpty
                                            ? 'Uncategorized'
                                            : session.category!.trim(),
                                      ),
                                      InfoChip(
                                        icon: Icons.check_circle,
                                        label:
                                            '${session.pomodoroCount} pomodoros',
                                      ),
                                      InfoChip(
                                        icon: Icons.coffee,
                                        label: '${session.breakCount} breaks',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete session?'),
                                    content: const Text(
                                      'This focus session will be removed permanently.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton.tonal(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  notifier.deleteSessionByKey(session.key);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
