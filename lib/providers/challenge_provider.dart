import 'package:flutter/material.dart';
import '../models/challenge_model.dart';

class ChallengeProvider with ChangeNotifier {
  final List<Challenge> _challenges = [
    Challenge(
      title: '30-Day Early Bird Challenge',
      participants: '1.2k',
      days: 30,
      progress: 14,
      joined: false,
    ),
    Challenge(
      title: 'Peak Vitality Sprint',
      participants: '834',
      days: 21,
      progress: 7,
      joined: true,
    ),
  ];

  List<Challenge> get challenges => _challenges;

  // ✅ Join Challenge
  void joinChallenge(int index) {
    if (index < 0 || index >= _challenges.length) return;

    final challenge = _challenges[index];

    if (!challenge.joined) {
      challenge.join();
      notifyListeners();
    }
  }

  // ✅ Update Progress
  void updateProgress(int index) {
    if (index < 0 || index >= _challenges.length) return;

    final challenge = _challenges[index];

    if (challenge.joined) {
      challenge.updateProgress();
      notifyListeners();
    }
  }

  // ✅ Smart Action (Join OR Progress)
  void handleChallengeAction(int index) {
    if (index < 0 || index >= _challenges.length) return;

    final challenge = _challenges[index];

    if (!challenge.joined) {
      challenge.join();
    } else {
      challenge.updateProgress();
    }

    notifyListeners();
  }
}