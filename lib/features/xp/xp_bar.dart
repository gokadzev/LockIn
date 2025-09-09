import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/features/xp/xp_provider.dart';
import 'package:lockin/features/xp/xp_service.dart';

class XPBar extends StatelessWidget {
  const XPBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final asyncXPNotifier = ref.watch(xpNotifierProvider);
        return asyncXPNotifier.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error loading XP: $err')),
          data: (notifier) {
            final xpProfile = notifier.profile;
            final xp = xpProfile.xp;
            final level = xpProfile.level;
            final nextLevelXP = XPService(xpProfile).xpForLevel(level + 1);
            final currentLevelXP = XPService(xpProfile).xpForLevel(level);
            final progress =
                (xp - currentLevelXP) / (nextLevelXP - currentLevelXP);

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Level $level',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$xp XP',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0, 1),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Next level: ${nextLevelXP - xp} XP to go',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
