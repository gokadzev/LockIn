import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/core/models/session.dart';
import 'package:lockin/core/services/notification_service.dart';
import 'package:lockin/features/sessions/session_provider.dart';
import 'package:lockin/features/xp/xp_provider.dart';
import 'package:lockin/widgets/lockin_notification.dart';
import 'package:permission_handler/permission_handler.dart';

enum PomodoroPhase { work, breakTime }

class PomodoroState {
  PomodoroState({
    required this.phase,
    required this.secondsLeft,
    required this.isRunning,
  });
  final PomodoroPhase phase;
  final int secondsLeft;
  final bool isRunning;

  PomodoroState copyWith({
    PomodoroPhase? phase,
    int? secondsLeft,
    bool? isRunning,
  }) {
    return PomodoroState(
      phase: phase ?? this.phase,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  PomodoroNotifier({this.workSeconds = 1500, this.breakSeconds = 300})
    : super(
        PomodoroState(
          phase: PomodoroPhase.work,
          secondsLeft: workSeconds,
          isRunning: false,
        ),
      );
  bool _isNotifying = false;
  final int workSeconds;
  final int breakSeconds;
  Timer? _timer;
  bool _cancelled = false;

  // Session tracking
  DateTime? _sessionStart;
  int _pomodoroCount = 0;
  int _breakCount = 0;
  Duration _sessionDuration = Duration.zero;

  bool get cancelled => _cancelled;
  int get pomodoroCount => _pomodoroCount;
  int get breakCount => _breakCount;
  DateTime? get sessionStart => _sessionStart;
  Duration get sessionDuration => _sessionDuration;

  final int _notificationId =
      1001; // use same id to get all notification with sound

  void startOrResume(BuildContext context) {
    if (state.isRunning) return;
    // Cancel any existing timer before starting a new one
    _timer?.cancel();
    _sessionStart ??= DateTime.now();
    var lastTick = DateTime.now();
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_isNotifying) return; // Prevent overlapping async executions
      final now = DateTime.now();
      final elapsed = now.difference(lastTick).inSeconds;
      lastTick = now;
      state = state.copyWith(secondsLeft: state.secondsLeft - elapsed);
      // Only count work time towards session duration.
      if (state.phase == PomodoroPhase.work) {
        _sessionDuration += Duration(seconds: elapsed);
      }
      if (state.secondsLeft > 0) return;
      _isNotifying = true;
      try {
        if (state.phase == PomodoroPhase.work) {
          _pomodoroCount++;
          // Check permission before sending notification
          final permission = await Permission.notification.status;
          if (permission.isGranted) {
            try {
              await NotificationService().showNotification(
                id: _notificationId,
                title: 'Pomodoro Finished',
                body: 'Time for a break!',
              );
            } catch (e) {
              debugPrint('Notification error: $e');
            }
          }
          state = PomodoroState(
            phase: PomodoroPhase.breakTime,
            secondsLeft: breakSeconds,
            isRunning: true,
          );
        } else {
          _breakCount++;
          final permission = await Permission.notification.status;
          if (permission.isGranted) {
            try {
              await NotificationService().showNotification(
                id: _notificationId,
                title: 'Break Finished',
                body: 'Time to focus!',
              );
            } catch (e) {
              debugPrint('Notification error: $e');
            }
          }
          // Starting a new work period. If we don't have a session start, set it.
          _sessionStart ??= DateTime.now();
          state = PomodoroState(
            phase: PomodoroPhase.work,
            secondsLeft: workSeconds,
            isRunning: true,
          );
        }
      } finally {
        _isNotifying = false;
      }
    });
  }

  void finishSession(WidgetRef ref, BuildContext context) {
    _timer?.cancel();
    if (_sessionStart != null && _pomodoroCount > 0) {
      final notifier = ref.read(sessionsListProvider.notifier);
      final start = _sessionStart!;
      final end = DateTime.now();
      final duration = _sessionDuration.inMinutes;
      notifier.addSession(
        Session()
          ..startTime = start
          ..endTime = end
          ..duration = duration > 0 ? duration : 1
          ..pomodoroCount = _pomodoroCount
          ..breakCount = _breakCount,
      );
      // Award XP for session completion
      ref
          .read(xpNotifierProvider.future)
          .then((xpNotifier) => xpNotifier.addXP(10));
      showLockinNotification(
        context,
        'Session finished! $_pomodoroCount Pomodoros, $_breakCount Breaks',
      );
    }
    state = PomodoroState(
      phase: PomodoroPhase.work,
      secondsLeft: workSeconds,
      isRunning: false,
    );
    _cancelled = false;
    _sessionStart = null;
    _sessionDuration = Duration.zero;
    _pomodoroCount = 0;
    _breakCount = 0;
  }

  void reset() {
    _timer?.cancel();
    _cancelled = true;
    state = PomodoroState(
      phase: PomodoroPhase.work,
      secondsLeft: workSeconds,
      isRunning: false,
    );
    _sessionStart = null;
    _sessionDuration = Duration.zero;
    _pomodoroCount = 0;
    _breakCount = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroState>(
  (ref) {
    return PomodoroNotifier();
  },
);
