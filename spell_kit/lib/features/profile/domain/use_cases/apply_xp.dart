import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

class ApplyXp {
  const ApplyXp(this._repository);

  final UserProfileRepository _repository;

  static const _levelThresholds = [0, 100, 250, 500, 1000, 2000, 4000, 8000];

  Future<({UserProfile profile, bool leveledUp})> call(
      int xpGained, int wordCount) async {
    final current = await _repository.get();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastDate = current.lastPracticeDate;
    final wasYesterday = lastDate != null &&
        DateTime(lastDate.year, lastDate.month, lastDate.day)
            .difference(today)
            .inDays ==
            -1;

    final newStreak = wasYesterday ? current.streak + 1 : 1;
    final newXp = current.xp + xpGained;
    final newLevel = _levelThresholds.lastIndexWhere((t) => newXp >= t) + 1;
    final leveledUp = newLevel > current.level;

    final updated = current.copyWith(
      xp: newXp,
      level: newLevel,
      streak: newStreak,
      lastPracticeDate: now,
      todayWordCount: current.todayWordCount + wordCount,
    );
    await _repository.save(updated);
    return (profile: updated, leveledUp: leveledUp);
  }
}
