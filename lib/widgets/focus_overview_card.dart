import 'package:flutter/material.dart';
import 'package:lockin/constants/ui_constants.dart';
import 'package:lockin/core/models/session.dart';
import 'package:lockin/core/utils/category_icon.dart';
import 'package:lockin/widgets/card_header.dart';
import 'package:lockin/widgets/lockin_card.dart';

class _FocusCategoryStat {
  const _FocusCategoryStat({
    required this.name,
    required this.count,
    required this.percent,
    required this.color,
  });

  final String name;
  final int count;
  final double percent;
  final Color color;
}

List<_FocusCategoryStat> _buildFocusCategoryStats(
  List<Session> sessions,
  ColorScheme scheme,
) {
  if (sessions.isEmpty) return [];

  String normalizeCategory(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? 'Uncategorized' : trimmed;
  }

  final counts = <String, int>{};
  for (final session in sessions) {
    final category = normalizeCategory(session.category);
    counts[category] = (counts[category] ?? 0) + 1;
  }

  final total = counts.values.fold<int>(0, (a, b) => a + b);
  if (total == 0) return [];

  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final palette = <Color>[
    scheme.primary,
    scheme.secondary,
    scheme.tertiary,
    scheme.error,
    scheme.primaryContainer,
    scheme.secondaryContainer,
  ];

  final stats = <_FocusCategoryStat>[];
  for (var i = 0; i < sorted.length; i++) {
    final entry = sorted[i];
    stats.add(
      _FocusCategoryStat(
        name: entry.key,
        count: entry.value,
        percent: (entry.value / total) * 100,
        color: palette[i % palette.length],
      ),
    );
  }

  return stats;
}

class FocusOverviewCard extends StatelessWidget {
  const FocusOverviewCard({required this.sessions, super.key});

  final List<Session> sessions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final stats = _buildFocusCategoryStats(sessions, scheme);

    if (stats.isEmpty) {
      return LockinCard(
        padding: const EdgeInsets.all(UIConstants.largeSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CardHeader(title: 'Focus Overview', icon: Icons.donut_large),
            const SizedBox(height: UIConstants.largeSpacing),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.donut_large,
                      size: 48,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No focus sessions',
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start a focus session to track your productivity',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final totalSessions = stats.fold<int>(0, (sum, s) => sum + s.count);
    final top = stats.first;

    return LockinCard(
      padding: const EdgeInsets.all(UIConstants.largeSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            title: 'Focus Overview',
            subtitle: '$totalSessions sessions',
            icon: Icons.donut_large,
            containerColor: scheme.secondaryContainer,
            iconColor: scheme.onSecondaryContainer,
          ),
          const SizedBox(height: 12),
          Text(
            'Most focused: ${top.name} — ${top.percent.toStringAsFixed(0)}% (${top.count})',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  for (final stat in stats)
                    Expanded(
                      flex: stat.count,
                      child: Container(color: stat.color),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...stats.map(
            (stat) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        categoryToIcon(
                          stat.name == 'Uncategorized' ? null : stat.name,
                        ),
                        color: stat.color,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          stat.name,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${stat.percent.toStringAsFixed(0)}%',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${stat.count}',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: stat.percent / 100,
                      minHeight: 6,
                      backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(stat.color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
