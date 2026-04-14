import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

class HabitLibraryScreen extends StatefulWidget {
  const HabitLibraryScreen({super.key});

  @override
  State<HabitLibraryScreen> createState() => _HabitLibraryScreenState();
}

class _HabitLibraryScreenState extends State<HabitLibraryScreen> {
  IconData _selectedIcon = Icons.star;

  // 🔥 ICON OPTIONS
  final List<IconData> _iconOptions = [
    Icons.star,
    Icons.water_drop,
    Icons.menu_book,
    Icons.fitness_center,
    Icons.self_improvement,
    Icons.directions_run,
    Icons.bedtime,
    Icons.local_drink,
  ];

  // 🔥 MASSIVE HABIT LIST (REAL APP LEVEL)
  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Mindfulness',
      'habits': [
        {'name': 'Meditation', 'detail': '10 min daily', 'icon': Icons.self_improvement},
        {'name': 'Gratitude Journal', 'detail': '5 min', 'icon': Icons.edit},
        {'name': 'Deep Breathing', 'detail': '3 min', 'icon': Icons.air},
        {'name': 'Digital Detox', 'detail': 'No phone 1 hr', 'icon': Icons.phone_disabled},
      ],
    },
    {
      'title': 'Fitness',
      'habits': [
        {'name': 'Morning Run', 'detail': '20 min', 'icon': Icons.directions_run},
        {'name': 'Gym Workout', 'detail': '45 min', 'icon': Icons.fitness_center},
        {'name': 'Stretching', 'detail': '10 min', 'icon': Icons.accessibility_new},
        {'name': 'Pushups', 'detail': '3 sets', 'icon': Icons.sports_gymnastics},
      ],
    },
    {
      'title': 'Productivity',
      'habits': [
        {'name': 'Read Book', 'detail': '20 min', 'icon': Icons.menu_book},
        {'name': 'Deep Work', 'detail': '60 min', 'icon': Icons.work},
        {'name': 'No Social Media', 'detail': '2 hr', 'icon': Icons.phone_disabled},
        {'name': 'Plan Tomorrow', 'detail': '5 min', 'icon': Icons.checklist},
      ],
    },
    {
      'title': 'Health',
      'habits': [
        {'name': 'Drink Water', 'detail': '8 glasses', 'icon': Icons.water_drop},
        {'name': 'Sleep Early', 'detail': 'Before 11 PM', 'icon': Icons.bedtime},
        {'name': 'Cold Shower', 'detail': '1 min', 'icon': Icons.shower},
        {'name': 'Walk 5k Steps', 'detail': 'Daily', 'icon': Icons.directions_walk},
      ],
    },
  ];

  void _showAdded(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name added!')),
    );
  }

  // 🔥 ADD HABIT DIALOG WITH ICON PICKER
  void _showAddHabitDialog(BuildContext context) {
    final titleController = TextEditingController();
    final detailController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.darkCard,
              title: const Text("Add Habit", style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  children: [

                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(hintText: "Habit Name"),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: detailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(hintText: "Details"),
                    ),

                    const SizedBox(height: 20),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Choose Icon",
                          style: TextStyle(color: Colors.white)),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      children: _iconOptions.map((icon) {
                        final isSelected = _selectedIcon == icon;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIcon = icon;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty) return;

                    Provider.of<HabitProvider>(context, listen: false)
                        .addHabit(
                      Habit(
                        id: DateTime.now().toString(),
                        title: titleController.text,
                        category: "Custom",
                        sub: detailController.text,
                        icon: _selectedIcon,
                        color: AppColors.primary,
                        containerColor: AppColors.primaryLight,
                        catColor: AppColors.primaryLight,
                        catTextColor: Colors.black,
                      ),
                    );

                    Navigator.pop(context);
                    _showAdded(titleController.text);
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showAddHabitDialog(context);
        },
        child: const Icon(Icons.add),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [

              const SizedBox(height: 12),

              Text(
                "Discover Habits",
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 24),

              ..._categories.map((cat) => _buildCategory(cat)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(Map<String, dynamic> category) {
    final habits = category['habits'] as List<Map<String, dynamic>>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category['title'],
            style: Theme.of(context).textTheme.titleLarge),

        const SizedBox(height: 12),

        ...habits.map((h) {
          return InkWell(
            onTap: () {
              HapticFeedback.lightImpact();

              Provider.of<HabitProvider>(context, listen: false)
                  .addHabit(
                Habit(
                  id: DateTime.now().toString(),
                  title: h['name'],
                  category: category['title'],
                  sub: h['detail'],
                  icon: h['icon'],
                  color: AppColors.primary,
                  containerColor: AppColors.primaryLight,
                  catColor: AppColors.primaryLight,
                  catTextColor: Colors.black,
                ),
              );

              _showAdded(h['name']);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [

                  Icon(h['icon'], color: AppColors.primary),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(h['name'],
                            style: const TextStyle(color: Colors.white)),
                        Text(h['detail'],
                            style: TextStyle(
                                color: AppColors.textSecondaryDark,
                                fontSize: 12)),
                      ],
                    ),
                  ),

                  const Icon(Icons.add, color: Colors.white),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 20),
      ],
    );
  }
}