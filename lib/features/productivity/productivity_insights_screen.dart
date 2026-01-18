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
import 'package:lockin/features/productivity/productivity_provider.dart';

class ProductivityInsightsScreen extends ConsumerWidget {
  const ProductivityInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
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
