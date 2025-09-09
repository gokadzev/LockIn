import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lockin/constants/app_constants.dart';
import 'package:lockin/core/models/journal.dart';
import 'package:lockin/features/journal/journal_provider.dart';
import 'package:lockin/themes/app_theme.dart';
import 'package:lockin/widgets/lockin_app_bar.dart';
import 'package:lockin/widgets/lockin_card.dart';
import 'package:lockin/widgets/lockin_dialog.dart';

class JournalHome extends ConsumerStatefulWidget {
  const JournalHome({super.key});

  @override
  ConsumerState<JournalHome> createState() => _JournalHomeState();
}

class _JournalHomeState extends ConsumerState<JournalHome> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final PageController _weekController;
  static final DateTime _weekRef = DateTime(1970, 1, 5); // Monday reference
  static const int _pageCenter = 20000;

  @override
  void initState() {
    super.initState();
    final weekIndex = _focusedDay.difference(_weekRef).inDays ~/ 7;
    _weekController = PageController(initialPage: _pageCenter + weekIndex);
  }

  @override
  void dispose() {
    _weekController.dispose();
    super.dispose();
  }

  bool isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final journalsRaw = ref.watch(journalsListProvider);
    final journals = journalsRaw.toList();
    final notifier = ref.read(journalsListProvider.notifier);
    final entriesByDay = <DateTime, List<Journal>>{};
    for (final j in journals) {
      final day = DateTime(j.date.year, j.date.month, j.date.day);
      entriesByDay.putIfAbsent(day, () => []).add(j);
    }
    final selectedDay =
        _selectedDay ??
        DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
    final selectedEntries = entriesByDay[selectedDay] ?? [];

    return Scaffold(
      appBar: const LockinAppBar(title: 'Journal'),
      body: Padding(
        padding: AppConstants.bodyPadding,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: LockinCard(
                // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(12),
                // ),
                // color: Colors.grey[900],
                child: Column(
                  children: [
                    // Header with chevrons and month title
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            color: scheme.onSurface,
                            onPressed: () {
                              setState(() {
                                _focusedDay = DateTime(
                                  _focusedDay.year,
                                  _focusedDay.month,
                                  _focusedDay.day - 7,
                                );
                                _selectedDay = null;
                              });
                            },
                          ),
                          Text(
                            DateFormat.yMMMM().format(_focusedDay),
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            color: scheme.onSurface,
                            onPressed: () {
                              setState(() {
                                _focusedDay = DateTime(
                                  _focusedDay.year,
                                  _focusedDay.month,
                                  _focusedDay.day + 7,
                                );
                                _selectedDay = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    // Swipeable week strip (pages by week)
                    SizedBox(
                      height: 112,
                      child: PageView.builder(
                        controller: _weekController,
                        onPageChanged: (page) {
                          final weekIndex = page - _pageCenter;
                          final firstOfWeek = _weekRef.add(
                            Duration(days: weekIndex * 7),
                          );
                          setState(() {
                            _focusedDay = firstOfWeek;
                            _selectedDay = null;
                          });
                        },
                        itemBuilder: (ctx, page) {
                          final weekIndex = page - _pageCenter;
                          final firstOfWeek = _weekRef.add(
                            Duration(days: weekIndex * 7),
                          );
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Row(
                              children: List.generate(7, (i) {
                                final day = DateTime(
                                  firstOfWeek.year,
                                  firstOfWeek.month,
                                  firstOfWeek.day + i,
                                );
                                final isSelected = isSameDay(_selectedDay, day);
                                final hasEntry =
                                    entriesByDay[DateTime(
                                          day.year,
                                          day.month,
                                          day.day,
                                        )]
                                        ?.isNotEmpty ??
                                    false;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDay = DateTime(
                                          day.year,
                                          day.month,
                                          day.day,
                                        );
                                        _focusedDay = day;
                                      });
                                    },
                                    child: Container(
                                      width: 84,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? scheme.onSurface
                                            : null,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 8,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            DateFormat.E().format(day),
                                            style: TextStyle(
                                              color: isSelected
                                                  ? scheme.onPrimary
                                                  : scheme.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          if (day.month == _focusedDay.month)
                                            Text(
                                              '${day.day}',
                                              style: TextStyle(
                                                color: isSelected
                                                    ? scheme.onPrimary
                                                    : scheme.onSurface,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          const SizedBox(height: 6),
                                          if (hasEntry)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? scheme.onPrimary
                                                    : scheme.primary,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Entries for',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                          Text(
                            DateFormat.yMMMMd().format(selectedDay),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildAddEntryButton(context, notifier, selectedDay),
                  ],
                ),
              ),
            ),
            if (selectedEntries.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book_outlined,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No entries for this day',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap "Add Entry" to record your thoughts',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final journal = selectedEntries[index];
                  return LockinCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row with mood and date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.sentiment_satisfied,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Mood: ${journal.mood}/10',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: scheme.onSurfaceVariant,
                                size: 28,
                              ),
                              onPressed: () =>
                                  notifier.deleteJournalByKey(journal.key),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Entry content
                        Text(
                          journal.entry ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Date at bottom
                        Text(
                          DateFormat.yMMMd().format(journal.date),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }, childCount: selectedEntries.length),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddEntryButton(
    BuildContext context,
    dynamic notifier,
    DateTime selectedDay,
  ) {
    final today = DateTime.now();
    final isFuture = selectedDay.isAfter(
      DateTime(today.year, today.month, today.day),
    );
    return ElevatedButton.icon(
      onPressed: isFuture
          ? null
          : () => _showAddEntryDialog(context, notifier, selectedDay),
      icon: const Icon(Icons.add, size: 18),
      label: const Text(
        'Add Entry',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _showAddEntryDialog(
    BuildContext context,
    dynamic notifier,
    DateTime selectedDay,
  ) async {
    final entryController = TextEditingController();
    final moodController = TextEditingController();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setState) => LockinDialog(
            title: const Text('Add Journal Entry'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: entryController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'What happened today?',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 4,
                  minLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: moodController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Mood (0-10)',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.sentiment_satisfied,
                      color: Colors.white,
                    ),
                    errorText: errorText,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final mood = int.tryParse(value);
                    if (mood == null || mood < 0 || mood > 10) {
                      setState(() => errorText = 'Enter a number from 0 to 10');
                    } else {
                      setState(() => errorText = null);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final mood = int.tryParse(moodController.text);
                  if (mood == null || mood < 0 || mood > 10) {
                    setState(() => errorText = 'Enter a number from 0 to 10');
                    return;
                  }
                  Navigator.pop(context, {
                    'entry': entryController.text,
                    'mood': moodController.text,
                  });
                },
                child: const Text('Add Entry'),
              ),
            ],
          ),
        );
      },
    );
    if (result != null && result['entry']!.isNotEmpty) {
      notifier.addJournal(
        Journal()
          ..entry = result['entry']
          ..date = selectedDay
          ..mood = int.tryParse(result['mood'] ?? '0') ?? 0,
      );
    }
  }
}
