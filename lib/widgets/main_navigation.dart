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
import 'package:lockin/core/notifications/notification_service.dart';
import 'package:lockin/core/services/user_activity_tracker.dart';
import 'package:lockin/features/dashboard/dashboard_home.dart';
import 'package:lockin/features/goals/goals_home.dart';
import 'package:lockin/features/habits/habits_home.dart';
import 'package:lockin/features/journal/journal_home.dart';
import 'package:lockin/features/sessions/sessions_home.dart';
import 'package:lockin/features/tasks/tasks_home.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  MainNavigationState createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;
  static const List<_NavigationItem> _items = [
    _NavigationItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      page: DashboardHome(),
    ),
    _NavigationItem(
      icon: Icons.check_circle_outline,
      label: 'Tasks',
      page: TasksHome(),
    ),
    _NavigationItem(icon: Icons.repeat, label: 'Habits', page: HabitsHome()),
    _NavigationItem(icon: Icons.flag, label: 'Goals', page: GoalsHome()),
    _NavigationItem(icon: Icons.timer, label: 'Focus', page: SessionsHome()),
    _NavigationItem(icon: Icons.book, label: 'Journal', page: JournalHome()),
  ];

  List<Widget> get _pages =>
      _items.map((item) => item.page).toList(growable: false);

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    // Request notification permission globally for all features
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await NotificationService().initialize(context);
      // Mark user as active when opening app
      await UserActivityTracker.markActive();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= UIConstants.tabletBreakpoint;
        if (isTablet) {
          final indicatorColor = Colors.white.withAlpha(
            43,
          ); // Theme.of(context).colorScheme.onSurface.withAlpha(43);
          // Tablet layout
          return Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) =>
                    setState(() => _selectedIndex = index),
                extended:
                    constraints.maxWidth > UIConstants.extendedNavBreakpoint,
                labelType:
                    constraints.maxWidth > UIConstants.extendedNavBreakpoint
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                // Main content
                destinations: _items
                    .map(
                      (item) => NavigationRailDestination(
                        indicatorColor: indicatorColor,
                        indicatorShape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        icon: Icon(item.icon),
                        label: Text(item.label),
                      ),
                    )
                    .toList(growable: false),
              ),
              Expanded(
                child: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.extraLargeSpacing,
                    ),
                    child: _pages[_selectedIndex],
                  ),
                ),
              ),
            ],
          );
        } else {
          // Mobile layout
          return Scaffold(
            body: _pages[_selectedIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              destinations: _items
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(growable: false),
            ),
          );
        }
      },
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.page,
  });

  final IconData icon;
  final String label;
  final Widget page;
}
