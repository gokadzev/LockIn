import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockin/constants/app_values.dart';
import 'package:lockin/core/models/session.dart';
import 'package:lockin/core/notifications/notification_service.dart';

import 'package:lockin/features/sessions/session_provider.dart';
import 'package:lockin/features/xp/xp_provider.dart';
import 'package:lockin/widgets/lockin_notification.dart';

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
  PomodoroNotifier({int? workSeconds, int? breakSeconds})
    : workSeconds = workSeconds ?? (AppValues.defaultWorkMinutes * 60),
      breakSeconds = breakSeconds ?? (AppValues.defaultBreakMinutes * 60),
      super(
        PomodoroState(
          phase: PomodoroPhase.work,
          secondsLeft: workSeconds ?? (AppValues.defaultWorkMinutes * 60),
          isRunning: false,
        ),
      );
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

  void startOrResume(BuildContext context) {
    if (state.isRunning) return;
    _timer?.cancel();
    _sessionStart ??= DateTime.now();
    var lastSecondDisplayed = state.secondsLeft;
    state = state.copyWith(isRunning: true);

    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      final elapsed = DateTime.now().difference(_sessionStart!).inSeconds;
      final remaining =
          (state.phase == PomodoroPhase.work ? workSeconds : breakSeconds) -
          elapsed;

      if (remaining != lastSecondDisplayed) {
        lastSecondDisplayed = remaining;
        state = state.copyWith(secondsLeft: remaining);

        if (state.phase == PomodoroPhase.work) {
          _sessionDuration = Duration(seconds: elapsed);
        }

        if (remaining <= 0) {
          timer.cancel();
          _handlePhaseTransition();
        }
      }
    });
  }

  void _handlePhaseTransition() {
    if (state.phase == PomodoroPhase.work) {
      _pomodoroCount++;
      _sendNotification(
        title: '⏱️ Pomodoro Finished',
        body: 'Time for a break!',
      ).then((_) {
        state = PomodoroState(
          phase: PomodoroPhase.breakTime,
          secondsLeft: breakSeconds,
          isRunning: true,
        );
        _restartTimer();
      });
    } else {
      _breakCount++;
      _sendNotification(title: '⏰ Break Finished', body: 'Time to focus!').then(
        (_) {
          _sessionStart ??= DateTime.now();
          state = PomodoroState(
            phase: PomodoroPhase.work,
            secondsLeft: workSeconds,
            isRunning: true,
          );
          _restartTimer();
        },
      );
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    var lastSecondDisplayed = state.secondsLeft;
    final phaseStart = DateTime.now();

    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      final elapsed = DateTime.now().difference(phaseStart).inSeconds;
      final remaining =
          (state.phase == PomodoroPhase.work ? workSeconds : breakSeconds) -
          elapsed;

      if (remaining != lastSecondDisplayed) {
        lastSecondDisplayed = remaining;
        state = state.copyWith(secondsLeft: remaining);

        if (state.phase == PomodoroPhase.work) {
          _sessionDuration = Duration(
            seconds: DateTime.now().difference(_sessionStart!).inSeconds,
          );
        }

        if (remaining <= 0) {
          timer.cancel();
          _handlePhaseTransition();
        }
      }
    });
  }

  Future<void> _sendNotification({
    required String title,
    required String body,
  }) async {
    try {
      final result = await NotificationService().showInstantNotification(
        title: title,
        body: body,
      );
      if (!result.success) {
        debugPrint('Notification failed: ${result.error}');
      }
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  void finishSession(WidgetRef ref, BuildContext context) {
    _timer?.cancel();
    if (_sessionStart != null && _pomodoroCount > 0) {
      final notifier = ref.read(sessionsListProvider.notifier);
      final selectedCategory = ref.read(focusCategoryProvider);
      final normalizedCategory =
          (selectedCategory == null || selectedCategory.trim().isEmpty)
          ? 'General'
          : selectedCategory.trim();
      final start = _sessionStart!;
      final end = DateTime.now();
      final duration = _sessionDuration.inMinutes;
      notifier.addSession(
        Session()
          ..startTime = start
          ..endTime = end
          ..duration = duration > 0 ? duration : 1
          ..pomodoroCount = _pomodoroCount
          ..breakCount = _breakCount
          ..category = normalizedCategory,
      );
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

/// Selected focus category for new sessions.
final focusCategoryProvider = StateProvider<String?>((ref) => null);
