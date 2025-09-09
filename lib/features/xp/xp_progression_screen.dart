import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/features/xp/xp_provider.dart';
import 'package:lockin/themes/app_theme.dart';

class XPProgressionScreen extends ConsumerWidget {
  const XPProgressionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncXPNotifier = ref.watch(xpNotifierProvider);
    return asyncXPNotifier.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text('Error loading XP: $err'))),
      data: (notifier) {
        final xpProfile = notifier.profile;
        final level = xpProfile.level;
        final wisdoms = [
          {'level': 2, 'tip': 'Stay consistent. Small steps build big habits.'},
          {
            'level': 4,
            'tip': 'Reflect on your progress weekly for best results.',
          },
          {'level': 6, 'tip': 'Try focus mode for deep work sessions.'},
          {'level': 8, 'tip': 'Share your milestones to stay motivated!'},
          {
            'level': 10,
            'tip': 'Unlock advanced analytics to optimize your productivity.',
          },
        ];
        final unlockedWisdoms = wisdoms
            .where((w) => level >= (w['level'] as int))
            .toList();
        return Scaffold(
          appBar: AppBar(title: const Text('Progression Coaching')),
          body: ListView.builder(
            itemCount: unlockedWisdoms.length,
            itemBuilder: (context, index) {
              final wisdom = unlockedWisdoms[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.lightbulb, color: scheme.onSurface),
                  title: Text('Level ${wisdom["level"]} Wisdom'),
                  subtitle: Text(wisdom['tip'] as String),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
