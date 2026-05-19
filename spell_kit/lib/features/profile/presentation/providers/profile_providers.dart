import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/hive_user_profile_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../../domain/use_cases/apply_xp.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>(
  (_) => HiveUserProfileRepository(),
);

final applyXpProvider = Provider(
  (ref) => ApplyXp(ref.read(userProfileRepositoryProvider)),
);

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, UserProfile>(ProfileNotifier.new);

class ProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    final repo = ref.read(userProfileRepositoryProvider);
    final profile = await repo.get();

    // Reset todayWordCount if the last practice was before today.
    if (profile.todayWordCount > 0 && profile.lastPracticeDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastDay = DateTime(
        profile.lastPracticeDate!.year,
        profile.lastPracticeDate!.month,
        profile.lastPracticeDate!.day,
      );
      if (lastDay != today) {
        final reset = profile.copyWith(todayWordCount: 0);
        await repo.save(reset);
        return reset;
      }
    }
    return profile;
  }

  Future<bool> applySessionXp(int xpGained, int wordCount) async {
    final result =
        await ref.read(applyXpProvider).call(xpGained, wordCount);
    state = AsyncData(result.profile);
    return result.leveledUp;
  }
}
