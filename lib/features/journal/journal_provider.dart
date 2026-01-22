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
import 'package:lockin/core/models/journal.dart';
import 'package:lockin/core/utils/box_crud_mixin.dart';
import 'package:lockin/core/utils/hive_utils.dart';

final journalsBoxProvider = Provider<Box<Journal>?>((ref) {
  return openBoxIfAvailable<Journal>(HiveBoxes.journals);
});

final journalsListProvider =
    StateNotifierProvider<JournalsNotifier, List<Journal>>((ref) {
      final box = ref.watch(journalsBoxProvider);
      return JournalsNotifier(box)..startWatchingBox();
    });

class JournalsNotifier extends StateNotifier<List<Journal>>
    with BoxCrudMixin<Journal> {
  JournalsNotifier(this.box) : super(box?.values.toList() ?? []);
  @override
  final Box<Journal>? box;

  void addJournal(Journal journal) => addItem(journal);
  void updateJournal(int index, Journal journal) => updateItem(index, journal);
  void deleteJournal(int index) => deleteItem(index);

  void updateJournalByKey(dynamic key, Journal journal) {
    if (box == null) return;
    if (!box!.containsKey(key)) return;
    updateItemByKey(key, journal);
  }

  void deleteJournalByKey(dynamic key) {
    if (box == null) return;
    deleteItemByKey(key);
  }

  @override
  void dispose() {
    stopWatchingBox();
    super.dispose();
  }
}
