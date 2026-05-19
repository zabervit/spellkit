# SpellKit — Phase 1 Implementation Plan

## Status
Scaffold complete. Architecture, domain logic, and data layer are in place.
App has not been run yet. No practice UI exists.

---

## Step 1 — Boot verification

**Goal:** confirm the app launches without crash on a real Android device.

Tasks:
- Run `flutter run` from `spell_kit/`
- Verify Home screen renders (streak, daily goal bar, Practice button)
- Verify navigation to Word Lists screen works
- Fix any runtime errors before building UI

---

## Step 2 — Word list flow (end to end)

**Goal:** a child can add words and see them in a list. This is the entry point to every practice session.

### 2a — Add Word List screen polish
- Text field auto-capitalises each word on entry
- Each added word animates in (slide + fade)
- Validation: name required, minimum 3 words before Save is enabled
- Duplicate word detection (case-insensitive)

### 2b — Word Lists screen
- Coloured card per list (rotate through `AppColors` palette, stored on `WordList`)
- Word count badge
- Last practiced date shown ("Never" if not yet)
- Swipe-to-delete with confirmation

### 2c — Difficulty picker
- Shown after tapping a word list card, before starting practice
- Five level cards with name, description, and XP multiplier
- Remembers last chosen difficulty per device (saved in Hive)

---

## Step 3 — TTS integration

**Goal:** child taps a speaker button and hears the word.

Tasks:
- Initialise `TtsService` in `main()` and expose via Riverpod provider
- Add `ttsServiceProvider` to `shared/services/`
- In `PracticeScreen`: large speaker `IconButton` calls `tts.speak(currentWord)`
- Replay button (same action) — child can tap as many times as needed
- Slow-speak button (reduce speech rate to 0.3) for harder words

---

## Step 4 — Tile mode UI (Levels 1–3)

**Goal:** core gameplay for younger / beginner children.

### Layout
```
┌─────────────────────────────────┐
│  🔊  [speaker]    1 / 8         │  ← AppBar
│                                 │
│  [ _ ][ _ ][ _ ][ _ ][ _ ]     │  ← answer slots (word length)
│                                 │
│  [E] [L] [P] [H] [A] [N] [T]  │  ← tile pool
│  [X] [K]                        │  ← decoy tiles (muted style)
└─────────────────────────────────┘
```

### Tasks
- `TileModeWidget` — stateful widget, receives `word` + `tilePool` from `BuildTilePool`
- Answer slot row: empty slots shown as rounded rectangles
- Tile pool: `Wrap` of `LetterTile` widgets
  - Correct letter tiles: bright with `AppColors` background
  - Decoy tiles: muted grey — not labelled, just visually distinct
- Tap a tile → moves to next empty slot
- Tap a filled slot → returns tile to pool
- All slots filled → auto-submit (no confirm button needed)
- On correct: confetti overlay + ding sound + advance
- On wrong: slots shake animation + tiles return to pool + attempt count increments
- After 3 wrong attempts: word revealed, marked incorrect, advance

### State wiring
- `PracticeNotifier.submitAnswer()` already handles attempt logic
- `TileModeWidget` calls it when slots are filled
- `BuildTilePool` already generates the correct pool per difficulty

---

## Step 5 — Type mode UI (Levels 4–5)

**Goal:** free-typing practice for advanced children.

### Layout
```
Level 4:  [ _ ][ _ ][ _ ][ _ ][ _ ][ _ ]  ← length hint slots (no letters)
Level 5:  [                             ]  ← single blank text field
```

### Tasks
- `TypeModeWidget` — keyboard-driven input
- Level 4: render `word.length` empty slot boxes; fill as user types
- Level 5: plain `TextField` with custom styling
- Submit button activates when input length > 0
- On wrong: input shakes, field clears, hint text appears below
- Hint text comes from `PracticeNotifier.getHint(attempt)`

---

## Step 6 — Session summary screen

**Goal:** satisfying end-of-session feedback screen.

