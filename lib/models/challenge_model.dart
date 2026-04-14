class Challenge {
  final String title;
  final String participants;
  final int days;
  int progress;
  bool joined;

  Challenge({
    required this.title,
    required this.participants,
    required this.days,
    required this.progress,
    required this.joined,
  });

  // ✅ Join challenge
  void join() {
    joined = true;
  }

  // ✅ Update progress (safe)
  void updateProgress() {
    if (progress < days) {
      progress++;
    }
  }

  // ✅ Get progress percentage (useful for UI)
  double get progressPercent {
    return progress / days;
  }

  // ✅ Copy method (future use - very important)
  Challenge copyWith({
    String? title,
    String? participants,
    int? days,
    int? progress,
    bool? joined,
  }) {
    return Challenge(
      title: title ?? this.title,
      participants: participants ?? this.participants,
      days: days ?? this.days,
      progress: progress ?? this.progress,
      joined: joined ?? this.joined,
    );
  }
}