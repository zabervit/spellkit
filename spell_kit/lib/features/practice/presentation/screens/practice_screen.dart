import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/domain/value_objects/difficulty.dart';
import '../../../../shared/services/tts_service.dart';
import '../../domain/entities/practice_session.dart';
import '../../domain/entities/practice_state.dart';
import '../../domain/use_cases/build_tile_pool.dart';
import '../providers/practice_providers.dart';
import '../widgets/tile_mode_widget.dart';
import '../widgets/type_mode_widget.dart';
import 'session_summary_screen.dart';

class PracticeScreen extends ConsumerStatefulWidget {
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
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  late final PracticeArgs _args;
  final _buildTilePool = BuildTilePool();
  bool _navigatedToSummary = false;

  @override
  void initState() {
    super.initState();
    _args = PracticeArgs(widget.listId, widget.words, widget.difficulty);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsServiceProvider).speak(widget.words.first);
    });
  }

  void _goToSummary(PracticeState state) {
    if (_navigatedToSummary) return;
    _navigatedToSummary = true;
    final session = PracticeSession(
      id: const Uuid().v4(),
      listId: widget.listId,
      date: DateTime.now(),
      difficulty: widget.difficulty,
      results: state.results,
    );
    context.go('/summary', extra: SummaryArgs(session, _args));
  }

  Future<void> _confirmQuit(BuildContext context) async {
    final quit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quit session?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Quit'),
          ),
        ],
      ),
    );
    if ((quit ?? false) && context.mounted) context.go('/lists');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceNotifierProvider(_args));
    final tts = ref.read(ttsServiceProvider);

    ref.listen(practiceNotifierProvider(_args), (prev, next) {
      if (next.status == PracticeStatus.sessionComplete) {
        _goToSummary(next);
        return;
      }
      if (prev?.currentIndex != next.currentIndex) {
        tts.speak(next.currentWord);
      }
    });

    // Guard in case build runs before the listener fires
    if (state.status == PracticeStatus.sessionComplete) {
      _goToSummary(state);
      return const Scaffold(body: SizedBox.shrink());
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _confirmQuit(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${state.currentIndex + 1} / ${state.words.length}'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Quit session',
            onPressed: () => _confirmQuit(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.volume_up_rounded),
              tooltip: 'Hear word',
              onPressed: () => tts.speak(state.currentWord),
            ),
            IconButton(
              icon: const Icon(Icons.slow_motion_video),
              tooltip: 'Slow',
              onPressed: () => tts.slowSpeak(state.currentWord),
            ),
          ],
        ),
        body: widget.difficulty.level <= 3
            ? TileModeWidget(
                key: ValueKey(state.currentIndex),
                args: _args,
                word: state.currentWord,
                tilePool: _buildTilePool(state.currentWord, widget.difficulty),
              )
            : TypeModeWidget(
                key: ValueKey(state.currentIndex),
                args: _args,
                word: state.currentWord,
                lengthHint: widget.difficulty.level == 4,
              ),
      ),
    );
  }
}
