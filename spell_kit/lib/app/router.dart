import 'package:go_router/go_router.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/practice/presentation/providers/practice_providers.dart';
import '../features/practice/presentation/screens/practice_screen.dart';
import '../features/practice/presentation/screens/session_summary_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/word_lists/domain/entities/word_list.dart';
import '../features/word_lists/presentation/screens/add_word_list_screen.dart';
import '../features/word_lists/presentation/screens/difficulty_picker_screen.dart';
import '../features/word_lists/presentation/screens/word_lists_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/lists',
      builder: (context, state) => const WordListsScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddWordListScreen(),
        ),
        GoRoute(
          path: 'difficulty',
          builder: (context, state) => DifficultyPickerScreen(
            wordList: state.extra as WordList,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/practice',
      builder: (context, state) {
        final args = state.extra as PracticeArgs;
        return PracticeScreen(
          listId: args.listId,
          words: args.words,
          difficulty: args.difficulty,
        );
      },
    ),
    GoRoute(
      path: '/summary',
      builder: (context, state) => SessionSummaryScreen(
        args: state.extra as SummaryArgs,
      ),
    ),
  ],
);
