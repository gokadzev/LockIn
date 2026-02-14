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

class PomodoroNotifier extends Notifier<PomodoroState> {
  late int workSeconds;
  late int breakSeconds;
  Timer? _timer;
  bool _cancelled = false;

  // Session tracking
  DateTime? _sessionStart;
  DateTime? _phaseStart;
  int _pomodoroCount = 0;
  int _breakCount = 0;
  Duration _sessionDuration = Duration.zero;
  int _workAccumulatedSeconds = 0;

  bool get cancelled => _cancelled;
  int get pomodoroCount => _pomodoroCount;
  int get breakCount => _breakCount;
  DateTime? get sessionStart => _sessionStart;
  Duration get sessionDuration => _sessionDuration;

  @override
  PomodoroState build() {
    _timer?.cancel();
    _cancelled = false;
    _sessionStart = null;
    _phaseStart = null;
    _pomodoroCount = 0;
    _breakCount = 0;
    _sessionDuration = Duration.zero;
    _workAccumulatedSeconds = 0;

    workSeconds = AppValues.defaultWorkMinutes * 60;
    breakSeconds = AppValues.defaultBreakMinutes * 60;

    ref.onDispose(() {
      _timer?.cancel();
    });

    return PomodoroState(
      phase: PomodoroPhase.work,
      secondsLeft: workSeconds,
      isRunning: false,
    );
  }

  void startOrResume(BuildContext context) {
    if (state.isRunning) return;
    _timer?.cancel();
    _sessionStart ??= DateTime.now();
    final phaseDuration = state.phase == PomodoroPhase.work
        ? workSeconds
        : breakSeconds;
    final elapsedSoFar = (phaseDuration - state.secondsLeft).clamp(
      0,
      phaseDuration,
    );
    _phaseStart ??= DateTime.now().subtract(Duration(seconds: elapsedSoFar));
    var lastSecondDisplayed = state.secondsLeft;
    state = state.copyWith(isRunning: true);

    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      final elapsed = DateTime.now().difference(_phaseStart!).inSeconds;
      final remaining =
          (state.phase == PomodoroPhase.work ? workSeconds : breakSeconds) -
          elapsed;
      final clampedRemaining = remaining < 0 ? 0 : remaining;

      if (clampedRemaining != lastSecondDisplayed) {
        lastSecondDisplayed = clampedRemaining;
        state = state.copyWith(secondsLeft: clampedRemaining);

        if (state.phase == PomodoroPhase.work) {
          _sessionDuration = Duration(
            seconds: _workAccumulatedSeconds + elapsed,
          );
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
      _workAccumulatedSeconds += workSeconds;
      _sessionDuration = Duration(seconds: _workAccumulatedSeconds);
      _sendNotification(
        title: '⏱️ Pomodoro Finished',
        body: 'Time for a break!',
        sessionType: 'work',
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
      _sendNotification(
        title: '⏰ Break Finished',
        body: 'Time to focus!',
        sessionType: 'break',
      ).then((_) {
        _sessionStart ??= DateTime.now();
        state = PomodoroState(
          phase: PomodoroPhase.work,
          secondsLeft: workSeconds,
          isRunning: true,
        );
        _restartTimer();
      });
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    _phaseStart = DateTime.now();
    var lastSecondDisplayed = state.secondsLeft;

    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      final elapsed = DateTime.now().difference(_phaseStart!).inSeconds;
      final remaining =
          (state.phase == PomodoroPhase.work ? workSeconds : breakSeconds) -
          elapsed;
      final clampedRemaining = remaining < 0 ? 0 : remaining;

      if (clampedRemaining != lastSecondDisplayed) {
        lastSecondDisplayed = clampedRemaining;
        state = state.copyWith(secondsLeft: clampedRemaining);

        if (state.phase == PomodoroPhase.work) {
          _sessionDuration = Duration(
            seconds: _workAccumulatedSeconds + elapsed,
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
    required String sessionType,
  }) async {
    try {
      final result = await NotificationService().showPomodoroNotification(
        title: title,
        body: body,
        sessionType: sessionType,
        sessionId: _sessionStart?.toIso8601String(),
      );
      if (!result.success) {
        debugPrint('Notification failed: ${result.error}');
      }
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  void finishSession(BuildContext context) {
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
      ref.read(xpNotifierProvider.notifier).addXP(10);
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
    _phaseStart = null;
    _sessionDuration = Duration.zero;
    _workAccumulatedSeconds = 0;
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
    _phaseStart = null;
    _sessionDuration = Duration.zero;
    _workAccumulatedSeconds = 0;
    _pomodoroCount = 0;
    _breakCount = 0;
  }
}

final pomodoroProvider = NotifierProvider<PomodoroNotifier, PomodoroState>(
  PomodoroNotifier.new,
);

/// Selected focus category for new sessions.
final focusCategoryProvider = NotifierProvider<FocusCategoryNotifier, String?>(
  FocusCategoryNotifier.new,
);

class FocusCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setCategory(String? value) {
    state = value;
  }
}
