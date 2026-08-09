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

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/core/utils/hive_utils.dart';

/// Shared CRUD operations for Hive-backed Riverpod notifiers.
mixin BoxCrudMixin<T> on Notifier<List<T>> {
  /// The Hive box backing this notifier.
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
  Future<void> addItem(T item) async {
    if (box == null) {
      debugPrint('Cannot add item: box is null');
      return;
    }
    try {
      await box!.add(item);
      syncStateFromBox();
    } catch (e, stackTrace) {
      debugPrint('Error adding item to box: $e');
      debugPrint('StackTrace: $stackTrace');
      // Still try to keep state consistent
      syncStateFromBox();
    }
  }

  /// Updates an item at [index] in the box and updates state efficiently.
  Future<bool> updateItem(int index, T item) async {
    if (box == null) {
      debugPrint('Cannot update item: box is null');
      return false;
    }
    if (index < 0 || index >= box!.length) {
      debugPrint('Invalid index $index for box with length ${box!.length}');
      return false;
    }
    try {
      await box!.putAt(index, item);
      if (index < state.length) {
        final updated = List<T>.from(state);
        updated[index] = item;
        state = updated;
      } else {
        syncStateFromBox();
      }
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error updating item at index $index: $e');
      debugPrint('StackTrace: $stackTrace');
      syncStateFromBox();
      return false;
    }
  }

  /// Prepares and persists an item, then applies effects only after success.
  Future<bool> updateItemWithPrevious(
    int index,
    T item, {
    required T Function(T? previous) prepare,
    void Function(T? previous, T updated)? onSuccess,
  }) async {
    if (box == null || index < 0 || index >= box!.length) return false;
    final previous = box!.getAt(index);
    final updated = prepare(previous);
    final success = await updateItem(index, updated);
    if (success) onSuccess?.call(previous, updated);
    return success;
  }

  /// Returns the current list index for a Hive key, or null when absent.
  int? indexForKey(dynamic key) {
    if (box == null) return null;
    final index = box!.keys.toList().indexOf(key);
    return index == -1 ? null : index;
  }

  /// Deletes an item at [index] from the box and updates state.
  Future<void> deleteItem(int index) async {
    if (box == null) {
      debugPrint('Cannot delete item: box is null');
      return;
    }
    if (index < 0 || index >= box!.length) {
      debugPrint('Invalid index $index for box with length ${box!.length}');
      return;
    }
    try {
      await box!.deleteAt(index);
      syncStateFromBox();
    } catch (e, stackTrace) {
      debugPrint('Error deleting item at index $index: $e');
      debugPrint('StackTrace: $stackTrace');
      syncStateFromBox();
    }
  }

  /// Updates an item by its Hive key. Returns true if update succeeded.
  Future<bool> updateItemByKey(dynamic key, T item) async {
    if (box == null) {
      debugPrint('Cannot update item by key: box is null');
      return false;
    }
    try {
      if (!box!.containsKey(key)) {
        debugPrint('Key $key not found in box');
        return false;
      }

      await box!.put(key, item);

      syncStateFromBox();

      return true;
    } catch (e, stackTrace) {
      debugPrint('Error updating item by key $key: $e');
      debugPrint('StackTrace: $stackTrace');
      return false;
    }
  }

  /// Deletes an item by its Hive key. Returns true if deletion succeeded.
  Future<bool> deleteItemByKey(dynamic key) async {
    if (box == null) {
      debugPrint('Cannot delete item by key: box is null');
      return false;
    }
    try {
      if (!box!.containsKey(key)) {
        debugPrint('Key $key not found in box');
        return false;
      }

      await box!.delete(key);
      syncStateFromBox();
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

/// Base notifier that provides the shared Hive box lifecycle.
abstract class BoxCrudNotifier<T> extends Notifier<List<T>>
    with BoxCrudMixin<T> {
  /// The Hive box name backing this notifier.
  String get boxName;

  Box<T>? _box;

  @override
  Box<T>? get box => _box;

  @override
  List<T> build() {
    stopWatchingBox();
    _box = openBoxIfAvailable<T>(boxName);
    startWatchingBox();
    ref.onDispose(stopWatchingBox);
    return _box?.values.toList() ?? [];
  }
}
