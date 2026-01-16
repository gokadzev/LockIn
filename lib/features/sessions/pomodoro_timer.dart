import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/core/utils/category_icon.dart';
import 'package:lockin/features/categories/categories_provider.dart';
import 'package:lockin/features/sessions/pomodoro_provider.dart';
import 'package:lockin/themes/app_theme.dart';
import 'package:lockin/widgets/lockin_card.dart';

typedef PomodoroCompleteCallback =
    void Function(int durationMinutes, DateTime startTime, DateTime endTime);

class PomodoroTimer extends ConsumerWidget {
  const PomodoroTimer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoro = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(focusCategoryProvider);
    final categoryOptions = <String>[
      'General',
      ...categories.where((c) => c.toLowerCase() != 'general'),
    ];
    final minutes = (pomodoro.secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (pomodoro.secondsLeft % 60).toString().padLeft(2, '0');
    return LockinCard(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pomodoro.phase == PomodoroPhase.work ? 'Focus Time' : 'Break',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 10),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: notifier.sessionStart == null
                  ? () async {
                      final selected = await showModalBottomSheet<String>(
                        context: context,
                        showDragHandle: true,
                        backgroundColor: scheme.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) {
                          return SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    8,
                                    20,
                                    4,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Choose category',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      8,
                                      12,
                                      16,
                                    ),
                                    itemCount: categoryOptions.length,
                                    separatorBuilder: (_, _) => Divider(
                                      color: scheme.onSurface.withValues(
                                        alpha: 0.06,
                                      ),
                                    ),
                                    itemBuilder: (context, index) {
                                      final category = categoryOptions[index];
                                      final isSelected =
                                          (selectedCategory ?? 'General') ==
                                          category;
                                      return ListTile(
                                        leading: Icon(
                                          categoryToIcon(category),
                                          color: scheme.primary,
                                        ),
                                        title: Text(category),
                                        trailing: isSelected
                                            ? Icon(
                                                Icons.check_circle,
                                                color: scheme.primary,
                                              )
                                            : null,
                                        onTap: () =>
                                            Navigator.pop(context, category),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                      if (selected != null) {
                        ref.read(focusCategoryProvider.notifier).state =
                            selected;
                      }
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: scheme.onSurface.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      categoryToIcon(selectedCategory ?? 'General'),
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedCategory ?? 'General',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      notifier.sessionStart == null ? 'Change' : 'Locked',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: notifier.sessionStart == null
                            ? scheme.primary
                            : scheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.expand_more,
                      color: notifier.sessionStart == null
                          ? scheme.onSurface
                          : scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$minutes:$seconds',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    minimumSize: const Size(120, 56),
                  ),
                  onPressed: notifier.sessionStart == null
                      ? () => notifier.startOrResume(context)
                      : () => notifier.finishSession(ref, context),
                  child: Text(
                    notifier.sessionStart == null ? 'Start' : 'Finish',
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    minimumSize: const Size(100, 56),
                    side: BorderSide(color: scheme.outline),
                  ),
                  onPressed: notifier.reset,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
