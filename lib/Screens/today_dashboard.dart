import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart'; // 🔥 ADD THIS

class TodayDashboardScreen extends StatelessWidget {
  final VoidCallback? onExploreTap;

  const TodayDashboardScreen({super.key, this.onExploreTap});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context);

    final total = provider.habits.length;
    final completedCount =
        provider.habits.where((h) => h.completed).length;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 12),

              Text(
                "Your Day",
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 24),

              // 🔥 PROGRESS CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Progress",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$completedCount / $total",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),

                    TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: total == 0
                            ? 0
                            : provider.completionRate,
                      ),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [

                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CustomPaint(
                                painter: _ProgressRingPainter(value),
                              ),
                            ),

                            Text(
                              "${(value * 100).toInt()}%",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.05),
              ),

              const SizedBox(height: 16),

              Text(
                total == 0
                    ? "Start your first habit 🚀"
                    : provider.completionRate == 1
                    ? "Perfect day 🔥"
                    : provider.completionRate > 0.5
                    ? "You're doing great 👊"
                    : "Keep going 💪",
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 24),

              Text(
                "Today",
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 10),

              // 🔥 TEST BUTTON (REMOVE LATER)
              ElevatedButton(
                onPressed: () async {
                  await NotificationService.testNow();
                },
                child: const Text("Test Notification"),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: provider.habits.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Text("🚀",
                          style: TextStyle(fontSize: 42)),

                      const SizedBox(height: 10),

                      Text(
                        "No habits yet",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Start your journey from Discover",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          onExploreTap?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Explore Habits"),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  physics:
                  const BouncingScrollPhysics(),
                  itemCount: provider.habits.length,
                  itemBuilder: (context, index) {
                    final habit =
                    provider.habits[index];

                    return InkWell(
                      borderRadius:
                      BorderRadius.circular(18),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        provider.toggleHabit(index);
                      },
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (_) =>
                              AlertDialog(
                                backgroundColor:
                                AppColors.darkCard,
                                title: const Text(
                                  "Delete Habit?",
                                  style: TextStyle(
                                      color:
                                      Colors.white),
                                ),
                                content: const Text(
                                  "This action cannot be undone",
                                  style: TextStyle(
                                      color: Colors
                                          .white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(
                                            context),
                                    child: const Text(
                                        "Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      provider
                                          .deleteHabit(
                                          index);
                                      Navigator.pop(
                                          context);
                                    },
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(
                                          color:
                                          Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: Container(
                        margin:
                        const EdgeInsets.only(
                            bottom: 12),
                        padding:
                        const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius:
                          BorderRadius.circular(
                              18),
                        ),
                        child: Row(
                          children: [

                            Icon(habit.icon,
                                color:
                                AppColors.primary),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                habit.title,
                                style:
                                const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            Text(
                              "🔥 ${habit.streak}",
                              style: TextStyle(
                                color: AppColors
                                    .textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔥 PROGRESS RING
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  _ProgressRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center =
    Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final bgPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0, 1),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) =>
      old.progress != progress;
}