import 'dart:math';

import 'package:hive_ce/hive.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/models/session.dart';
import 'package:lockin/core/models/task.dart';

class ProductivityService {
  ProductivityService(this.taskBox, this.habitBox, this.sessionBox);
  final Box<Task> taskBox;
  final Box<Habit> habitBox;
  final Box<Session> sessionBox;

  // 1. Exponential moving average for task durations
  double getMovingAverageDuration({String? tag, double alpha = 0.5}) {
    final tasks =
        taskBox.values
            .where(
              (t) =>
                  t.actualDuration != null &&
                  (tag == null || t.tags.contains(tag)),
            )
            .toList()
          ..sort((a, b) {
            final aTime =
                a.completionTime ??
                a.startTime ??
                DateTime.fromMillisecondsSinceEpoch(0);
            final bTime =
                b.completionTime ??
                b.startTime ??
                DateTime.fromMillisecondsSinceEpoch(0);
            return aTime.compareTo(bTime);
          });
    double avg = 0;
    for (final t in tasks) {
      avg = alpha * (t.actualDuration ?? 0) + (1 - alpha) * avg;
    }
    return avg;
  }

  // 2. Cluster task completion times (simple k-means)
  List<int> getFocusTimeClusters({int k = 2}) {
    final times = taskBox.values
        .where((t) => t.completionTime != null)
        .map((t) => t.completionTime!.hour)
        .toList();
    if (times.isEmpty || k <= 0) return [];
    if (k > times.length) k = times.length; // clamp
    times.sort();
    // Simple clustering: split into k buckets
    final n = times.length ~/ k;
    if (n == 0) return [times.first];
    return List.generate(
      k,
      (i) => times[min(i * n, times.length - 1)],
    ).toSet().toList(); // ensure uniqueness
  }

  // 3. Sliding window productivity score (last 7 days)
  List<double> getSlidingWindowScores({int window = 7}) {
    final now = DateTime.now();
    final scores = <double>[];
    for (var i = 0; i < window; i++) {
      final day = now.subtract(Duration(days: i));
      final tasks = taskBox.values.where(
        (t) =>
            t.completed &&
            !t.abandoned &&
            t.completionTime != null &&
            t.completionTime!.year == day.year &&
            t.completionTime!.month == day.month &&
            t.completionTime!.day == day.day,
      );
      scores.add(tasks.length.toDouble());
    }
    return scores.reversed.toList();
  }

  // 4. Estimate vs. actual accuracy
  double getEstimateAccuracy() {
    final tasks = taskBox.values.where(
      (t) => t.estimatedDuration != null && t.actualDuration != null,
    );
    if (tasks.isEmpty) return 1;
    double sum = 0;
    for (final t in tasks) {
      final est = t.estimatedDuration!.toDouble();
      if (est <= 0) continue; // skip invalid estimates
      sum += 1 - (t.estimatedDuration! - t.actualDuration!).abs() / est;
    }
    final count = tasks.where((t) => t.estimatedDuration! > 0).length;
    return count == 0 ? 1 : (sum / count).clamp(-1.0, 1.0);
  }

  // 5. Flow session detection
  List<Session> getFlowSessions({int minTasks = 2, int maxBreakMinutes = 10}) {
    final sessions = sessionBox.values.toList();
    return sessions
        .where(
          (s) =>
              s.consecutiveTaskIds.length >= minTasks &&
              s.flowSessionDuration > 0,
        )
        .toList();
  }

  // 6. Fatigue detection (simple productivity decay)
  double getFatigueScore() {
    final scores = getSlidingWindowScores();
    if (scores.length < 2) return 0;
    return scores.first - scores.last;
  }

  // 7. Streaks
  int getDailyStreak() {
    final today = DateTime.now();
    var streak = 0;
    for (var i = 0; i < 30; i++) {
      final day = today.subtract(Duration(days: i));
      final tasks = taskBox.values.where(
        (t) =>
            t.completed &&
            !t.abandoned &&
            t.completionTime != null &&
            t.completionTime!.year == day.year &&
            t.completionTime!.month == day.month &&
            t.completionTime!.day == day.day,
      );
      if (tasks.isNotEmpty) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  // 8. Heatmap data (hourly productivity)
  Map<int, int> getHourlyHeatmap() {
    final map = <int, int>{};
    for (final t in taskBox.values.where(
      (t) => t.completed && !t.abandoned && t.completionTime != null,
    )) {
      final hour = t.completionTime!.hour;
      map[hour] = (map[hour] ?? 0) + 1;
    }
    return map;
  }

  // 9. Personalized nudges
  String getNudge() {
    final clusters = getFocusTimeClusters();
    if (clusters.isNotEmpty) {
      return "You're fastest at deep work at ${clusters.first}:00";
    }
    return 'Keep up the good work!';
  }
}
