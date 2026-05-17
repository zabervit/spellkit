import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/domain/value_objects/difficulty.dart';
import '../../domain/entities/practice_state.dart';
import '../providers/practice_providers.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({
    super.key,
    required this.listId,
    required this.words,
    required this.difficulty,
  });

  final String listId;
  final List<String> words;
  final Difficulty difficulty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = PracticeArgs(listId, words, difficulty);
    final state = ref.watch(practiceNotifierProvider(args));

    if (state.status == PracticeStatus.sessionComplete) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Session complete!', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${state.currentIndex + 1} / ${state.words.length}',
        ),
      ),
      body: Center(
        child: Text(
          state.currentWord,
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
    );
  }
}
