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

class LockinAppBar extends StatelessWidget implements PreferredSizeWidget {
  const LockinAppBar({required this.title, this.actions, super.key});
  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final defaultActions = [
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () => Navigator.of(context).pushNamed('/settings'),
      ),
    ];
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(letterSpacing: 1.1),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions ?? defaultActions,
                  ),
                ],
              ),
            ),
          ),
          // Subtle divider
          Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
