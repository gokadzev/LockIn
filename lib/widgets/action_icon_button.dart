import 'package:flutter/material.dart';
import 'package:lockin/themes/app_theme.dart';

class ActionIconButton extends StatelessWidget {
  const ActionIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: color ?? scheme.onSurface, size: 28),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}