Tasks:
- Animated star award: 1–3 stars pop in one by one (scale animation)
- XP counter ticks up from 0 to `session.xpEarned`
- Words practiced list: ✅ correct / ❌ wrong per word
- "Play again" (same list + difficulty) and "Done" buttons
- Call `ProfileNotifier.applySessionXp()` on entry to update XP + streak
- Level-up detection: if `leveledUp == true`, show full-screen level-up overlay before summary

---

## Step 7 — Profile & streak wiring

**Goal:** XP, level, streak, and daily goal all update correctly after each session.

Tasks:
- `ApplyXp` use case already handles streak logic — verify edge cases:
  - First practice of the day: streak increments
  - Already practiced today: streak stays, `todayWordCount` adds up
  - Missed a day: streak resets to 1
- Reset `todayWordCount` to 0 at midnight (check on app launch, compare date)
- Home screen XP bar animates on return from session
- Daily goal bar fills and shows completion animation when reached

---

## Step 8 — Sound effects & haptics

**Goal:** every interaction has audio + tactile feedback.

Tasks:
- Add sound assets to `spell_kit/assets/sounds/`:
  - `correct.mp3` — short ding
  - `wrong.mp3` — soft buzz
  - `level_up.mp3` — fanfare
- Register assets in `pubspec.yaml`
- Wire `AudioService.play()` calls at correct moments:
  - Correct answer → `SoundEffect.correct`
  - Wrong answer → `SoundEffect.wrong`
  - Level up → `SoundEffect.levelUp`
- Add `HapticFeedback.lightImpact()` on every tile tap
- Add `HapticFeedback.mediumImpact()` on correct answer

---

## Milestone: Phase 1 Done

A child can:
1. Create a word list from their school homework
2. Pick a difficulty level
3. Hear each word read aloud
4. Spell it using tiles (easy) or typing (hard)
5. Get immediate feedback with sound + animation
6. See their stars and XP at the end
7. See their streak and daily goal on the home screen

---

## Out of scope for Phase 1

- Mascot animations (Lottie) — Phase 2
- Unlockables / themes — Phase 2
- WhatsApp sharing — Phase 2
- Claude API hints — Phase 3
- Supabase leaderboard — Phase 3

---

---

# SpellKit — Phase 2 Implementation Plan

## Goal

Increase the learning rate by making the app feel competitive and personal across classmates — through identity, social sharing, mastery tracking, and visual rewards.

## Status

Phase 1 complete. Phase 2 not started.

---

## Step 1 — Identity & Onboarding

**Goal:** every child has a name and avatar used throughout the app and on shared cards.

### 1a — Data model

Add to `UserProfile` entity and `UserProfileModel` Hive adapter:
- `name: String` — empty string until setup is complete
- `avatarPreset: int` — index 0–11 into the preset animal list
- `avatarPhotoPath: String?` — local file path if child chose a real photo; `null` otherwise

Bump the Hive type adapter version. Add `image_picker` to `pubspec.yaml`.

### 1b — Setup screen (`/setup`)

Shown automatically on first launch when `profile.name.isEmpty`.

```
┌─────────────────────────────────┐
│    Hi! What's your name?        │
│   ┌───────────────────────┐     │
│   │  Alex                 │     │
│   └───────────────────────┘     │
│                                 │
│    Pick your avatar             │
│   🦁  🐶  🐱  🦊              │
│   🐸  🐧  🦉  🐯              │
│   🦄  🐻  🐨  🦕              │
│                                 │
│   [ 📷 Use my photo instead ]   │
│   ┌───────────────────────┐     │
│   │     Let's go!  →      │     │
│   └───────────────────────┘     │
└─────────────────────────────────┘
```

- "Let's go!" enabled only when name is non-empty
- Selecting a preset deselects the photo (and vice-versa)
- Photo opens `ImagePicker` (camera + gallery choice)
- `isEditing: bool` flag reuses this screen from Profile — button label becomes "Save changes"

### 1c — Router guard

In `router.dart`, add a redirect: if `profile.name.isEmpty`, send to `/setup` before `/`.

### 1d — Home screen greeting

