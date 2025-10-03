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
