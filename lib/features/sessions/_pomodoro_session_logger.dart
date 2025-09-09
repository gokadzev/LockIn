import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PomodoroSessionLogger extends ConsumerStatefulWidget {
  const PomodoroSessionLogger({super.key});
  @override
  ConsumerState<PomodoroSessionLogger> createState() =>
      _PomodoroSessionLoggerState();
}

class _PomodoroSessionLoggerState extends ConsumerState<PomodoroSessionLogger> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
