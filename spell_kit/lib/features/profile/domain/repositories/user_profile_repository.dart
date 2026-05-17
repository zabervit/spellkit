import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile> get();
  Future<void> save(UserProfile profile);
}
