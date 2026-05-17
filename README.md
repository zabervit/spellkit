# SpellKit — Kids Spelling Trainer

A cross-platform mobile app (Android first, iOS later) that helps kids aged 6–10 practice spelling words from their school curriculum. Kids hear words read aloud via TTS, then either arrange scrambled letter tiles or type the word from memory, earning XP, streaks, and unlockable rewards along the way.

See [GAME.md](GAME.md) for the full game design document.

## Tech Stack

- **Framework**: Flutter (Dart) — single codebase for Android & iOS
- **TTS**: `flutter_tts` — offline, wraps Android TextToSpeech + iOS AVSpeechSynthesizer
- **Storage**: `hive` — local, no backend required
- **State**: `riverpod`
- **Sharing**: `screenshot` + `share_plus` — WhatsApp achievement cards

## Setup

1. Install Flutter: [https://docs.flutter.dev/install/manual](https://docs.flutter.dev/install/manual)
2. Verify: `flutter doctor`
3. Create project: `flutter create spell_kit` (inside `Learning/SpellKit/`)
4. Add dependencies to `pubspec.yaml` — see GAME.md for full package list
5. Run on Android emulator or device: `flutter run`
