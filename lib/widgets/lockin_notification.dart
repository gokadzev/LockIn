import 'package:flutter/material.dart';

final List<OverlayEntry> _activeLockinEntries = [];
const int _kMaxLockinEntries = 3;

void showLockinNotification(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context, rootOverlay: true);

  // If we already have too many entries, drop the oldest
  if (_activeLockinEntries.length >= _kMaxLockinEntries) {
    try {
      _activeLockinEntries.removeAt(0).remove();
    } catch (_) {}
  }

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => LockinNotification(
      message: message,
      duration: duration,
      onTap: () {
        try {
          entry.remove();
        } catch (_) {}
        try {
          _activeLockinEntries.remove(entry);
        } catch (_) {}
      },
      onDismiss: () {
        try {
          entry.remove();
        } catch (_) {}
        try {
          _activeLockinEntries.remove(entry);
        } catch (_) {}
      },
    ),
  );
  try {
    overlay.insert(entry);
    _activeLockinEntries.add(entry);
  } catch (e) {
    // overlay insert failed (race with navigation); ignore silently
    debugPrint('Failed to insert overlay: $e');
  }
}

class LockinNotification extends StatefulWidget {
  const LockinNotification({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 3),
    this.onTap,
    this.onDismiss,
  });
  final String message;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  State<LockinNotification> createState() => _LockinNotificationState();
}

class _LockinNotificationState extends State<LockinNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted && widget.onDismiss != null) {
            widget.onDismiss!();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: _offsetAnimation,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.black26.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.white24,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.white, size: 26),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