Replace static "SpellKit" title with `"Hi, [name]! 👋"` in the AppBar or as a headline above the streak row.

### 1e — Profile screen identity header

Top of `ProfileScreen`: avatar circle (photo or emoji on coloured background) + name + level badge. Tap the avatar or name to open `/setup?editing=true`.

---

## Step 2 — Word Mastery System

**Goal:** track per-word performance so children focus on words they haven't mastered, directly improving retention.

### Rule

A word is **mastered** when the child answers it correctly on the first attempt in **3 separate sessions**. A wrong answer resets the streak for that word.

### Tasks

- New entity `WordMastery`: `wordText`, `listId`, `firstTryStreak` (0–3), `totalSessions`, `masteredAt: DateTime?`
- New Hive box `wordMastery`; new `WordMasteryRepository` + `HiveWordMasteryRepository`
- `UpdateWordMastery` use case: called after each session with the list of `WordResult`
- `WordListsScreen` card: mastery progress bar under the word count badge (`X / Y mastered`)
- `AddWordListScreen`: mastered words show a ⭐ in the word chip
- Session result: pass mastery summary into `SessionSummaryScreen` — show "⭐ 2 words mastered this session!" if any new mastery achieved

---

## Step 3 — Achievement Badge System

**Goal:** one-time milestone rewards that create surprise moments and visible proof of effort.

### Badge catalogue

| ID | Name | Trigger |
|---|---|---|
| `first_word` | First Word! | Spell any word correctly for the first time |
| `perfect_session` | Flawless | 100% accuracy in a session |
| `streak_5` | On Fire | 5-day streak |
| `streak_10` | Unstoppable | 10-day streak |
| `word_master` | Word Master | 10 words mastered |
| `century` | Century | 100 total words practiced |
| `comeback_kid` | Comeback Kid | Correct after 2 wrong attempts in one word |
| `speed_run` | Speed Speller | All words correct first-try in a session of 5+ words |

### Tasks

- `Badge` value object: `id`, `name`, `description`, `icon (String emoji or IconData)`
- `BadgeCatalogue`: const list of all badge definitions
- `CheckAchievements` use case: takes updated `UserProfile` + session results, returns `List<Badge>` newly earned; stores earned IDs in `profile.unlockedItems`
- Call `CheckAchievements` inside `ProfileNotifier.applySessionXp()`
- `SessionSummaryScreen`: if any new badges earned, show a badge-earned row with pop-in animation after the stars/XP sequence
- `ProfileScreen`: badge gallery grid below the stats — earned badges shown in colour, unearned shown greyed with `?` label

---

## Step 4 — Animated Mascot

**Goal:** emotional engagement — the mascot makes children feel the app responds to them.

### Animations required (source from LottieFiles — free licence)

| State | Trigger |
|---|---|
| `idle` | Default loop on home screen and during practice |
| `correct` | Word answered correctly |
| `wrong` | Wrong answer |
| `level_up` | Level-up overlay |
| `thinking` | TTS playing (optional) |

### Tasks

- Add Lottie JSON files to `assets/animations/`
- Register in `pubspec.yaml`
- `MascotWidget`: `StatefulWidget` wrapping a `LottieBuilder`; exposes a `play(MascotState)` method via a `GlobalKey` or controller
- `MascotState` enum: `idle, correct, wrong, levelUp, thinking`
- Practice screen: small `MascotWidget` anchored bottom-right, driven by `PracticeNotifier` state changes
- Home screen: larger `MascotWidget` playing `idle` with greeting text "Hi, [name]!" above it
- After correct: play `correct` once, then return to `idle`

---

## Step 5 — Unlockable Themes & Cosmetics

**Goal:** visual rewards that give children something tangible to work toward.

### Themes

| ID | Name | Unlock at level | Background | Accent |
|---|---|---|---|---|
| `default` | Default | — | White | Electric blue |
| `space` | Space | 3 | Deep purple | Star gold |
| `ocean` | Ocean | 5 | Deep teal | Coral |
| `jungle` | Jungle | 8 | Forest green | Lime |
| `sunset` | Sunset | 10 | Burnt orange | Pink |

