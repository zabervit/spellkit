# SpellKit — Phase 2: Gamification & Social Learning

## Vision

Make the learning process competitive and personal across classmates.
Every child has an identity, tracks their own progress, earns visible rewards,
and can share achievements with their class group — all without a backend.

## Motivational pillars

| Pillar | Mechanism | Features |
|---|---|---|
| **Progress clarity** | Kids practice more when they can see improvement | Word mastery, achievement badges |
| **Social proof** | Kids work harder when classmates can see their effort | WhatsApp sharing, challenge cards |
| **Intrinsic reward** | Visual and emotional rewards make kids want to return | Mascot reactions, themes, daily challenge |

---

## New package

| Package | Purpose |
|---|---|
| `image_picker` | Avatar photo from camera or gallery |

All other packages (`lottie`, `screenshot`, `share_plus`) are already in `pubspec.yaml`.

---

## Step 1 — Identity & Onboarding

**Goal:** every child has a name and avatar used throughout the app and on shared cards.

### Setup screen — first launch only

Shown automatically when `profile.name` is empty.
Reused from the Profile screen in edit mode (`isEditing: true`).

```
┌─────────────────────────────────┐
│                                 │
│     Hi! What's your name?       │
│                                 │
│   ┌───────────────────────┐     │
│   │  Alex                 │     │
│   └───────────────────────┘     │
│                                 │
│     Pick your avatar            │
│                                 │
│    🦁   🐶   🐱   🦊           │
│    🐸   🐧   🦉   🐯           │
│    🦄   🐻   🐨   🦕           │
│                                 │
│   [ 📷  Use my photo instead ]  │
│                                 │
│   ┌───────────────────────┐     │
│   │     Let's go!  →      │     │
│   └───────────────────────┘     │
│   (button enabled once name     │
│    is non-empty)                │
└─────────────────────────────────┘
```

- Selecting a preset clears the photo, and vice-versa
- Photo option opens `ImagePicker` with camera + gallery choice
- In edit mode the button label is "Save changes"

### Data model additions to `UserProfile`

```dart
final String name;             // "" until setup complete
final int avatarPreset;        // 0–11 index into preset list
final String? avatarPhotoPath; // local file path, null if using preset
```

Hive `UserProfileModel` adapter must be versioned for the new fields.

### Tasks

- Add `name`, `avatarPreset`, `avatarPhotoPath` to `UserProfile` + `UserProfileModel`
- Add `image_picker` to `pubspec.yaml`
- Create `SetupScreen` with name input, preset grid, optional photo picker
- Router redirect: `/setup` when `profile.name.isEmpty`, before `/`
- Home screen: replace AppBar title with `"Hi, [name]! 👋"` headline
- Profile screen: avatar circle + name header, tap to open `/setup?editing=true`

---

## Step 2 — Word Mastery System

**Goal:** track per-word performance so children focus on unmastered words,
directly improving retention through lightweight spaced repetition.

### Mastery rule

A word is **mastered** when the child answers it correctly on the first attempt
in **3 separate sessions**. A wrong answer resets the streak for that word.

### Mastery states

| State | Condition | Display |
|---|---|---|
| New | 0 first-try sessions | Grey dot |
| In progress | 1–2 first-try sessions | Half-filled star |
| Mastered | 3 first-try sessions | Gold star ⭐ |

### Tasks

- New entity `WordMastery`: `wordText`, `listId`, `firstTryStreak` (0–3), `totalSessions`, `masteredAt: DateTime?`
- New Hive box `wordMastery`; `WordMasteryRepository` interface + `HiveWordMasteryRepository`
- `UpdateWordMastery` use case: called after each session with the list of `WordResult`
- Word Lists screen: mastery progress bar on each card (`X / Y mastered`)
- Add Word List screen: mastered words show ⭐ in the word chip
- Session summary: "⭐ 2 new words mastered!" line if any mastery achieved this session

---

## Step 3 — Achievement Badge System

**Goal:** one-time milestone rewards that create surprise moments and visible
proof of effort — both solo and shared.

### Badge catalogue

| ID | Name | Icon | Trigger |
|---|---|---|---|
| `first_word` | First Word! | 🌟 | First word spelled correctly ever |
| `perfect_session` | Flawless | 💎 | 100% accuracy in a session |
| `streak_5` | On Fire | 🔥 | 5-day streak |
| `streak_10` | Unstoppable | ⚡ | 10-day streak |
| `word_master` | Word Master | 👑 | 10 words mastered |
| `century` | Century | 💯 | 100 total words practiced |
| `comeback_kid` | Comeback Kid | 💪 | Correct after 2 wrong attempts |
| `speed_run` | Speed Speller | ⚡ | All words first-try in a session of 5+ |

### Tasks

- `Badge` value object: `id`, `name`, `description`, `icon`
- `BadgeCatalogue`: const list of all definitions
- `CheckAchievements` use case: receives updated `UserProfile` + session results,
  returns `List<Badge>` newly earned; stores IDs in `profile.unlockedItems`
- Call `CheckAchievements` inside `ProfileNotifier.applySessionXp()`
- Session summary: if badges earned, show pop-in badge row after the XP sequence
- Profile screen: badge gallery grid — earned in colour, unearned greyed with `?`

---

## Step 4 — Animated Mascot

**Goal:** the mascot gives the app a personality that children bond with,
making it feel alive rather than mechanical.

### Animation states

