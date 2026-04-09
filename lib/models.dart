import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TaskCategory { work, personal }

class TodoTask {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final DateTime? dueDate;
  final bool isUrgent;
  bool isDone;
  final Color? leftDeco;
  final TaskCategory category;

  TodoTask({
    required this.id,
    required this.title,
    required this.subtitle,
    this.description = '',
    this.dueDate,
    this.isUrgent = false,
    this.isDone = false,
    this.leftDeco,
    this.category = TaskCategory.personal,
  });

TodoTask copyWith({
String? id,
String? title,
String? subtitle,
String? description,
DateTime? dueDate,
bool? isUrgent,
bool? isDone,
Color? leftDeco,
TaskCategory? category,
}) {
return TodoTask(
id: id ?? this.id,
title: title ?? this.title,
subtitle: subtitle ?? this.subtitle,
description: description ?? this.description,
dueDate: dueDate ?? this.dueDate,
isUrgent: isUrgent ?? this.isUrgent,
isDone: isDone ?? this.isDone,
leftDeco: leftDeco ?? this.leftDeco,
category: category ?? this.category,
);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'isUrgent': isUrgent,
      'isDone': isDone,
      'leftDeco': leftDeco?.value,
      'category': category.index,
    };
  }

  static TodoTask fromJson(Map<String, dynamic> json) {
    return TodoTask(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'] ?? '',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isUrgent: json['isUrgent'] ?? false,
      isDone: json['isDone'] ?? false,
      leftDeco: json['leftDeco'] != null ? Color(json['leftDeco']) : null,
      category: TaskCategory.values[json['category'] ?? 0],
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
  });

  static List<Achievement> get defaultAchievements => [
        Achievement(
          id: 'first_task',
          title: 'First Task',
          description: 'Complete your first task',
          icon: Icons.star,
        ),
        Achievement(
          id: 'early_bird',
          title: 'Early Bird',
          description: 'Complete a task before 7:00 AM',
          icon: Icons.wb_sunny,
        ),
        Achievement(
          id: 'night_owl',
          title: 'Night Owl',
          description: 'Complete a task after 10:00 PM',
          icon: Icons.nightlight_round,
        ),
        Achievement(
          id: 'urgent_fighter',
          title: 'Urgent Fighter',
          description: 'Complete 5 urgent tasks',
          icon: Icons.bolt,
        ),
        Achievement(
          id: 'productivity_master',
          title: 'Productivity Master',
          description: 'Complete 10 tasks in total',
          icon: Icons.emoji_events,
        ),
        Achievement(
          id: 'streak_master',
          title: 'Streak Master',
          description: 'Maintain a 3-day completion streak',
          icon: Icons.local_fire_department,
        ),
      ];
}

class AchievementManager {
  static bool _isProcessing = false;
  static final List<Function> _queue = [];

  static Future<void> checkAndUnlock(TodoTask task, {void Function(String)? onAchievementUnlocked}) async {
    if (_isProcessing) {
      _queue.add(() => checkAndUnlock(task, onAchievementUnlocked: onAchievementUnlocked));
      return;
    }
    if (!task.isDone) return;
    _isProcessing = true;
    try {
      await _doCheckAndUnlock(task, onAchievementUnlocked);
    } finally {
      _isProcessing = false;
      if (_queue.isNotEmpty) {
        final next = _queue.removeAt(0);
        next();
      }
    }
  }

  static Future<void> _doCheckAndUnlock(TodoTask task, void Function(String)? onAchievementUnlocked) async {

    final prefs = await SharedPreferences.getInstance();
    List<String> unlockedIds = prefs.getStringList('unlocked_achievement_ids') ?? [];
    
    bool newlyUnlocked = false;

void unlock(String id) {
if (!unlockedIds.contains(id)) {
unlockedIds.add(id);
        newlyUnlocked = true;
        onAchievementUnlocked?.call(id);
}
}

    // Logic: 'first_task' - Unlock on first completion
    unlock('first_task');

    // Logic: 'early_bird' - completion time < 7 AM
    final now = DateTime.now();
    if (now.hour < 7) {
      unlock('early_bird');
    }

    // Logic: 'night_owl' - completion time > 10 PM (22:00)
    if (now.hour >= 22) {
      unlock('night_owl');
    }

    // Update counts for other achievements
    int totalDone = (prefs.getInt('tasks_done') ?? 0) + 1;
    await prefs.setInt('tasks_done', totalDone);

    // Update streak logic
    String todayDate = now.toIso8601String().split('T')[0];
    String? lastDateStr = prefs.getString('last_completion_date');
    if (lastDateStr != todayDate) {
      int streak = prefs.getInt('streak_days') ?? 0;
      if (lastDateStr != null) {
        DateTime lastDate = DateTime.parse(lastDateStr);
        DateTime today = DateTime.parse(todayDate);
        int diff = today.difference(lastDate).inDays;
        if (diff == 1) {
          streak++;
        } else if (diff > 1) {
          streak = 1;
        }
      } else {
        streak = 1;
      }
      await prefs.setInt('streak_days', streak);
      await prefs.setString('last_completion_date', todayDate);
    }
    
    // Update weekly progress
    // Update weekly progress - mapping current day to index (0=Mon, 6=Sun)
    String? weeklyProgressStr = prefs.getString('weekly_progress');
    List<int> weeklyProgress;
    if (weeklyProgressStr != null) {
      try {
        weeklyProgress = List<int>.from(jsonDecode(weeklyProgressStr));
      } catch (_) {
        weeklyProgress = List.generate(7, (_) => 0);
      }
    } else {
      weeklyProgress = List.generate(7, (_) => 0);
    }
    
    if (weeklyProgress.length == 7) {
      int dayIndex = (now.weekday - 1) % 7; // Mon=0, Sun=6
      weeklyProgress[dayIndex]++;
      await prefs.setString('weekly_progress', jsonEncode(weeklyProgress));
    }

    // Logic: 'urgent_fighter' - 5 urgent tasks
    if (task.isUrgent) {
      int urgentDone = (prefs.getInt('urgent_tasks_done') ?? 0) + 1;
      await prefs.setInt('urgent_tasks_done', urgentDone);
      if (urgentDone >= 5) {
        unlock('urgent_fighter');
      }
    }

    // Logic: 'productivity_master' - 10 tasks in total
    // Logic: 'streak_master' - 3 days streak
    int currentStreak = prefs.getInt('streak_days') ?? 0;
    if (currentStreak >= 3) {
      unlock('streak_master');
    }

    if (totalDone >= 10) {
      unlock("productivity_master");
    }
    // Logic: 'productivity_master' - 10 tasks in total
    if (newlyUnlocked) {
      await prefs.setStringList('unlocked_achievement_ids', unlockedIds);
    }
  }
}
