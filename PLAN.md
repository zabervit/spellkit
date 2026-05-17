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
