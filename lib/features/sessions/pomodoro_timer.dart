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
import 'package:lockin/core/utils/category_icon.dart';
import 'package:lockin/features/categories/categories_provider.dart';
import 'package:lockin/features/sessions/pomodoro_provider.dart';
import 'package:lockin/widgets/lockin_card.dart';

typedef PomodoroCompleteCallback =
    void Function(int durationMinutes, DateTime startTime, DateTime endTime);

class PomodoroTimer extends ConsumerWidget {
  const PomodoroTimer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pomodoro = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(focusCategoryProvider);
    final categoryOptions = <String>[
      'General',
      ...categories.where((c) => c.toLowerCase() != 'general'),
    ];
    final phaseIsWork = pomodoro.phase == PomodoroPhase.work;
    final hasActiveSession = notifier.sessionStart != null;
    final minutes = (pomodoro.secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (pomodoro.secondsLeft % 60).toString().padLeft(2, '0');
    return LockinCard(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  phaseIsWork
                      ? Icons.bolt_rounded
                      : Icons.free_breakfast_rounded,
                  color: phaseIsWork ? scheme.primary : scheme.tertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  phaseIsWork ? 'Focus Time' : 'Break',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              pomodoro.isRunning
                  ? (phaseIsWork ? 'Deep work in progress' : 'Recovery time')
                  : 'Ready to start',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Focus category',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                return DropdownMenu<String>(
                  width: constraints.maxWidth,
                  initialSelection: selectedCategory ?? 'General',
                  enabled: notifier.sessionStart == null,
                  leadingIcon: Icon(
                    categoryToIcon(selectedCategory ?? 'General'),
                    color: scheme.primary,
                  ),
                  trailingIcon: Icon(
                    Icons.expand_more_rounded,
                    color: notifier.sessionStart == null
                        ? scheme.onSurfaceVariant
                        : scheme.onSurface.withValues(alpha: 0.4),
                  ),
                  textStyle: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: scheme.surfaceContainerHigh,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: scheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: scheme.outlineVariant),
                    ),
                  ),
                  dropdownMenuEntries: categoryOptions
                      .map(
                        (category) => DropdownMenuEntry<String>(
                          value: category,
                          label: category,
                          leadingIcon: Icon(categoryToIcon(category)),
                        ),
                      )
                      .toList(),
                  onSelected: notifier.sessionStart == null
                      ? (value) {
                          if (value == null) return;
                          ref
                              .read(focusCategoryProvider.notifier)
                              .setCategory(value);
                        }
                      : null,
                );
              },
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$minutes:$seconds',
                textAlign: TextAlign.center,
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(140, 52),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  onPressed: hasActiveSession
                      ? () => notifier.finishSession(context)
                      : () => notifier.startOrResume(context),
                  icon: Icon(
                    hasActiveSession
                        ? Icons.check_circle_rounded
                        : Icons.play_circle_fill_rounded,
                  ),
                  label: Text(hasActiveSession ? 'Finish' : 'Start'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(120, 52),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  onPressed: notifier.reset,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
