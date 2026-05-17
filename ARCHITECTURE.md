# SpellKit — Architecture

## Foundational Decisions

| Concern | Decision |
|---|---|
| Structure | Feature-first |
| Data access | Repository pattern (abstract interface + Hive implementation) |
| Navigation | `go_router` |
| State | `Notifier` (synchronous) + `AsyncNotifier` (async data loading) |
| Domain model | Pure Dart entities, separate from Hive DTOs |
| Testing | Unit tests (domain logic) + Widget tests (key screens) |

---

## Folder Structure

```
lib/
  app/
    app.dart           # MaterialApp + ProviderScope setup
    router.dart        # GoRouter route definitions

  features/
    word_lists/
      data/
        models/        # WordListModel (@HiveType)
        repositories/  # HiveWordListRepository implements WordListRepository
      domain/
        entities/      # WordList (pure Dart)
        repositories/  # WordListRepository (abstract interface)
        use_cases/     # AddWordList, DeleteWordList, GetAllWordLists
      presentation/
        providers/     # WordListsNotifier (AsyncNotifier)
        screens/       # WordListsScreen, AddWordListScreen
        widgets/       # WordListCard, WordInputField

    practice/
      data/
        models/        # PracticeSessionModel (@HiveType)
        repositories/  # HivePracticeSessionRepository
      domain/
        entities/      # PracticeSession, PracticeState, WordResult
        repositories/  # PracticeSessionRepository (abstract)
        use_cases/     # CalculateXP, CalculateStars, BuildTilePool
        services/      # HintService (Phase 1: rule-based; Phase 3: Claude API)
      presentation/
        providers/     # PracticeNotifier (Notifier<PracticeState>)
        screens/       # PracticeScreen, SessionSummaryScreen
        widgets/       # TileModeWidget, TypeModeWidget, MascotWidget

    profile/
      data/
        models/        # UserProfileModel (@HiveType)
        repositories/  # HiveUserProfileRepository
      domain/
        entities/      # UserProfile, Unlockable
        repositories/  # UserProfileRepository (abstract)
        use_cases/     # ApplyXP, UpdateStreak, UnlockItem
      presentation/
        providers/     # ProfileNotifier (AsyncNotifier)
        screens/       # ProfileScreen
        widgets/       # LevelBadge, StreakCalendar, UnlockablesGallery

    home/
      presentation/
        screens/       # HomeScreen
        widgets/       # DailyGoalBar, StreakFlame

  shared/
    data/
      hive_config.dart  # registerAdapters(), box keys as constants
    domain/
      value_objects/    # Difficulty enum (with .multiplier, .name)
    presentation/
      theme/            # AppTheme, AppColors, AppTextStyles
      widgets/          # BounceButton, ConfettiOverlay
    services/
      tts_service.dart
      audio_service.dart
      screenshot_service.dart
      share_service.dart

  main.dart
```

---

## Key Design Patterns

### Repository — abstract interface in domain, Hive implementation in data

```dart
// features/word_lists/domain/repositories/word_list_repository.dart
abstract class WordListRepository {
  Future<List<WordList>> getAll();
  Future<void> save(WordList list);
  Future<void> delete(String id);
}

// features/word_lists/data/repositories/hive_word_list_repository.dart
class HiveWordListRepository implements WordListRepository { ... }
```

### Notifier — depends only on domain, injected via Riverpod

```dart
// features/word_lists/presentation/providers/word_lists_notifier.dart
@riverpod
class WordListsNotifier extends AsyncNotifier<List<WordList>> {
  Future<List<WordList>> build() =>
      ref.read(wordListRepositoryProvider).getAll();

  Future<void> add(WordList list) async {
    await ref.read(wordListRepositoryProvider).save(list);
    ref.invalidateSelf();
  }
}
```

### HintService — seam for Phase 3 swap

```dart
// features/practice/domain/services/hint_service.dart
abstract class HintService {
  Future<String> explain(String word, String attempt);
}
// Phase 1: RuleBasedHintService (pattern matching, no network)
// Phase 3: ClaudeHintService (Claude API, falls back to RuleBasedHintService offline)
```

### Difficulty — typed value object shared across features

```dart
// shared/domain/value_objects/difficulty.dart
enum Difficulty {
  starter(1, 1.0),
  explorer(2, 1.5),
  challenger(3, 2.0),
  master(4, 2.5),
  expert(5, 3.0);

  const Difficulty(this.level, this.multiplier);
  final int level;
  final double multiplier;
}
```

---

## Phase 3 Extensibility

- **Supabase leaderboard**: add `SupabaseWordListRepository` implementing `WordListRepository` — no changes to domain or UI.
- **Claude API hints**: add `ClaudeHintService` implementing `HintService`, swap at the provider level with offline fallback to `RuleBasedHintService`.
- **iOS**: no structural changes — Flutter and go_router handle cross-platform routing.
