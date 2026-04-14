import 'package:flutter/material.dart';
import '../models/habit.dart';

class HeatmapCalendar extends StatelessWidget {
  final List<Habit> habits;

  const HeatmapCalendar({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    // 🔥 180 days
    final days = List.generate(180, (i) {
      return DateTime(today.year, today.month, today.day - i);
    }).reversed.toList();

    // 🔥 ALIGN MONDAY START
    int startOffset = days.first.weekday - 1;

    List<DateTime?> alignedDays = [
      ...List.generate(startOffset, (_) => null),
      ...days
    ];

    // 🔥 SPLIT INTO WEEKS
    List<List<DateTime?>> weeks = [];
    for (int i = 0; i < alignedDays.length; i += 7) {
      weeks.add(alignedDays.sublist(
        i,
        i + 7 > alignedDays.length ? alignedDays.length : i + 7,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // 🔥 SINGLE SCROLL (IMPORTANT FIX)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔥 MONTH LABELS
              Row(
                children: weeks.map((week) {
                  final firstValid =
                  week.firstWhere((d) => d != null, orElse: () => null);

                  return SizedBox(
                    width: 14,
                    child: (firstValid != null && firstValid.day <= 7)
                        ? Text(
                      _month(firstValid.month),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    )
                        : const SizedBox(),
                  );
                }).toList(),
              ),

              const SizedBox(height: 6),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🔥 WEEK LABELS (LEFT)
                  Column(
                    children: const [
                      SizedBox(height: 4),
                      Text("Mon",
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                      SizedBox(height: 18),
                      Text("Wed",
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                      SizedBox(height: 18),
                      Text("Fri",
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),

                  const SizedBox(width: 6),

                  // 🔥 GRID
                  Row(
                    children: weeks.map((week) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Column(
                          children: List.generate(7, (index) {
                            final day =
                            index < week.length ? week[index] : null;

                            if (day == null) {
                              return const SizedBox(
                                width: 10,
                                height: 10,
                              );
                            }

                            final count = _count(day);

                            final isToday =
                                day.year == today.year &&
                                    day.month == today.month &&
                                    day.day == today.day;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 3),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _color(count),
                                borderRadius: BorderRadius.circular(2),
                                border: isToday
                                    ? Border.all(
                                  color: Colors.white,
                                  width: 1,
                                )
                                    : null,
                              ),
                            );
                          }),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 🔥 LEGEND
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text("Less",
                style: TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(width: 6),
            ...List.generate(5, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _legendColor(i),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
            const SizedBox(width: 6),
            const Text("More",
                style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  // 🔥 MONTH NAME
  String _month(int m) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[m - 1];
  }

  // 🔥 COUNT COMPLETED HABITS
  int _count(DateTime day) {
    int count = 0;

    for (var habit in habits) {
      for (var d in habit.completedDates) {
        if (d.year == day.year &&
            d.month == day.month &&
            d.day == day.day) {
          count++;
        }
      }
    }

    return count;
  }

  // 🎨 GITHUB COLORS
  Color _color(int count) {
    if (count == 0) return const Color(0xFF161B22);
    if (count == 1) return const Color(0xFF0E4429);
    if (count == 2) return const Color(0xFF006D32);
    if (count == 3) return const Color(0xFF26A641);
    return const Color(0xFF39D353);
  }

  Color _legendColor(int i) {
    switch (i) {
      case 0:
        return const Color(0xFF161B22);
      case 1:
        return const Color(0xFF0E4429);
      case 2:
        return const Color(0xFF006D32);
      case 3:
        return const Color(0xFF26A641);
      default:
        return const Color(0xFF39D353);
    }
  }
}