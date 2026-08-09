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

final journalsListProvider = NotifierProvider<JournalsNotifier, List<Journal>>(
  JournalsNotifier.new,
);

class JournalsNotifier extends BoxCrudNotifier<Journal> {
  @override
  String get boxName => HiveBoxes.journals;

  Future<void> addJournal(Journal journal) => addItem(journal);
  Future<void> updateJournal(int index, Journal journal) async {
    await updateItem(index, journal);
  }

  Future<void> deleteJournal(int index) => deleteItem(index);

  Future<void> updateJournalByKey(dynamic key, Journal journal) async {
    final index = indexForKey(key);
    if (index == null) return;
    await updateJournal(index, journal);
  }

  Future<bool> deleteJournalByKey(dynamic key) {
    if (box == null) return Future.value(false);
    return deleteItemByKey(key);
  }
}
