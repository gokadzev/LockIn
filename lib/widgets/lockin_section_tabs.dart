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

class LockinSectionTabs extends StatelessWidget {
  const LockinSectionTabs({
    super.key,
    required this.tabTitles,
    required this.tabCounts,
    required this.tabViews,
    this.controller,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.labelStyle,
  });
  final List<String> tabTitles;
  final List<int> tabCounts;
  final List<Widget> tabViews;
  final TabController? controller;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final indicator = indicatorColor ?? scheme.primary;
    final label = labelColor ?? scheme.onSurface;
    final unselected = unselectedLabelColor ?? scheme.onSurfaceVariant;
    assert(tabTitles.length == tabCounts.length);
    assert(tabTitles.length == tabViews.length);
    return DefaultTabController(
      length: tabTitles.length,
      child: Column(
        children: [
          TabBar(
            controller: controller,
            indicatorColor: indicator,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            labelColor: label,
            unselectedLabelColor: unselected,
            labelStyle:
                labelStyle ?? const TextStyle(fontWeight: FontWeight.w600),
            tabs: [
              for (int i = 0; i < tabTitles.length; i++)
                Tab(text: '${tabTitles[i]} (${tabCounts[i]})'),
            ],
          ),
          Expanded(
            child: TabBarView(controller: controller, children: tabViews),
          ),
        ],
      ),
    );
  }
}
