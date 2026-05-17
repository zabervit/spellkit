import 'package:hive/hive.dart';
import '../../../../shared/data/hive_config.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel extends HiveObject {
  UserProfileModel({
    required this.xp,
    required this.level,
    required this.streak,
    required this.lastPracticeDate,
    required this.dailyGoal,
    required this.todayWordCount,
    required this.unlockedItems,
  });

  int xp;
  int level;
  int streak;
  DateTime? lastPracticeDate;
  int dailyGoal;
  int todayWordCount;
  List<String> unlockedItems;

  factory UserProfileModel.fromEntity(UserProfile e) => UserProfileModel(
        xp: e.xp,
        level: e.level,
        streak: e.streak,
        lastPracticeDate: e.lastPracticeDate,
        dailyGoal: e.dailyGoal,
        todayWordCount: e.todayWordCount,
        unlockedItems: List<String>.from(e.unlockedItems),
      );

  UserProfile toEntity() => UserProfile(
        xp: xp,
        level: level,
        streak: streak,
        lastPracticeDate: lastPracticeDate,
        dailyGoal: dailyGoal,
        todayWordCount: todayWordCount,
        unlockedItems: List<String>.unmodifiable(unlockedItems),
      );
}

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = HiveTypeIds.userProfileModel;

  @override
  UserProfileModel read(BinaryReader reader) {
    return UserProfileModel(
      xp: reader.readInt(),
      level: reader.readInt(),
      streak: reader.readInt(),
      lastPracticeDate: reader.readBool()
          ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
          : null,
      dailyGoal: reader.readInt(),
      todayWordCount: reader.readInt(),
      unlockedItems: reader.readStringList(),
    );
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer.writeInt(obj.xp);
    writer.writeInt(obj.level);
    writer.writeInt(obj.streak);
    final hasDate = obj.lastPracticeDate != null;
    writer.writeBool(hasDate);
    if (hasDate) writer.writeInt(obj.lastPracticeDate!.millisecondsSinceEpoch);
    writer.writeInt(obj.dailyGoal);
    writer.writeInt(obj.todayWordCount);
    writer.writeStringList(obj.unlockedItems);
  }
}
