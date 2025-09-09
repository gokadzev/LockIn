import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
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
