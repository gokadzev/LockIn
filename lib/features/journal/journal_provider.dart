import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/core/models/journal.dart';
import 'package:lockin/core/utils/box_crud_mixin.dart';

final journalsBoxProvider = Provider<Box<Journal>?>((ref) {
  try {
    return Hive.isBoxOpen('journals') ? Hive.box<Journal>('journals') : null;
  } catch (e) {
    return null;
  }
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
    updateItemByKey(key, journal, onSuccess: () {});
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
