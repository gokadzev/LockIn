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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lockin/constants/app_constants.dart';
import 'package:lockin/core/models/journal.dart';
import 'package:lockin/features/journal/journal_provider.dart';
import 'package:lockin/widgets/lockin_app_bar.dart';
import 'package:lockin/widgets/lockin_card.dart';
import 'package:lockin/widgets/lockin_dialog.dart';

class JournalHome extends ConsumerStatefulWidget {
  const JournalHome({super.key});

  @override
  ConsumerState<JournalHome> createState() => _JournalHomeState();
}

class _JournalHomeState extends ConsumerState<JournalHome> {
  late DateTime _selectedDay;
  late final PageController _weekController;
  static final DateTime _weekRef = DateTime(1970, 1, 5); // Reference date
  static const int _pageCenter = 20000;
  static const int _daysPerPage = 3;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    final dayIndex = _selectedDay.difference(_weekRef).inDays;
    final pageIndex = dayIndex ~/ _daysPerPage;
    _weekController = PageController(initialPage: _pageCenter + pageIndex);
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
    final scheme = Theme.of(context).colorScheme;
    final journalsRaw = ref.watch(journalsListProvider);
    final journals = journalsRaw.toList();
    final notifier = ref.read(journalsListProvider.notifier);
    final entriesByDay = <DateTime, List<Journal>>{};
    for (final j in journals) {
      final day = DateTime(j.date.year, j.date.month, j.date.day);
      entriesByDay.putIfAbsent(day, () => []).add(j);
    }
    final selectedDay = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    final selectedEntries = entriesByDay[selectedDay] ?? [];

    return Scaffold(
      appBar: const LockinAppBar(title: 'Journal'),
      body: Padding(
        padding: AppConstants.bodyPadding,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: LockinCard(
                child: Column(
                  children: [
                    // Header with chevrons and month title
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            color: scheme.onSurface,
                            onPressed: () {
                              _weekController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                          Column(
                            children: [
                              Text(
                                DateFormat.yMMMM().format(_selectedDay),
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            color: scheme.onSurface,
                            onPressed: () {
                              _weekController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Swipeable day strip (pages by 3 days)
                    SizedBox(
                      height: 112,
                      child: PageView.builder(
                        controller: _weekController,
                        onPageChanged: (page) {
                          // Keep the selected day unchanged when paging.
                        },
                        itemBuilder: (ctx, page) {
                          final pageIndex = page - _pageCenter;
                          final firstOfChunk = _weekRef.add(
                            Duration(days: pageIndex * _daysPerPage),
                          );
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Row(
                              children: List.generate(_daysPerPage, (i) {
                                final day = DateTime(
                                  firstOfChunk.year,
                                  firstOfChunk.month,
                                  firstOfChunk.day + i,
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
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDay = DateTime(
                                          day.year,
                                          day.month,
                                          day.day,
                                        );
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? scheme.secondaryContainer
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
                                                  ? scheme.onSecondaryContainer
                                                  : scheme.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          if (day.month == _selectedDay.month)
                                            Text(
                                              '${day.day}',
                                              style: TextStyle(
                                                color: isSelected
                                                    ? scheme
                                                          .onSecondaryContainer
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
                                                    ? scheme
                                                          .onSecondaryContainer
                                                    : scheme.secondary,
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
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => LockinDialog(
                                    title: const Text('Delete entry'),
                                    content: const Text(
                                      'Are you sure you want to delete this entry?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  notifier.deleteJournalByKey(journal.key);
                                }
                              },
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
