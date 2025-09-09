import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/features/productivity/productivity_provider.dart';
import 'package:lockin/themes/app_theme.dart';

class ProductivityInsightsScreen extends ConsumerWidget {
  const ProductivityInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(productivityStatsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Productivity Insights')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Average Task Duration'),
              subtitle: Text('${stats.avgDuration.toStringAsFixed(1)} min'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Focus Time Clusters'),
              subtitle: Text(
                stats.clusters.isNotEmpty
                    ? stats.clusters.map((c) => '$c:00').join(', ')
                    : 'No data',
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Daily Streak'),
              subtitle: Text('${stats.streak} days'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Estimate Accuracy'),
              subtitle: Text('${(stats.accuracy * 100).toStringAsFixed(1)}%'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Fatigue Score'),
              subtitle: Text(stats.fatigue.toStringAsFixed(1)),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Hourly Productivity Heatmap'),
              subtitle: Text(
                stats.heatmap.entries
                    .map((e) => '${e.key}:00 → ${e.value} tasks')
                    .join(', '),
              ),
            ),
          ),
          Card(
            color: scheme.surfaceContainerHighest,
            child: ListTile(
              leading: Icon(Icons.lightbulb, color: scheme.onSurface),
              title: const Text('Personalized Nudge'),
              subtitle: Text(stats.nudge),
            ),
          ),
        ],
      ),
    );
  }
}
