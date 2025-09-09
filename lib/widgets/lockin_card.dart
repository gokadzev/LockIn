import 'package:flutter/material.dart';
import 'package:lockin/constants/app_constants.dart';
import 'package:lockin/themes/app_theme.dart';

class LockinCard extends StatelessWidget {
  const LockinCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppConstants.defaultPadding),
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.borderRadius = 16,
    this.color,
    this.boxShadow,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color? color;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? scheme.surfaceContainerHighest;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
