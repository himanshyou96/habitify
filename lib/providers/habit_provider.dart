import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/habit.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  Map<String, double> dailyProgress = {};

  // =========================
  // 🔥 COMPLETION RATE
  // =========================
  double get completionRate {
    if (_habits.isEmpty) return 0;
    final completed = _habits.where((h) => h.completed).length;
    return completed / _habits.length;
  }

  // =========================
  // ➕ ADD
  // =========================
  void addHabit(Habit habit) {
    _habits.add(habit);
    _updateDailyProgress();
    notifyListeners();
    saveHabits();
  }

  // =========================
  // ❌ DELETE
  // =========================
  void deleteHabit(int index) {
    _habits.removeAt(index);
    _updateDailyProgress();
    notifyListeners();
    saveHabits();
  }

  // =========================
  // 🔥 TOGGLE (FIXED + SAFE)
  // =========================
  void toggleHabit(int index) {
    final habit = _habits[index];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final alreadyDoneToday = habit.completedDates.any((d) =>
    d.year == today.year &&
        d.month == today.month &&
        d.day == today.day);

    if (!alreadyDoneToday) {
      // ✅ MARK COMPLETE
      habit.completed = true;
      habit.completedDates.add(today);

      // Previous completion date (before adding today)
      final prevDates = habit.completedDates
          .where((d) => d.isBefore(today))
          .toList()
        ..sort();

      final prevDate = prevDates.isNotEmpty ? prevDates.last : null;

      if (prevDate != null) {
        final diff = today.difference(prevDate).inDays;
        if (diff == 1) {
          habit.streak++;       // consecutive day
        } else {
          habit.streak = 1;     // streak broke
        }
      } else {
        habit.streak = 1;       // first ever completion
      }

      habit.lastCompletedDate = today;

    } else {
      // ❌ UNDO
      habit.completed = false;

      habit.completedDates.removeWhere((d) =>
      d.year == today.year &&
          d.month == today.month &&
          d.day == today.day);

      // Restore lastCompletedDate to previous date
      final prevDates = habit.completedDates
          .where((d) => d.isBefore(today))
          .toList()
        ..sort();

      habit.lastCompletedDate =
      prevDates.isNotEmpty ? prevDates.last : null;

      // Restore streak count
      habit.streak = habit.completedDates.length > 0
          ? habit.streak  // keep existing streak (wasn't today's responsibility)
          : 0;
    }

    _updateDailyProgress();
    notifyListeners();
    saveHabits();
  }

  // =========================
  // 📊 DAILY PROGRESS
  // =========================
  void _updateDailyProgress() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int completedToday = 0;

    for (var habit in _habits) {
      if (habit.completedDates.any((d) =>
      d.year == today.year &&
          d.month == today.month &&
          d.day == today.day)) {
        completedToday++;
      }
    }

    final key =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    dailyProgress[key] =
    _habits.isEmpty ? 0 : completedToday / _habits.length;
  }

  // =========================
  // 📈 WEEKLY GRAPH
  // =========================
  List<FlSpot> getWeeklySpots() {
    final now = DateTime.now();
    List<FlSpot> spots = [];

    for (int i = 6; i >= 0; i--) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));

      final key =
          "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

      final value = dailyProgress[key] ?? 0;

      spots.add(
        FlSpot((6 - i).toDouble(), value * 100),
      );
    }

    return spots;
  }

  // =========================
  // 🔄 DAILY RESET (IMPORTANT)
  // =========================
  void resetDailyHabits() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var habit in _habits) {
      if (habit.lastCompletedDate != null) {
        final last = habit.lastCompletedDate!;
        final lastDate = DateTime(
          last.year,
          last.month,
          last.day,
        );

        if (lastDate.year != today.year ||
            lastDate.month != today.month ||
            lastDate.day != today.day) {
          habit.completed = false;
        }
      } else {
        habit.completed = false;
      }
    }

    notifyListeners();
    saveHabits();
  }

  // =========================
  // 💾 SAVE
  // =========================
  Future<void> saveHabits() async {
    final prefs = await SharedPreferences.getInstance();

    final data =
    _habits.map((h) => jsonEncode(h.toJson())).toList();

    await prefs.setStringList('habits', data);

    await prefs.setString(
      'dailyProgress',
      jsonEncode(dailyProgress),
    );
  }

  // =========================
  // 📂 LOAD
  // =========================
  Future<void> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList('habits');

    if (data != null) {
      _habits = data
          .map((e) => Habit.fromJson(jsonDecode(e)))
          .toList();
    }

    final progressData = prefs.getString('dailyProgress');

    if (progressData != null) {
      dailyProgress =
      Map<String, double>.from(jsonDecode(progressData));
    }

    notifyListeners();
  }
}