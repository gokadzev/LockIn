import 'dart:async';

import 'package:flutter/foundation.dart';
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
    } catch (e, stackTrace) {
      debugPrint('Error watching box: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Stop listening to the Hive box.
  void stopWatchingBox() {
    _boxSub?.cancel();
    _boxSub = null;
  }

  /// Adds an item to the box and updates state.
  void addItem(T item) {
    if (box == null) {
      debugPrint('Cannot add item: box is null');
      return;
    }
    try {
      box!.add(item);
      syncStateFromBox();
    } catch (e, stackTrace) {
      debugPrint('Error adding item to box: $e');
      debugPrint('StackTrace: $stackTrace');
      // Still try to keep state consistent
      syncStateFromBox();
    }
  }

  /// Updates an item at [index] in the box and updates state efficiently.
  void updateItem(int index, T item) {
    if (box == null) {
      debugPrint('Cannot update item: box is null');
      return;
    }
    if (index < 0 || index >= box!.length) {
      debugPrint('Invalid index $index for box with length ${box!.length}');
      return;
    }
    try {
      box!.putAt(index, item);
      if (index < state.length) {
        final updated = List<T>.from(state);
        updated[index] = item;
        state = updated;
      } else {
        syncStateFromBox();
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating item at index $index: $e');
      debugPrint('StackTrace: $stackTrace');
      syncStateFromBox();
    }
  }

  /// Deletes an item at [index] from the box and updates state.
  void deleteItem(int index) {
    if (box == null) {
      debugPrint('Cannot delete item: box is null');
      return;
    }
    if (index < 0 || index >= box!.length) {
      debugPrint('Invalid index $index for box with length ${box!.length}');
      return;
    }
    try {
      box!.deleteAt(index);
      syncStateFromBox();
    } catch (e, stackTrace) {
      debugPrint('Error deleting item at index $index: $e');
      debugPrint('StackTrace: $stackTrace');
      syncStateFromBox();
    }
  }

  /// Updates an item by its Hive key. Returns true if update succeeded.
  bool updateItemByKey(dynamic key, T item, {VoidCallback? onSuccess}) {
    if (box == null) {
      debugPrint('Cannot update item by key: box is null');
      return false;
    }
    try {
      final keys = box!.keys.toList();
      final index = keys.indexOf(key);
      if (index == -1) {
        debugPrint('Key $key not found in box');
        return false;
      }
      updateItem(index, item);
      onSuccess?.call();
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error updating item by key $key: $e');
      debugPrint('StackTrace: $stackTrace');
      return false;
    }
  }

  /// Deletes an item by its Hive key. Returns true if deletion succeeded.
  bool deleteItemByKey(dynamic key) {
    if (box == null) {
      debugPrint('Cannot delete item by key: box is null');
      return false;
    }
    try {
      final keys = box!.keys.toList();
      final index = keys.indexOf(key);
      if (index == -1) {
        debugPrint('Key $key not found in box');
        return false;
      }
      deleteItem(index);
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error deleting item by key $key: $e');
      debugPrint('StackTrace: $stackTrace');
      return false;
    }
  }

  /// Gets an item by its Hive key. Returns null if not found.
  T? getItemByKey(dynamic key) {
    if (box == null) {
      debugPrint('Cannot get item by key: box is null');
      return null;
    }
    try {
      return box!.get(key);
    } catch (e, stackTrace) {
      debugPrint('Error getting item by key $key: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }
}
