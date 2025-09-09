import 'package:flutter/material.dart';
import 'package:lockin/themes/app_theme.dart';

class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.color,
    this.size = 36,
    this.iconSize = 18,
  });

  final IconData icon;
  final Color? color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: boxDecorationColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(icon, color: color ?? scheme.onSurface, size: iconSize),
      ),
    );
  }
}
