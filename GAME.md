# SpellKit — Game Design Document

## Concept

A spelling dictation trainer for kids aged 6–10. Kids upload their own word lists from school, hear each word read aloud via TTS, and practice spelling through two interaction modes: a tile-tap puzzle (easy) or free typing from memory (advanced). Progress is rewarded with XP, levels, streaks, and unlockables. Achievements are shared with classmates via WhatsApp — no backend required.

---

## Target Audience

- Age: 6–10 (primary school)
- Word lists come from school curriculum, entered by the child
- Used independently by the child; parents involved only for WhatsApp class group sharing

---

## Visual & Feel Philosophy

> It should feel like a game, not like school.

| Element | Approach |
|---|---|
| Colors | Vivid saturated palette — electric blue, coral, yellow, mint. No grays. |
| Typography | `Fredoka One` for headings, `Nunito` for body text |
| Mascot | A friendly owl or bee character that reacts — celebrates wins, looks sad on wrong answers, cheers on level-up |
| Buttons | Large, rounded, with a bounce animation on tap |
| Backgrounds | Soft animated gradient or floating stars/clouds |
| Correct answer | Full-screen confetti burst + ding sound + mascot jumps |
| Wrong answer | Input shakes, wrong letters glow red, hint appears |
| Sound effects | Satisfying "ding" on correct, soft "buzz" on wrong, fanfare on level-up |
| Haptics | Light tap feedback on every interaction |

---

## Screens

| Screen | Key Details |
|---|---|
| Home / Dashboard | Mascot greeting, streak flame counter, XP bar, daily goal progress, glowing "Practice!" button |
| My Word Lists | Card grid with per-list colors, word count badge, last practiced date |
| Add / Edit List | Clean input, each added word animates in with a pop |
| Practice Session | Giant TTS speaker button, interaction area changes by difficulty level, mascot reacts in corner |
| Correct Answer | Full-screen confetti + ding + mascot animation |
| Wrong Answer | Shake animation, red letter highlights, hint text below |
| Session Summary | Animated star award (1–3), XP counter ticks up, "Share with class" button |
| Profile | Level badge with glow, streak calendar, avatar, unlocked items gallery |

---

## Practice Flow

```
1. Child picks a word list and selects a difficulty level
2. Word is spoken aloud via TTS (child can replay as many times as needed)
3. Child interacts based on level:
   - Levels 1–3 (tile mode): tap letter tiles into correct order
   - Level 4–5 (type mode): type the spelling from memory
4. Result:
   ✅ Correct → confetti + XP + next word
   ❌ Wrong   → visual feedback + hint → retry (up to 3 attempts, then word revealed)
5. After all words → Session Summary
```

---

## Difficulty Ladder

Five progressive levels chosen before each session. Higher levels award more XP.

| Level | Name | What the child sees | Interaction | XP Multiplier |
|---|---|---|---|---|
| 1 | Starter | Exact scrambled letters only | Tap tiles to arrange in order | ×1 |
| 2 | Explorer | Scrambled letters + 2 decoy letters | Tap tiles, ignore wrong ones | ×1.5 |
| 3 | Challenger | Scrambled letters + 4–5 decoy letters | Harder tile puzzle | ×2 |
| 4 | Master | Blank input, word length shown as empty slots | Type from scratch | ×2.5 |
| 5 | Expert | Completely blank screen, no hints | Pure dictation typing | ×3 |

### Tile Mode UI (Levels 1–3)

```
┌──────────────────────────────────┐
│   🔊  "ELEPHANT"                 │
│                                  │
│  [ _ ] [ _ ] [ _ ] [ _ ]        │  ← answer slots (word length)
│  [ _ ] [ _ ] [ _ ] [ _ ]        │
│                                  │
│  [E] [L] [P] [H] [X] [A] [N]   │  ← tile pool
│  [T] [E] [K] [B]                │  ← decoys shown in muted style
└──────────────────────────────────┘
```

- Correct letter tiles: bright, colorful
- Decoy tiles: slightly muted/grey — visually different but not labeled
- Tap a placed tile to return it to the pool
- All slots filled correctly → instant confetti burst

### Type Mode UI (Levels 4–5)

```
Level 4:  [ _ ] [ _ ] [ _ ] [ _ ] [ _ ] [ _ ] [ _ ] [ _ ]  (length hint)
Level 5:  [                                               ]  (blank input)
```

---

## Hint System

### Phase 1 (no AI)

