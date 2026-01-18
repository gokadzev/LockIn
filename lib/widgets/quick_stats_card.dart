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
import 'package:lockin/constants/ui_constants.dart';
import 'package:lockin/features/dashboard/dashboard_provider.dart';
import 'package:lockin/widgets/card_header.dart';
import 'package:lockin/widgets/lockin_card.dart';
import 'package:lockin/widgets/stat_tile.dart';

/// Widget that displays quick stats in a card format
class QuickStatsCard extends StatelessWidget {
  const QuickStatsCard({required this.stats, super.key});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return LockinCard(
      padding: const EdgeInsets.all(UIConstants.largeSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(title: 'Quick Stats', icon: Icons.dashboard_rounded),
          const SizedBox(height: UIConstants.mediumSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatTile(label: 'Tasks', value: stats.tasksDone),
              StatTile(label: 'Habits', value: stats.habitsCompleted),
              StatTile(label: 'Sessions', value: stats.focusSessions),
              StatTile(label: 'Journals', value: stats.journalEntries),
            ],
          ),
        ],
      ),
    );
  }
}
