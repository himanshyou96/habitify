import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../models/habit.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static const int _dailyId = 0;

  // 🔥 INIT
  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _notifications.initialize(settings);
  }

  // 🔔 PERMISSION
  static Future<void> requestPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  // 🔥 SMART DAILY REMINDER (UPGRADED)
  static Future<void> scheduleSmartReminder(List<Habit> habits) async {
    // 🔥 Cancel old scheduled notification (avoid duplicates)
    await _notifications.cancel(_dailyId);

    final total = habits.length;
    final completed = habits.where((h) => h.completed).length;

    // ❌ NO HABITS
    if (total == 0) {
      await _showNow(
        "Start your journey 🚀",
        "Add your first habit today!",
      );
      return;
    }

    // ❌ ALL COMPLETED → NO NOTIFICATION
    if (completed == total) return;

    // 🔥 STREAK RISK DETECTION
    final bool streakRisk =
    habits.any((h) => h.streak >= 3 && !h.completed);

    String title;
    String body;

    if (streakRisk) {
      title = "Streak at risk 🔥";
      body = "Don't break your streak! Complete it now.";
    } else {
      title = "Stay consistent 💪";
      body = "You have ${total - completed} habits left today.";
    }

    await _notifications.zonedSchedule(
      _dailyId,
      title,
      body,
      _nextInstanceOfTime(21, 0), // 🕘 9 PM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_channel',
          'Habit Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ⚡ TEST NOTIFICATION
  static Future<void> testNow() async {
    await _notifications.show(
      999,
      'Test Notification 🚀',
      'Smart notification system working perfectly!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ⚡ INSTANT SHOW (PRIVATE)
  static Future<void> _showNow(String title, String body) async {
    await _notifications.show(
      1,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'smart_channel',
          'Smart Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // ⏰ NEXT TIME CALCULATION (SAFE)
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}