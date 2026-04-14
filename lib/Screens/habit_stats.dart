import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../widgets/heatmap_calendar.dart';
import '../theme/app_theme.dart';

class HabitStatsScreen extends StatelessWidget {
  const HabitStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context);

    final total = provider.habits.length;
    final completed =
        provider.habits.where((h) => h.completed).length;
    final percent = (provider.completionRate * 100).toInt();

    final spots = provider.getWeeklySpots();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 12),

                Text(
                  "Your Progress",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),

                const SizedBox(height: 24),

                // 🔥 STATS CARDS
                Row(
                  children: [
                    Expanded(child: _statCard("Total", total.toString())),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard("Done", completed.toString())),
                    const SizedBox(width: 10),
                    Expanded(child: _statCard("Progress", "$percent%")),
                  ],
                ),

                const SizedBox(height: 30),

                // 🔥 HEATMAP
                Text(
                  "Consistency",
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: HeatmapCalendar(habits: provider.habits),
                ),

                const SizedBox(height: 30),

                // 📊 GRAPH
                Text(
                  "Weekly Activity",
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 220,
                  child: spots.every((e) => e.y == 0)
                      ? Center(
                    child: Text(
                      "No data yet 🚀",
                      style: TextStyle(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  )
                      : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 100,
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),

                      // 🔥 FIXED LABELS
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            getTitlesWidget: (value, meta) {
                              final now = DateTime.now();

                              final date = now.subtract(
                                Duration(days: 6 - value.toInt()),
                              );

                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  _getDayLabel(date),
                                  style: TextStyle(
                                    color: AppColors.textSecondaryDark,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),

                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.4,
                          barWidth: 4,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.5),
                            ],
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.25),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter:
                                (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: AppColors.primary,
                                strokeWidth: 0,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 DAY LABEL FUNCTION
  String _getDayLabel(DateTime date) {
    const days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];
    return days[date.weekday - 1];
  }

  // 🔥 STAT CARD
  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}