On a wrong answer, the app shows:
1. The correct word with the wrong letters highlighted in red
2. A simple spelling rule if detectable (e.g. "I before E", "double consonant before -ing", "silent E")
3. Up to 3 retry attempts before the correct word is fully revealed

### Phase 3 (AI-powered)

Wrong answers are sent to the Claude API with the word and the child's attempt. The API returns a short, kid-friendly explanation of the mistake and the rule behind it. Falls back to Phase 1 hints when offline.

---

## Gamification System

### XP & Levels

| Attempt | XP awarded |
|---|---|
| Correct on first try | +10 |
| Correct on second try | +5 |
| Correct on third try | +2 |

XP is multiplied by the difficulty level multiplier (see Difficulty Ladder above).

Level thresholds: 0 → 100 → 250 → 500 → 1000 → … (exponential growth)

Level-up triggers a dedicated full-screen celebration animation.

### Streaks

- A streak increments when the child practices ≥ 5 words in a day
- Shown as a 🔥 flame counter on the home screen
- Missing a day resets the streak to zero

### Daily Goal

- Configurable target word count (default: 10 words/day)
- Progress bar shown on the home screen
- Completing the daily goal triggers a bonus animation

### Stars per Session

| Accuracy | Stars |
|---|---|
| 90%+ | ⭐⭐⭐ |
| 60–89% | ⭐⭐ |
| < 60% | ⭐ |

Stars are displayed on the session summary screen and accumulated on the profile.

### Unlockables

Unlocked by reaching level milestones and accumulating stars:
- Mascot outfits / accessories
- Background themes (space, underwater, jungle, etc.)
- Special confetti effects

---

## Class Sharing (WhatsApp)

No backend or server required. Achievements are shared as an image card via the system share sheet.

### How It Works

1. After a session summary (or from the Profile screen), child taps **"Share with class"**
2. The app renders an achievement card widget off-screen using the `screenshot` package
3. The card is exported as a PNG image
4. The system share sheet opens — child picks their WhatsApp class group
5. The class WhatsApp group acts as a natural leaderboard — zero infrastructure needed

### Achievement Card Design

```
┌─────────────────────────────┐
│  🦉 SpellKit                │
│  🏆 Alex — MASTER level!   │
│                             │
│  📚 32 words this week      │
│  ⭐⭐⭐ 3 stars today        │
│  🔥 7-day streak · Lvl 5   │
│                             │
│  Can you beat me? 😄        │
└─────────────────────────────┘
```

The card includes the difficulty level so kids are motivated to share higher-level achievements.

---

## Data Model (local storage)

```
UserProfile
  xp: int
  level: int
  streak: int
  lastPracticeDate: DateTime
  dailyGoal: int
  unlockedItems: List<String>

WordList
  id: String
  name: String
  words: List<Word>
  createdAt: DateTime
  lastPracticedAt: DateTime

Word
  text: String

PracticeSession
  listId: String
  date: DateTime
  difficulty: int          // 1–5
  results: List<WordResult>
  xpEarned: int
  stars: int               // 1–3

WordResult
  word: String
  attempts: int
  correct: bool
```

---

## Flutter Package List

| Package | Purpose |
|---|---|
| `flutter_tts` | Offline TTS — word playback on Android & iOS |
| `hive` + `hive_flutter` | Local data persistence |
| `riverpod` | State management |
| `lottie` | Mascot animations, confetti, level-up effects |
| `audioplayers` | Sound effects (ding, buzz, fanfare) |
| `screenshot` | Render achievement card as PNG image |
| `share_plus` | System share sheet for WhatsApp sharing |
| `google_fonts` | Fredoka One + Nunito |
| `http` *(Phase 3)* | Claude API calls for AI spelling explanations |

---

## Build Phases

### Phase 1 — Core MVP
- Word list CRUD (child-managed)
- TTS word playback
- Tile-tap mode (Level 1–3) + typing mode (Level 4–5)
- Letter-highlight hints and retry logic
- XP, levels, streak, daily goal
- Static mascot art, sound effects, basic animations
- Session summary screen

### Phase 2 — Polish + Class Sharing
- Lottie-animated mascot reactions
- Full animation pass: confetti, haptics, level-up screen
- Unlockable themes and mascot outfits
- Profile screen with streak calendar and unlocked items
- Achievement card rendering + WhatsApp sharing via `share_plus`

### Phase 3 — AI Explanations + Optional Backend
- Claude API integration for kid-friendly spelling explanations on wrong answers
- Offline fallback to Phase 1 rule-based hints
- Optional: lightweight Supabase backend for real class leaderboard (class join code, no auth)
