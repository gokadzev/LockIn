import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/features/xp/xp_models.dart';
import 'package:lockin/features/xp/xp_service.dart';
import 'package:lockin/themes/app_theme.dart';
import 'package:lockin/widgets/lockin_card.dart';

class XPDashboardCard extends ConsumerWidget {
  const XPDashboardCard({required this.xpProfile, super.key});

  final XPProfile xpProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xp = xpProfile.xp;
    final level = xpProfile.level;
    final nextLevelXP = XPService(xpProfile).xpForLevel(level + 1);
    final currentLevelXP = XPService(xpProfile).xpForLevel(level);
    final progress = ((xp - currentLevelXP) / (nextLevelXP - currentLevelXP))
        .clamp(0.0, 1.0);
    return LockinCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, size: 32),
                const SizedBox(width: 10),
                Text(
                  'XP & Level',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.analytics),
                  label: const Text('View XP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/xp');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: progress, minHeight: 8),
            ),
            const SizedBox(height: 8),
            Text('Level $level  •  XP: $xp / $nextLevelXP'),
            const SizedBox(height: 8),
            Text(
              'Progress: ${(progress * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlocked Rewards: ${xpProfile.unlockedRewards.length}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
