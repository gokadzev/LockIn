import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/core/models/session.dart';
import 'package:lockin/core/utils/box_crud_mixin.dart';

/// Provides access to the Hive box for sessions.
final sessionsBoxProvider = Provider<Box<Session>?>((ref) {
  try {
    return Hive.isBoxOpen('sessions') ? Hive.box<Session>('sessions') : null;
  } catch (e) {
    return null;
  }
});

/// Main provider for the list of sessions, using [SessionsNotifier].
final sessionsListProvider =
    StateNotifierProvider<SessionsNotifier, List<Session>>((ref) {
      final box = ref.watch(sessionsBoxProvider);
      final notifier = SessionsNotifier(box)..startWatchingBox();
      return notifier;
    });

class SessionsNotifier extends StateNotifier<List<Session>>
    with BoxCrudMixin<Session> {
  /// Creates a SessionsNotifier backed by the given Hive [box].
  SessionsNotifier(this.box) : super(box?.values.toList() ?? []);
  @override
  final Box<Session>? box;

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
      final idx = box!.keys.toList().indexOf(key);
      if (idx == -1) return false;
      deleteItem(idx);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    stopWatchingBox();
    super.dispose();
  }
}
