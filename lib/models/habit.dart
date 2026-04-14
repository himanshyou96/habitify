import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String title;
  final String category;
  final String sub;
  final IconData icon;
  final Color color;
  final Color containerColor;
  final Color catColor;
  final Color catTextColor;

  bool completed;
  final bool wide;
  final double? progress;

  // 🔥 CORE LOGIC
  int streak;
  DateTime? lastCompletedDate;
  final List<DateTime> completedDates;

  // 🧊 NEW: STREAK FREEZE
  int freezeCount;

  Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.sub,
    required this.icon,
    required this.color,
    required this.containerColor,
    required this.catColor,
    required this.catTextColor,
    this.completed = false,
    this.wide = false,
    this.progress,
    this.streak = 0,
    this.lastCompletedDate,
    List<DateTime>? completedDates,
    this.freezeCount = 2, // 🔥 DEFAULT FREEZE
  }) : completedDates = completedDates ?? [];

  // 🔥 TO JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'sub': sub,
      'icon': icon.codePoint,
      'color': color.value,
      'containerColor': containerColor.value,
      'catColor': catColor.value,
      'catTextColor': catTextColor.value,
      'completed': completed,
      'wide': wide,
      'progress': progress,
      'streak': streak,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'completedDates':
      completedDates.map((d) => d.toIso8601String()).toList(),

      // 🧊 SAVE FREEZE
      'freezeCount': freezeCount,
    };
  }

  // 🔥 FROM JSON
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      sub: json['sub'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
      containerColor: Color(json['containerColor']),
      catColor: Color(json['catColor']),
      catTextColor: Color(json['catTextColor']),
      completed: json['completed'] ?? false,
      wide: json['wide'] ?? false,
      progress: json['progress'] != null
          ? (json['progress'] as num).toDouble()
          : null,
      streak: json['streak'] ?? 0,
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'])
          : null,
      completedDates: (json['completedDates'] as List?)
          ?.map((d) => DateTime.parse(d))
          .toList() ??
          [],

      // 🧊 LOAD FREEZE
      freezeCount: json['freezeCount'] ?? 2,
    );
  }
}