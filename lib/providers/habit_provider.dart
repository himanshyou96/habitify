import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/habit.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  Map<String, double> dailyProgress = {};

  double get completionRate {
    if (_habits.isEmpty) return 0;
    final completed = _habits.where((h) => h.completed).length;
    return completed / _habits.length;
  }

  // 🏆 BADGE SYSTEM
  String getStreakBadge(int streak) {
    if (streak >= 100) return "👑 Legend";
    if (streak >= 50) return "🔥 Elite";
    if (streak >= 30) return "💎 Pro";
    if (streak >= 7) return "⚡ Rising";
    return "🌱 Beginner";
  }

  // ➕ ADD
  void addHabit(Habit habit) {
    _habits.add(habit);
    _updateDailyProgress();
    saveHabits();
    notifyListeners();
  }

  // ❌ DELETE
  void deleteHabit(int index) {
    _habits.removeAt(index);
    _updateDailyProgress();
    saveHabits();
    notifyListeners();
  }

  // 🔥 FINAL TOGGLE WITH FREEZE
  void toggleHabit(int index) {
    final habit = _habits[index];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 🔁 TOGGLE
    habit.completed = !habit.completed;

    if (habit.completed) {
      // ✅ prevent duplicate date
      if (!habit.completedDates.any((d) =>
      d.year == today.year &&
          d.month == today.month &&
          d.day == today.day)) {
        habit.completedDates.add(today);
      }

      if (habit.lastCompletedDate != null) {
        final last = habit.lastCompletedDate!;
        final lastDate = DateTime(last.year, last.month, last.day);

        final diff = today.difference(lastDate).inDays;

        if (diff == 1) {
          // 🔥 CONTINUE STREAK
          habit.streak++;
        } else if (diff > 1) {
          // ❌ MISSED DAYS

          if (habit.freezeCount > 0) {
            // 🧊 USE FREEZE
            habit.freezeCount--;

            debugPrint("❄️ Freeze used. Left: ${habit.freezeCount}");

            // streak remains SAME
          } else {
            // 💥 RESET
            habit.streak = 1;
          }
        }
      } else {
        // 🆕 FIRST TIME
        habit.streak = 1;
      }

      habit.lastCompletedDate = today;
    } else {
      // ❌ UNDO
      habit.completedDates.removeWhere((d) =>
      d.year == today.year &&
          d.month == today.month &&
          d.day == today.day);

      if (habit.streak > 0) habit.streak--;
    }

    _updateDailyProgress();
    saveHabits();
    notifyListeners();
  }

  // 📊 DAILY PROGRESS
  void _updateDailyProgress() {
    final now = DateTime.now();

    final key =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    dailyProgress[key] = completionRate;
  }

  // 📈 WEEK GRAPH
  List<FlSpot> getWeeklySpots() {
    final now = DateTime.now();
    List<FlSpot> spots = [];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));

      final key =
          "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

      final value = dailyProgress[key] ?? 0;

      spots.add(
        FlSpot((6 - i).toDouble(), value * 100),
      );
    }

    return spots;
  }

  // 💾 SAVE
  Future<void> saveHabits() async {
    final prefs = await SharedPreferences.getInstance();

    final habitData =
    _habits.map((h) => jsonEncode(h.toJson())).toList();

    await prefs.setStringList('habits', habitData);

    await prefs.setString(
      'dailyProgress',
      jsonEncode(dailyProgress),
    );
  }

  // 📂 LOAD
  Future<void> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();

    final habitData = prefs.getStringList('habits');

    if (habitData != null) {
      _habits = habitData
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

  // 🔥 DAILY RESET (FINAL FIXED)
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

        // ❌ अगर आज नहीं है → reset
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
}