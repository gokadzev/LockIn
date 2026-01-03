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
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.repeat),
                    label: 'Habits',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.flag),
                    label: 'Goals',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.timer),
                    label: 'Focus',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.book),
                    label: 'Journal',
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
