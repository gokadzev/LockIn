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
    final scheme = Theme.of(context).colorScheme;
    final iconColor = scheme.onSurfaceVariant;
    final textColor = scheme.onSurface;
    return LockinCard(
      padding: const EdgeInsets.all(UIConstants.largeSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            title: title,
            icon: _getIconForTitle(title),
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
                    Icon(item.icon, color: iconColor, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: textColor,
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
