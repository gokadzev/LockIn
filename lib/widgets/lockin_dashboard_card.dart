import 'package:flutter/material.dart';
import 'package:lockin/constants/app_constants.dart';
import 'package:lockin/constants/ui_constants.dart';
import 'package:lockin/widgets/card_header.dart';
import 'package:lockin/widgets/lockin_card.dart';

class LockinDashboardCard extends StatelessWidget {
  const LockinDashboardCard({
    super.key,
    required this.title,
    required this.items,
    this.elevation = 4,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(AppConstants.defaultPadding),
    this.trailing,
  });
  final String title;
  final List<DashboardItem> items;
  final double elevation;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'recommendations':
        return Icons.lightbulb_rounded;
      case 'stats':
        return Icons.analytics_rounded;
      default:
        return Icons.dashboard_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LockinCard(
      padding: const EdgeInsets.all(UIConstants.largeSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: title,
            icon: _getIconForTitle(title),
            containerColor: colorScheme.secondaryContainer,
            iconColor: colorScheme.onSecondaryContainer,
            trailing: trailing,
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: item.onTap,
                child: Row(
                  children: [
                    Icon(item.icon, color: Colors.white, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardItem {
  const DashboardItem({required this.icon, required this.text, this.onTap});
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
}
