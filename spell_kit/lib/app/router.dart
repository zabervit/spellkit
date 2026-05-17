import 'package:go_router/go_router.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/word_lists/presentation/screens/word_lists_screen.dart';
import '../features/word_lists/presentation/screens/add_word_list_screen.dart';

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
      ],
    ),
  ],
);
