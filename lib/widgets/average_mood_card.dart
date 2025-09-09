import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lockin/features/journal/journal_provider.dart';
import 'package:lockin/themes/app_theme.dart';
import 'package:lockin/widgets/lockin_card.dart';

class AverageMoodCard extends ConsumerWidget {
  const AverageMoodCard({super.key});

  String _emojiAsset(double? moodAvg) {
    if (moodAvg == null) return 'assets/emoji/neutral.png';
    if (moodAvg >= 8) return 'assets/emoji/happy.png';
    if (moodAvg >= 6) return 'assets/emoji/smile.png';
    if (moodAvg >= 4) return 'assets/emoji/neutral.png';
    return 'assets/emoji/sad.png';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journals = ref.watch(journalsListProvider);
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    final recent = journals
        .where(
          (j) =>
              j.date.isAfter(weekAgo.subtract(const Duration(days: 1))) &&
              j.date.isBefore(now.add(const Duration(days: 1))),
        )
        .toList();
    final moodAvg = recent.isNotEmpty
        ? (recent.map((j) => j.mood).reduce((a, b) => a + b) / recent.length)
        : null;
    var color = scheme.onSurfaceVariant;
    if (moodAvg != null) {
      if (moodAvg >= 8) {
        color = scheme.onSurface;
      } else if (moodAvg >= 6) {
        color = scheme.onSurface.withValues(alpha: 0.85);
      } else if (moodAvg >= 4) {
        color = scheme.onSurfaceVariant;
      } else {
        color = scheme.onSurface.withValues(alpha: 0.6);
      }
    }
    return LockinCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: color.withValues(alpha: 0.15),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: scheme.onSurface,
              child: Image.asset(_emojiAsset(moodAvg), width: 48, height: 48),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average Mood (7 days)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  moodAvg != null ? moodAvg.toStringAsFixed(1) : '-',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: color),
                ),
                if (recent.isNotEmpty)
                  Text(
                    '${DateFormat.yMMMd().format(weekAgo)} - ${DateFormat.yMMMd().format(now)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                if (recent.isEmpty)
                  Text(
                    'No journal entries this week.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
