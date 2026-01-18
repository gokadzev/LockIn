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
  final List<Widget> _pages = const [
    DashboardHome(),
    TasksHome(),
    HabitsHome(),
    GoalsHome(),
    SessionsHome(),
    JournalHome(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    // Request notification permission globally for all features
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
                destinations: [
                  NavigationRailDestination(
                    indicatorColor: indicatorColor,
                    indicatorShape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    icon: const Icon(Icons.dashboard),
                    label: const Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    indicatorColor: indicatorColor,
                    indicatorShape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Tasks'),
                  ),
                  NavigationRailDestination(
                    indicatorColor: indicatorColor,
                    indicatorShape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    icon: const Icon(Icons.repeat),
                    label: const Text('Habits'),
                  ),
                  NavigationRailDestination(
                    indicatorColor: indicatorColor,
                    indicatorShape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    icon: const Icon(Icons.flag),
                    label: const Text('Goals'),
                  ),
                  NavigationRailDestination(
                    indicatorColor: indicatorColor,
                    indicatorShape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    icon: const Icon(Icons.timer),
                    label: const Text('Focus'),
                  ),
                  NavigationRailDestination(
                    indicatorColor: indicatorColor,
                    indicatorShape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    icon: const Icon(Icons.book),
                    label: const Text('Journal'),
                  ),
                ],
              ),
              // Main content
              Expanded(
                child: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: UIConstants.extraLargeSpacing,
                          ),
                          child: _pages[_selectedIndex],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          // Mobile layout
          return Scaffold(
            body: _pages[_selectedIndex],
            bottomNavigationBar: Theme(
              data: Theme.of(context).copyWith(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  height: 72,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  indicatorShape: const StadiumBorder(),
                  indicatorColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withAlpha(140),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    final base = Theme.of(context).textTheme.labelSmall
                        ?.copyWith(fontWeight: FontWeight.w600);
                    if (states.contains(WidgetState.selected)) {
                      return base?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      );
                    }
                    return base?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(170),
                    );
                  }),
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return IconThemeData(
                        size: 24,
                        color: Theme.of(context).colorScheme.onSurface,
                      );
                    }
                    return IconThemeData(
                      size: 22,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(170),
                    );
                  }),
                ),
                child: NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _selectedIndex = index),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.dashboard),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.check_circle_outline),
                      label: 'Tasks',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.repeat),
                      label: 'Habits',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.flag),
                      label: 'Goals',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.timer),
                      label: 'Focus',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.book),
                      label: 'Journal',
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
