import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lockin/themes/app_theme.dart';

class LockinDialog extends StatelessWidget {
  const LockinDialog({
    required this.title,
    required this.content,
    required this.actions,
    super.key,
  });
  final Widget title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.7;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth =
        (screenWidth > 700
                ? math.min(720, screenWidth * 0.5)
                : screenWidth * 0.92)
            .toDouble();

    return Dialog(
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                  child: title,
                ),
                const SizedBox(height: 16),
                // Let the dialog content manage its own scrolling (ListView, SingleChildScrollView, etc.)
                Flexible(child: content),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: actions,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
