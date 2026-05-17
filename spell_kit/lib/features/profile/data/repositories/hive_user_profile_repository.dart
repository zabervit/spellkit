import 'package:hive/hive.dart';
import '../../../../shared/data/hive_config.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../models/user_profile_model.dart';

class HiveUserProfileRepository implements UserProfileRepository {
  static const _key = 'profile';

  Box<UserProfileModel> get _box =>
      Hive.box<UserProfileModel>(HiveBoxes.userProfile);

  @override
  Future<UserProfile> get() async =>
      _box.get(_key)?.toEntity() ?? UserProfile.initial();

  @override
  Future<void> save(UserProfile profile) async =>
      _box.put(_key, UserProfileModel.fromEntity(profile));
}
