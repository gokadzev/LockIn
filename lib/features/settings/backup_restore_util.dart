import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:lockin/core/models/goal.dart';
import 'package:lockin/core/models/habit.dart';
import 'package:lockin/core/models/journal.dart';
import 'package:lockin/core/models/session.dart';
import 'package:lockin/core/models/task.dart';

class BackupRestoreUtil {
  static Future<String> exportAllData() async {
    final tasks = Hive.box<Task>('tasks').values.toList();
    final goals = Hive.box<Goal>('goals').values.toList();
    final journals = Hive.box<Journal>('journals').values.toList();
    final habits = Hive.box<Habit>('habits').values.toList();
    final sessions = Hive.box<Session>('sessions').values.toList();

    final data = {
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'goals': goals.map((g) => g.toJson()).toList(),
      'journals': journals.map((j) => j.toJson()).toList(),
      'habits': habits.map((h) => h.toJson()).toList(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
    };
    return jsonEncode(data);
  }

  static Future<String> saveBackupFile(String jsonData) async {
    final backupDir = Directory('/storage/emulated/0/Download/LockinBackup');

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    final filePath =
        '${backupDir.path}/lockin_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File(filePath);
    await file.writeAsString(jsonData);
    return filePath;
  }

  static Future<Map<String, dynamic>> importBackupFile(File file) async {
    try {
      final content = await file.readAsString();
      return jsonDecode(content);
    } catch (e) {
      debugPrint('Error importing backup file: $e');
      return {};
    }
  }

  static Future<void> restoreAllData(Map<String, dynamic> data) async {
    final tasksBox = Hive.box<Task>('tasks');
    final goalsBox = Hive.box<Goal>('goals');
    final journalsBox = Hive.box<Journal>('journals');
    final habitsBox = Hive.box<Habit>('habits');
    final sessionsBox = Hive.box<Session>('sessions');

    await tasksBox.clear();
    await goalsBox.clear();
    await journalsBox.clear();
    await habitsBox.clear();
    await sessionsBox.clear();

    for (final t in data['tasks'] ?? []) {
      await tasksBox.add(Task.fromJson(t));
    }
    for (final g in data['goals'] ?? []) {
      await goalsBox.add(Goal.fromJson(g));
    }
    for (final j in data['journals'] ?? []) {
      await journalsBox.add(Journal.fromJson(j));
    }
    for (final h in data['habits'] ?? []) {
      await habitsBox.add(Habit.fromJson(h));
    }
    for (final s in data['sessions'] ?? []) {
      await sessionsBox.add(Session.fromJson(s));
    }
  }
}
