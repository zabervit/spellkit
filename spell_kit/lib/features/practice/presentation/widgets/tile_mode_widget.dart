import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/audio_service.dart';
import '../../domain/entities/practice_state.dart';
import '../providers/practice_providers.dart';
import 'letter_tile.dart';

class _TileData {
  _TileData(this.letter) : isPlaced = false;
  final String letter;
  bool isPlaced;
}

class TileModeWidget extends ConsumerStatefulWidget {
  const TileModeWidget({
    super.key,
    required this.args,
    required this.word,
    required this.tilePool,
  });

  final PracticeArgs args;
  final String word;
  final List<String> tilePool;

  @override
  ConsumerState<TileModeWidget> createState() => _TileModeWidgetState();
}

class _TileModeWidgetState extends ConsumerState<TileModeWidget>
    with SingleTickerProviderStateMixin {
  late List<_TileData> _tiles;
  late List<int?> _slots;

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  bool _submitting = false;
  bool _celebrating = false;
  bool _revealing = false;
  Completer<void>? _tapCompleter;

  @override
  void initState() {
    super.initState();
    _tiles = widget.tilePool.map(_TileData.new).toList();
    _slots = List.filled(widget.word.length, null);

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _tapCompleter?.complete();
    _shakeCtrl.dispose();
    super.dispose();
  }

  bool get _canInteract => !_submitting && !_celebrating && !_revealing;

  void _tapTile(int i) {
    if (!_canInteract) return;
    if (_tiles[i].isPlaced) return;
    final emptySlot = _slots.indexWhere((s) => s == null);
    if (emptySlot == -1) return;
    setState(() {
      _slots[emptySlot] = i;
      _tiles[i].isPlaced = true;
    });
    if (_slots.every((s) => s != null)) _submit();
  }

  void _tapSlot(int j) {
    if (!_canInteract) return;
    if (_slots[j] == null) return;
    setState(() {
      _tiles[_slots[j]!].isPlaced = false;
      _slots[j] = null;
    });
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);

    final answer = _slots.map((i) => _tiles[i!].letter).join();
    final notifier =
        ref.read(practiceNotifierProvider(widget.args).notifier);
    final isCorrect = await notifier.submitAnswer(answer);
    if (!mounted) return;

    final audio = ref.read(audioServiceProvider);
    if (isCorrect) {
      HapticFeedback.mediumImpact();
      audio.play(SoundEffect.correct);
      _tapCompleter = Completer<void>();
      setState(() => _celebrating = true);
      await Future.any([
        Future.delayed(const Duration(milliseconds: 2500)),
        _tapCompleter!.future,
      ]);
      _tapCompleter = null;
      if (!mounted) return;
      setState(() => _celebrating = false);
      notifier.nextWord();
    } else {
      audio.play(SoundEffect.wrong);
      final status = ref.read(practiceNotifierProvider(widget.args)).status;
      if (status == PracticeStatus.wordComplete) {
        // wordComplete — max attempts reached, reveal the word
        setState(() => _revealing = true);
        await Future.delayed(const Duration(milliseconds: 1600));
        if (!mounted) return;
        setState(() => _revealing = false);
        notifier.nextWord();
      } else {
        // wrong but still has retries — shake + reset
        await _shakeCtrl.forward();
        if (!mounted) return;
        _shakeCtrl.reset();
        setState(() {
          for (int j = 0; j < _slots.length; j++) {
            if (_slots[j] != null) _tiles[_slots[j]!].isPlaced = false;
            _slots[j] = null;
          }
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSlots(),
              const SizedBox(height: 36),
              _buildPool(),
            ],
          ),
        ),
        if (_celebrating)
          _CelebrateOverlay(
            word: widget.word,
            onTap: () {
              if (_tapCompleter != null && !_tapCompleter!.isCompleted) {
                _tapCompleter!.complete();
              }
            },
          ),
        if (_revealing) _RevealOverlay(word: widget.word),
      ],
    );
  }

  Widget _buildSlots() {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (context, child) => Transform.translate(
        offset: Offset(_shakeAnim.value, 0),
        child: child,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          for (int j = 0; j < _slots.length; j++)
            _slots[j] == null
                ? EmptySlot(onTap: () => _tapSlot(j))
                : LetterTile(
                    letter: _tiles[_slots[j]!].letter,
                    variant: TileVariant.slot,
                    onTap: () => _tapSlot(j),
                  ),
        ],
      ),
    );
  }

  Widget _buildPool() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        for (int i = 0; i < _tiles.length; i++)
          Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            visible: !_tiles[i].isPlaced,
            child: LetterTile(
              letter: _tiles[i].letter,
              variant: TileVariant.correct,
              onTap: () => _tapTile(i),
            ),
          ),
      ],
    );
  }
}

class _CelebrateOverlay extends StatelessWidget {
  const _CelebrateOverlay({required this.word, required this.onTap});
  final String word;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.black.withValues(alpha: 0.45),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.72, end: 1.0),
              duration: const Duration(milliseconds: 420),
              curve: Curves.elasticOut,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 36),
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF2E7D32),
                        size: 46,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Correct!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      word.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A237E),
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Tap to continue',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RevealOverlay extends StatelessWidget {
  const _RevealOverlay({required this.word});
  final String word;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.black.withValues(alpha: 0.72),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'The word was',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  word.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
