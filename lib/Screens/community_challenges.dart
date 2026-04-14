import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CommunityChallengesScreen extends StatelessWidget {
  const CommunityChallengesScreen({super.key});

  static const List<Map<String, dynamic>> _challenges = [
    {
      'title': '30-Day Early Bird',
      'participants': '1.2k',
      'days': 30,
      'progress': 14,
      'joined': false,
      'icon': Icons.wb_sunny_rounded,
    },
    {
      'title': 'Peak Vitality Sprint',
      'participants': '834',
      'days': 21,
      'progress': 7,
      'joined': true,
      'icon': Icons.bolt_rounded,
    },
  ];

  static const List<Map<String, dynamic>> _friends = [
    {
      'name': 'Maya',
      'habit': 'Meditation',
      'detail': '🔥 14-day streak',
      'emoji': '🧘',
      'time': '5m ago',
    },
    {
      'name': 'Jordan',
      'habit': 'Cold Shower',
      'detail': 'Day 1 done',
      'emoji': '🚿',
      'time': '1h ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              const SizedBox(height: 12),

              Text(
                "Community",
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 24),

              Text(
                "Challenges",
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 12),

              ..._challenges.map((c) => _challengeCard(c)),

              const SizedBox(height: 24),

              Text(
                "Friends Activity",
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 12),

              ..._friends.map((f) => _activityCard(f)),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 FINAL FIXED CARD
  Widget _challengeCard(Map<String, dynamic> c) {
    final progress = (c['progress'] as int) / (c['days'] as int);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(c['icon'], color: AppColors.primary),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  c['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),

              const SizedBox(width: 8),

              // ✅ FIXED (NO OVERFLOW EVER)
              SizedBox(
                width: 40,
                child: Text(
                  "${c['days']}d",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            "${c['participants']} joined",
            style: TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor:
              const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: c['joined']
                    ? AppColors.darkBackground
                    : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                c['joined'] ? "Continue" : "Join",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityCard(Map<String, dynamic> f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                f['emoji'],
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${f['name']} → ${f['habit']}",
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  f['detail'],
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Flexible(
            child: Text(
              f['time'],
              style: TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}