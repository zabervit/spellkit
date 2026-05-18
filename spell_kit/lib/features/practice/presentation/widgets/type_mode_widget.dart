import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/presentation/theme/app_colors.dart';
import '../../domain/entities/practice_state.dart';
import '../providers/practice_providers.dart';
import 'letter_tile.dart';

class TypeModeWidget extends ConsumerStatefulWidget {
  const TypeModeWidget({
    super.key,
    required this.args,
    required this.word,
    required this.lengthHint,
  });

  final PracticeArgs args;
  final String word;

  /// Level 4: show empty slot boxes as a length hint.
  /// Level 5: plain text field, no hint.
  final bool lengthHint;

  @override
  ConsumerState<TypeModeWidget> createState() => _TypeModeWidgetState();
}

class _TypeModeWidgetState extends ConsumerState<TypeModeWidget>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  String _hint = '';
  bool _submitting = false;
  bool _celebrating = false;
  bool _revealing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _focus = FocusNode();

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

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _ctrl.text.trim().isNotEmpty && !_submitting && !_celebrating && !_revealing;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);

    final answer = _ctrl.text.trim();
    final notifier = ref.read(practiceNotifierProvider(widget.args).notifier);
    final isCorrect = await notifier.submitAnswer(answer);
    if (!mounted) return;

    if (isCorrect) {
      setState(() => _celebrating = true);
      await Future.delayed(const Duration(milliseconds: 1100));
      if (!mounted) return;
      setState(() => _celebrating = false);
      notifier.nextWord();
    } else {
      final status = ref.read(practiceNotifierProvider(widget.args)).status;
      if (status == PracticeStatus.wordComplete) {
        // Max attempts — reveal the correct word
        setState(() => _revealing = true);
        await Future.delayed(const Duration(milliseconds: 1600));
        if (!mounted) return;
        setState(() => _revealing = false);
        notifier.nextWord();
      } else {
        // Wrong but can retry — get hint, shake, clear
        final hint = await notifier.getHint(answer);
        if (!mounted) return;
        await _shakeCtrl.forward();
        if (!mounted) return;
        _shakeCtrl.reset();
        _ctrl.clear();
        setState(() {
          _hint = hint;
          _submitting = false;
        });
        _focus.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              if (widget.lengthHint) _buildSlots(),
              const SizedBox(height: 24),
              _buildInput(),
              const SizedBox(height: 16),
              if (_hint.isNotEmpty)
                Text(
                  _hint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.coral,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Check'),
              ),
            ],
          ),
        ),
        if (_celebrating) _CelebrateOverlay(word: widget.word),
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
      child: ListenableBuilder(
        listenable: _ctrl,
        builder: (context, _) {
          final typed = _ctrl.text;
          return Wrap(
            alignment: WrapAlignment.center,
            children: [
              for (int i = 0; i < widget.word.length; i++)
                i < typed.length
                    ? LetterTile(
                        letter: typed[i],
                        variant: TileVariant.slot,
                      )
                    : const EmptySlot(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInput() {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (context, child) => Transform.translate(
        offset: Offset(widget.lengthHint ? 0 : _shakeAnim.value, 0),
        child: child,
      ),
      child: TextField(
        controller: _ctrl,
        focusNode: _focus,
        maxLength: widget.lengthHint ? widget.word.length : null,
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.none,
        style: Theme.of(context).textTheme.headlineMedium,
        decoration: InputDecoration(
          counterText: '',
          hintText: widget.lengthHint ? null : 'Type the word…',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onSubmitted: (_) => _submit(),
        onChanged: (_) => setState(() => _hint = ''),
      ),
    );
  }
}

class _CelebrateOverlay extends StatelessWidget {
  const _CelebrateOverlay({required this.word});
  final String word;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: AppColors.mint.withValues(alpha: 0.85),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('✓', style: TextStyle(fontSize: 72, color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  word.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
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
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white70),
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
