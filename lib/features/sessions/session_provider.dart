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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/constants/hive_constants.dart';
import 'package:lockin/core/models/session.dart';
import 'package:lockin/core/utils/box_crud_mixin.dart';
import 'package:lockin/core/utils/hive_utils.dart';

/// Provides access to the Hive box for sessions.
final sessionsBoxProvider = Provider<Box<Session>?>((ref) {
  return openBoxIfAvailable<Session>(HiveBoxes.sessions);
});

/// Main provider for the list of sessions, using [SessionsNotifier].
final sessionsListProvider = NotifierProvider<SessionsNotifier, List<Session>>(
  SessionsNotifier.new,
);

class SessionsNotifier extends Notifier<List<Session>>
    with BoxCrudMixin<Session> {
  Box<Session>? _box;

  @override
  Box<Session>? get box => _box;

  @override
  List<Session> build() {
    stopWatchingBox();
    _box = ref.watch(sessionsBoxProvider);
    startWatchingBox();
    ref.onDispose(stopWatchingBox);
    return _box?.values.toList() ?? [];
  }

  /// Adds a new session to the box and updates state.
  void addSession(Session session) => addItem(session);

  /// Updates a session at [index] and updates state.
  void updateSession(int index, Session session) => updateItem(index, session);

  /// Deletes a session at [index] from the box and updates state.
  void deleteSession(int index) => deleteItem(index);

  /// Deletes a session by Hive key. Returns true when delete succeeded.
  bool deleteSessionByKey(dynamic key) {
    if (box == null) return false;
    try {
      return deleteItemByKey(key);
    } catch (_) {
      return false;
    }
  }
}
