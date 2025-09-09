import 'package:flutter/material.dart';

class LockinSnackBar {
  static void showUndo({
    required BuildContext context,
    required String message,
    required VoidCallback onUndo,
    String undoLabel = 'Undo',
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: SnackBarAction(label: undoLabel, onPressed: onUndo),
      ),
    );
  }

  static void showSimple({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), duration: duration));
  }
}
