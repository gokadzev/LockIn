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
import 'package:lockin/constants/app_constants.dart';
import 'package:lockin/core/utils/category_icon.dart';
import 'package:lockin/features/sessions/_pomodoro_session_logger.dart';
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
    final sessionsRaw = ref.watch(sessionsListProvider);
    final sessions = sessionsRaw.toList();
    final notifier = ref.read(sessionsListProvider.notifier);
    return Scaffold(
      appBar: const LockinAppBar(title: 'Focus'),
      body: SingleChildScrollView(
        padding: AppConstants.bodyPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PomodoroSessionLogger(),
            const PomodoroTimer(),
            const SizedBox(height: 24),
            Text(
              'Focus Sessions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...sessions.isEmpty
                ? [
                    const LockinCard(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('No sessions yet. Start a Pomodoro!'),
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
                                    'Session: ${session.startTime.toLocal().toString().substring(0, 16)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Duration: ${session.duration} min',
                                    style: const TextStyle(color: Colors.white),
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
                                        label: '${session.pomodoroCount}',
                                      ),
                                      InfoChip(
                                        icon: Icons.coffee,
                                        label: '${session.breakCount}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () =>
                                  notifier.deleteSessionByKey(session.key),
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
