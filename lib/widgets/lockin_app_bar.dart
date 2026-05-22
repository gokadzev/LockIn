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
  const LockinAppBar({
    required this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.centerTitle = false,
    this.elevation,
    this.backgroundColor,
    super.key,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;

  static const List<Widget> _defaultActions = [_SettingsAction()];

  @override
  Widget build(BuildContext context) {
    final actionsList = actions ?? _defaultActions;

    return AppBar(
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(letterSpacing: 1.1),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16),
      centerTitle: centerTitle,
      leading: leading,
      actions: actionsList,
      bottom: bottom,
      elevation: elevation,
      toolbarHeight: 64,
    );
  }

  @override
  Size get preferredSize {
    var height = 64.0;
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }
}

class _SettingsAction extends StatelessWidget {
  const _SettingsAction();

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      icon: const Icon(Icons.settings),
      onPressed: () => Navigator.of(context).pushNamed('/settings'),
    );
  }
}
