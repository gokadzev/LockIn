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
import 'package:lockin/core/utils/mood_icon.dart';
import 'package:lockin/features/journal/journal_provider.dart';
import 'package:lockin/widgets/lockin_app_bar.dart';
import 'package:lockin/widgets/lockin_card.dart';
import 'package:lockin/widgets/lockin_dialog.dart';
import 'package:lockin/widgets/lockin_journal_card.dart';

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

  DateTime _startOfDay(DateTime day) => DateTime(day.year, day.month, day.day);

  void _jumpToDay(DateTime day) {
    final normalized = _startOfDay(day);
    setState(() => _selectedDay = normalized);
    final dayIndex = normalized.difference(_weekRef).inDays;
    final pageIndex = dayIndex ~/ _daysPerPage;
    _weekController.animateToPage(
      _pageCenter + pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickDateFromMonthHeader(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startOfDay(_selectedDay),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100, 12, 31),
      helpText: 'Select date',
    );
    if (picked == null) return;
    _jumpToDay(picked);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final journalsRaw = ref.watch(journalsListProvider);
    final journals = journalsRaw.toList();
    final notifier = ref.read(journalsListProvider.notifier);
    final entriesByDay = <DateTime, List<Journal>>{};
    for (final j in journals) {
      final day = DateTime(j.date.year, j.date.month, j.date.day);
      entriesByDay.putIfAbsent(day, () => []).add(j);
    }
    final selectedDay = _startOfDay(_selectedDay);
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            color: colorScheme.onSurface,
                            onPressed: () {
                              _weekController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () =>
                                      _pickDateFromMonthHeader(context),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          DateFormat.yMMMM().format(
                                            _selectedDay,
                                          ),
                                          style: textTheme.titleLarge?.copyWith(
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.calendar_month_rounded,
                                          size: 18,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Swipe to browse days',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            color: colorScheme.onSurface,
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
                    SizedBox(
                      height: 112,
                      child: PageView.builder(
                        controller: _weekController,
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
                                        _selectedDay = _startOfDay(day);
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? colorScheme.secondaryContainer
                                            : colorScheme.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? colorScheme.secondary
                                              : colorScheme.outlineVariant,
                                        ),
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
                                                  ? colorScheme
                                                        .onSecondaryContainer
                                                  : colorScheme.onSurface,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          if (day.month == _selectedDay.month)
                                            Text(
                                              '${day.day}',
                                              style: TextStyle(
                                                color: isSelected
                                                    ? colorScheme
                                                          .onSecondaryContainer
                                                    : colorScheme.onSurface,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          if (day.month != _selectedDay.month)
                                            Text(
                                              '${day.day}',
                                              style: TextStyle(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          const SizedBox(height: 6),
                                          if (hasEntry)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? colorScheme
                                                          .onSecondaryContainer
                                                    : colorScheme.secondary,
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
                  return LockinJournalCard(
                    journal: journal,
                    onDelete: (key) => notifier.deleteJournalByKey(key),
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
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final isToday =
        selectedDay.year == todayStart.year &&
        selectedDay.month == todayStart.month &&
        selectedDay.day == todayStart.day;
    return FilledButton.icon(
      onPressed: isToday
          ? () => _showAddEntryDialog(context, notifier, selectedDay)
          : null,
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
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        String? errorText;
        var mood = 6.0;
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
                Row(
                  children: [
                    Icon(moodIcon(mood.round()), color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Mood: ${mood.round()}/10',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Slider(
                  max: 10,
                  divisions: 10,
                  value: mood,
                  onChanged: (value) {
                    setState(() {
                      mood = value;
                      errorText = null;
                    });
                  },
                ),
                if (errorText != null)
                  Text(
                    errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
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
              FilledButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'entry': entryController.text,
                    'mood': mood.round(),
                  });
                },
                child: const Text('Add Entry'),
              ),
            ],
          ),
        );
      },
    );
    if (result != null && (result['entry'] as String).isNotEmpty) {
      final postedDate = DateTime.now();
      notifier.addJournal(
        Journal()
          ..entry = result['entry']
          ..date = postedDate
          ..mood = result['mood'] as int,
      );
    }
  }
}
