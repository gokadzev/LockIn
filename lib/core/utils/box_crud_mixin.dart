import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

mixin BoxCrudMixin<T> on StateNotifier<List<T>> {
  /// The Hive box backing this provider. Must be implemented by the class using the mixin.
  Box<T>? get box;

  /// Refreshes the StateNotifier state from the current box values.
  void syncStateFromBox() {
    if (box != null) {
      state = List<T>.from(box!.values);
    }
  }

  StreamSubscription? _boxSub;

  /// Start listening to the Hive box and keep state in sync for external changes.
  void startWatchingBox() {
    if (box == null || _boxSub != null) return;
    try {
      _boxSub = box!.watch().listen((event) {
        // On any change event, refresh state from box.
        syncStateFromBox();
      });
    } catch (_) {
      // ignore listen errors; best-effort sync
    }
  }

  /// Stop listening to the Hive box.
  void stopWatchingBox() {
    _boxSub?.cancel();
    _boxSub = null;
  }

  /// Adds an item to the box and updates state.
  void addItem(T item) {
    if (box == null) return;
    try {
      box!.add(item);
    } catch (e) {
      // best-effort: still try to keep state consistent
    }
    syncStateFromBox();
  }

  /// Updates an item at [index] in the box and updates state efficiently.
  void updateItem(int index, T item) {
    if (box == null) return;
    if (index < 0 || index >= box!.length) return;
    try {
      box!.putAt(index, item);
    } catch (e) {
      // ignore and fallback to full sync
      syncStateFromBox();
      return;
    }
    if (index < state.length) {
      final updated = List<T>.from(state);
      updated[index] = item;
      state = updated;
    } else {
      syncStateFromBox();
    }
  }

  /// Deletes an item at [index] from the box and updates state.
  void deleteItem(int index) {
    if (box == null) return;
    if (index < 0 || index >= box!.length) return;
    try {
      box!.deleteAt(index);
    } catch (e) {
      // fallback
    }
    syncStateFromBox();
  }
}
