import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/app.dart';
import 'features/profile/data/models/user_profile_model.dart';
import 'features/word_lists/data/models/word_list_model.dart';
import 'shared/data/hive_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(WordListModelAdapter());
  Hive.registerAdapter(UserProfileModelAdapter());

  await Future.wait([
    Hive.openBox<WordListModel>(HiveBoxes.wordLists),
    Hive.openBox<UserProfileModel>(HiveBoxes.userProfile),
  ]);

  runApp(const ProviderScope(child: SpellKitApp()));
}
