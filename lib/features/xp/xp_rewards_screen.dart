import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/features/xp/xp_provider.dart';
import 'package:lockin/features/xp/xp_service.dart';
import 'package:lockin/themes/app_theme.dart';
import 'package:lockin/widgets/lockin_card.dart';

class XPRewardsScreen extends ConsumerWidget {
  const XPRewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncXPNotifier = ref.watch(xpNotifierProvider);
    return asyncXPNotifier.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading XP: $err')),
      data: (notifier) {
        final xpProfile = notifier.profile;
        final rewards = XPData.rewards;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rewards.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final reward = rewards[index];
            final unlocked = xpProfile.unlockedRewards.any(
              (r) => r.id == reward.id,
            );
            return LockinCard(
              color: scheme.onSurface.withValues(alpha: 0.12),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: unlocked ? scheme.primary : scheme.onSurfaceVariant,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reward.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (unlocked && reward.id == 'streak_saver')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: xpProfile.streakSaverAvailable
                            ? Colors.black
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        xpProfile.streakSaverAvailable ? 'Unlocked' : 'Used',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else if (unlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Unlocked',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Unlocks at Level ${reward.unlockLevel}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