| State | Trigger | Loop |
|---|---|---|
| `idle` | Default — home screen, between words | Yes |
| `correct` | Word answered correctly | No (returns to idle) |
| `wrong` | Wrong answer | No (returns to idle) |
| `level_up` | Level-up overlay | No |
| `thinking` | TTS speaking | Yes (until TTS stops) |

Source free Lottie JSON files from [LottieFiles.com](https://lottiefiles.com)
(search: owl, bee, animal character — CC0 or free licence).

### Tasks

- Add Lottie JSON files to `assets/animations/`; register in `pubspec.yaml`
- `MascotState` enum: `idle`, `correct`, `wrong`, `levelUp`, `thinking`
- `MascotWidget`: wraps `LottieBuilder`, exposes `play(MascotState)` via controller
- `mascotStateProvider`: Riverpod `StateProvider<MascotState>` driven by practice events
- Practice screen: small `MascotWidget` bottom-right corner
- Home screen: larger `MascotWidget` with `idle` loop + greeting above it
- `PracticeNotifier` state changes drive `mascotStateProvider`

---

## Step 5 — Unlockable Themes & Cosmetics

**Goal:** visual rewards give children something concrete to work toward
and let them personalise their experience.

### Themes

| ID | Name | Unlock level | Background | Accent |
|---|---|---|---|---|
| `default` | Classic | — | White | Electric blue |
| `space` | Space | 3 | Deep purple | Star gold |
| `ocean` | Ocean | 5 | Deep teal | Coral |
| `jungle` | Jungle | 8 | Forest green | Lime |
| `sunset` | Sunset | 10 | Burnt orange | Pink |

### Mascot accessories

Unlocked at levels 4, 6, 9, 12: graduation cap, sunglasses, superhero cape, golden crown.
Rendered as an image overlay on the `MascotWidget`.

### Tasks

- `AppThemeData` value object: `id`, `name`, `backgroundColor`, `tileColor`, `accentColor`, `unlockLevel`
- `ThemeCatalogue`: const list of all themes
- `activeThemeProvider`: reads `profile.activeTheme`, returns matching `AppThemeData`
- Practice screen + home screen consume `activeThemeProvider` for background colour
- `UnlockNewItems` use case: called from `applySessionXp`, returns newly unlocked IDs
- Session summary: "New unlock! 🎉 Space theme" card if something unlocked this session
- Profile screen: unlockables gallery — theme cards + accessory row;
  active item has a checkmark; tap to set as active

---

## Step 6 — Class Sharing (WhatsApp)

**Goal:** the class WhatsApp group becomes an organic leaderboard that
motivates practice with zero backend infrastructure.

### Brag card (from Profile or session summary)

```
┌─────────────────────────────┐
│  🦉  SpellKit               │
│  [avatar]   Alex            │
│  🏆  Level 5 — Master!      │
│                             │
│  📚  32 words this week     │
│  ⭐⭐⭐  3 stars today       │
│  🔥  7-day streak           │
│                             │
│  Can you beat me? 😄        │
└─────────────────────────────┘
```

### Challenge card (from session summary — includes list + difficulty)

```
┌─────────────────────────────┐
│  🦉  SpellKit Challenge     │
│  [avatar]   Alex            │
│                             │
│  ⭐⭐⭐ on "Animals" list   │
│  at  Master  difficulty     │
│                             │
│  Think you can beat it? 🎯  │
└─────────────────────────────┘
```

### Tasks

- `AchievementCardWidget`: off-screen widget inside `RepaintBoundary`
- Avatar in card: `CircleAvatar` — photo if set, otherwise emoji on coloured background
- `ScreenshotService.capture(key)` → `Uint8List` PNG
- `ShareService.shareImage(bytes)` → `share_plus` (opens system share sheet)
- Session summary: "Share with class 📤" button →
  dialog to choose Brag card vs Challenge card → capture → share
- Profile screen: "Share my stats" button → Brag card only

---

## Step 7 — Daily Challenge Word

**Goal:** give every child a reason to open the app each day and a shared
talking point with classmates ("did you get today's challenge?").

### Rule

One word is picked randomly from the child's lists each day (seeded by date
so it stays consistent across multiple app opens). Worth **2× XP** if
answered correctly on the first attempt.

```
Home screen card
┌─────────────────────────────┐
│  👑  Today's Challenge      │
│  "Animals" word list        │
│  Tap to practice  →         │
└─────────────────────────────┘
```

When the challenge word appears in the session:
- Gold 👑 crown badge next to the word counter in the AppBar
- Correct on first try → "Challenge complete! 👑 +[xp] XP" in the success overlay
- Card hidden once completed for the day

### Tasks

- `DailyChallenge` entity: `wordText`, `listId`, `date`, `completed`, `xpBonus`
- Stored in Hive `settings` box keyed by date string `"YYYY-MM-DD"`
- `PickDailyChallenge` use case: deterministic random pick for today's date;
  returns `null` if no word lists exist
- Home screen: gold challenge card between the daily goal bar and Practice button;
  hidden if no lists or already completed
- Practice screen: AppBar shows 👑 when current word matches the daily challenge
- On correct first try: award 2× XP, mark challenge completed,
  show special overlay text in the success card

---

## Milestone: Phase 2 Done

A child can:

1. Set up their name and avatar on first launch, and edit them any time from the Profile screen
2. See which words they have mastered (⭐) and which still need practice
3. Earn achievement badges for effort, streaks, and consistency
4. Watch their mascot react to every correct answer, wrong answer, and level-up
5. Unlock new background themes and mascot accessories as they level up
6. Share a personalised achievement or challenge card to their class WhatsApp group
7. Accept a daily challenge word worth 2× XP and compare results with classmates
