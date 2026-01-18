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
import 'package:lockin/features/xp/xp_provider.dart';

class XPProgressionScreen extends ConsumerWidget {
  const XPProgressionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
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
