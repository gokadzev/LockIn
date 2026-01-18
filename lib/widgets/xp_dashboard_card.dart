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
import 'package:lockin/constants/ui_constants.dart';
import 'package:lockin/features/xp/xp_models.dart';
import 'package:lockin/features/xp/xp_service.dart';
import 'package:lockin/widgets/card_header.dart';
import 'package:lockin/widgets/lockin_card.dart';

class XPDashboardCard extends ConsumerWidget {
  const XPDashboardCard({required this.xpProfile, super.key});

  final XPProfile xpProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final xp = xpProfile.xp;
    final level = xpProfile.level;
    final nextLevelXP = XPService(xpProfile).xpForLevel(level + 1);
    final currentLevelXP = XPService(xpProfile).xpForLevel(level);
    final progress = ((xp - currentLevelXP) / (nextLevelXP - currentLevelXP))
        .clamp(0.0, 1.0);
    return LockinCard(
      padding: const EdgeInsets.all(UIConstants.largeSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: 'XP & Level',
            icon: Icons.stars_rounded,
            containerColor: colorScheme.tertiaryContainer,
            iconColor: colorScheme.onTertiaryContainer,
            trailing: ElevatedButton.icon(
              icon: const Icon(Icons.analytics),
              label: const Text('View XP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/xp');
              },
            ),
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlocked Rewards: ${xpProfile.unlockedRewards.length}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
