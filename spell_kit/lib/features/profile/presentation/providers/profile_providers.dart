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
  Future<UserProfile> build() =>
      ref.read(userProfileRepositoryProvider).get();

  Future<bool> applySessionXp(int xpGained, int wordCount) async {
    final result =
        await ref.read(applyXpProvider).call(xpGained, wordCount);
    state = AsyncData(result.profile);
    return result.leveledUp;
  }
}
