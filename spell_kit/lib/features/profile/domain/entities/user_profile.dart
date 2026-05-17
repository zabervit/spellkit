import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.xp,
    required this.level,
    required this.streak,
    required this.lastPracticeDate,
    required this.dailyGoal,
    required this.todayWordCount,
    required this.unlockedItems,
  });

  factory UserProfile.initial() => const UserProfile(
        xp: 0,
        level: 1,
        streak: 0,
        lastPracticeDate: null,
        dailyGoal: 10,
        todayWordCount: 0,
        unlockedItems: [],
      );

  final int xp;
  final int level;
  final int streak;
  final DateTime? lastPracticeDate;
  final int dailyGoal;
  final int todayWordCount;
  final List<String> unlockedItems;

  static const _levelThresholds = [0, 100, 250, 500, 1000, 2000, 4000, 8000];

  int get xpToNextLevel {
    if (level >= _levelThresholds.length) return 999999;
    return _levelThresholds[level] - xp;
  }

  double get levelProgress {
    if (level >= _levelThresholds.length) return 1.0;
    final start = level > 1 ? _levelThresholds[level - 1] : 0;
    final end = _levelThresholds[level];
    return (xp - start) / (end - start);
  }

  bool get dailyGoalReached => todayWordCount >= dailyGoal;

  UserProfile copyWith({
    int? xp,
    int? level,
    int? streak,
    DateTime? lastPracticeDate,
    int? dailyGoal,
    int? todayWordCount,
    List<String>? unlockedItems,
  }) =>
      UserProfile(
        xp: xp ?? this.xp,
        level: level ?? this.level,
        streak: streak ?? this.streak,
        lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
        dailyGoal: dailyGoal ?? this.dailyGoal,
        todayWordCount: todayWordCount ?? this.todayWordCount,
        unlockedItems: unlockedItems ?? this.unlockedItems,
      );

  @override
  List<Object?> get props =>
      [xp, level, streak, lastPracticeDate, dailyGoal, todayWordCount, unlockedItems];
}