### Mascot accessories (overlay images or Lottie layer)

Unlocked at level 4, 6, 9, 12: graduation cap, sunglasses, superhero cape, golden crown.

### Tasks

- `AppThemeData` value object: `id`, `name`, `backgroundColor`, `tileColor`, `accentColor`, `unlockLevel`
- `ThemeCatalogue`: const list
- `activeThemeProvider`: reads `profile.activeTheme`, returns matching `AppThemeData`
- Practice screen and home screen consume `activeThemeProvider` for background colour
- `UnlockNewItems` use case: called from `applySessionXp` — returns newly unlocked theme/accessory IDs, adds to `profile.unlockedItems`
- If items newly unlocked: show "New unlock! 🎉" card in `SessionSummaryScreen` between XP counter and word list
- `ProfileScreen` unlockables gallery: themed card per theme + accessory row; active item has a checkmark; tapping sets as active

---

## Step 6 — Class Sharing (WhatsApp)

**Goal:** the class WhatsApp group becomes an organic leaderboard that motivates practice without any backend.

### Card types

**Brag card** (from Profile or session summary):
```
┌─────────────────────────────┐
│  🦉  SpellKit               │
│  [avatar]  Alex             │
│  🏆 Level 5 — Master!       │
│                             │
│  📚 32 words this week      │
│  ⭐⭐⭐ 3 stars today        │
│  🔥 7-day streak            │
│                             │
│  Can you beat me? 😄        │
└─────────────────────────────┘
```

**Challenge card** (from session summary, includes list + difficulty):
```
┌─────────────────────────────┐
│  🦉  SpellKit Challenge     │
│  [avatar]  Alex             │
│                             │
│  ⭐⭐⭐ on "Animals" list    │
│  at Master difficulty       │
│                             │
│  Think you can beat it? 🎯  │
└─────────────────────────────┘
```

### Tasks

- `AchievementCardWidget`: off-screen rendered widget (inside `RepaintBoundary`)
- `ScreenshotService.capture(key)`: returns `Uint8List` PNG
- `ShareService.shareImage(bytes, text)`: calls `share_plus`
- Session summary: "Share with class 📤" button → renders brag card + challenge card choice dialog → shares
- Profile screen: "Share my stats" button → brag card only
- Avatar in card: `CircleAvatar` showing photo or emoji preset on coloured background

---

## Step 7 — Daily Challenge Word

**Goal:** give every child a reason to open the app each day and a shared talking point with classmates.

### Rule

One word is picked randomly from the child's word lists each day (seeded by date so it stays consistent if they open the app multiple times). Worth **2× XP** if spelled correctly on the first attempt.

### Tasks

- `DailyChallenge` entity: `wordText`, `listId`, `date`, `completed: bool`, `xpBonus: int`
- Stored in the Hive `settings` box (keyed by date string)
- `PickDailyChallenge` use case: picks a random word from available lists for today's date; returns `null` if no lists exist
- Home screen: gold "Today's challenge" card below the daily goal bar — shows word list name, "Tap to practice"; hidden if no lists or already completed
- Practice session: when the current word matches today's challenge word, show a small gold 👑 crown badge next to the word counter in the AppBar
- On correct first-try: award 2× XP, mark `DailyChallenge.completed = true`, show "Challenge complete! 👑 +[xp] XP" in the correct-answer overlay instead of the normal card

---

## New packages required for Phase 2

| Package | Step | Purpose |
|---|---|---|
| `image_picker` | Step 1 | Camera + gallery photo for avatar |

All other packages (`lottie`, `screenshot`, `share_plus`) are already in `pubspec.yaml`.

---

## Milestone: Phase 2 Done

A child can:
1. Set up their name and avatar on first launch, edit it any time
2. See which words they have mastered and which still need practice
3. Earn achievement badges for effort and consistency
4. Watch their mascot react to every answer
5. Unlock new themes and accessories as they level up
6. Share a personalised achievement card to their class WhatsApp group
7. Accept a daily challenge word and compare results with classmates
