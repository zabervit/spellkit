import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/services/audio_service.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../domain/entities/practice_session.dart';
import '../providers/practice_providers.dart';

/// Passed as route extra to /summary.
class SummaryArgs {
  const SummaryArgs(this.session, this.practiceArgs);
  final PracticeSession session;
  final PracticeArgs practiceArgs;
}

class SessionSummaryScreen extends ConsumerStatefulWidget {
  const SessionSummaryScreen({super.key, required this.args});

  final SummaryArgs args;

  @override
  ConsumerState<SessionSummaryScreen> createState() =>
      _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends ConsumerState<SessionSummaryScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _starCtrlrs;
  late final List<Animation<double>> _starAnims;
  late final AnimationController _xpCtrl;
  late final Animation<double> _xpAnim;
  late final AnimationController _levelUpCtrl;

  bool _showLevelUp = false;

  PracticeSession get _session => widget.args.session;

  @override
  void initState() {
    super.initState();

    _starCtrlrs = List.generate(
      3,
      (_) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 400)),
    );
    _starAnims = _starCtrlrs
        .map((c) => Tween<double>(begin: 0.0, end: 1.0)
            .animate(CurvedAnimation(parent: c, curve: Curves.elasticOut)))
        .toList();

    _xpCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _xpAnim = Tween<double>(begin: 0, end: _session.xpEarned.toDouble())
        .animate(CurvedAnimation(parent: _xpCtrl, curve: Curves.easeOut));

    _levelUpCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _applyAndAnimate();
  }

  Future<void> _applyAndAnimate() async {
    final leveledUp = await ref
        .read(profileProvider.notifier)
        .applySessionXp(_session.xpEarned, _session.wordCount);
    if (!mounted) return;

    if (leveledUp) {
      ref.read(audioServiceProvider).play(SoundEffect.levelUp);
      setState(() => _showLevelUp = true);
      _levelUpCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 2200));
      if (!mounted) return;
      await _levelUpCtrl.reverse();
      if (!mounted) return;
      setState(() => _showLevelUp = false);
    }

    // Stars pop in one by one
    for (int i = 0; i < _session.stars; i++) {
      await Future.delayed(const Duration(milliseconds: 220));
      if (!mounted) return;
      _starCtrlrs[i].forward();
    }

    // XP ticks up
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _xpCtrl.forward();
  }

  @override
  void dispose() {
    for (final c in _starCtrlrs) {
      c.dispose();
    }
    _xpCtrl.dispose();
    _levelUpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Session Complete!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 32),
                  _buildStars(context),
                  const SizedBox(height: 16),
                  _buildXpCounter(context),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),
                  Expanded(child: _buildWordList(context)),
                  const SizedBox(height: 16),
                  _buildButtons(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_showLevelUp) _LevelUpOverlay(controller: _levelUpCtrl),
        ],
      ),
    );
  }

  Widget _buildStars(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final earned = i < _session.stars;
        return ScaleTransition(
          scale: earned ? _starAnims[i] : const AlwaysStoppedAnimation(1.0),
          child: Text(
            '⭐',
            style: TextStyle(
              fontSize: 48,
              color: earned ? null : Colors.grey.withValues(alpha: 0.35),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildXpCounter(BuildContext context) {
    return AnimatedBuilder(
      animation: _xpAnim,
      builder: (context, _) => Text(
        '+${_xpAnim.value.round()} XP',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }

  Widget _buildWordList(BuildContext context) {
    return ListView.separated(
      itemCount: _session.results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final r = _session.results[i];
        return ListTile(
          dense: true,
          leading: Text(r.correct ? '✅' : '❌', style: const TextStyle(fontSize: 20)),
          title: Text(
            r.word,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: Text(
            r.correct
                ? r.attempts == 1
                    ? '1st try'
                    : '${r.attempts} tries'
                : 'missed',
            style: TextStyle(
              color: r.correct
                  ? Colors.green.shade700
                  : Colors.red.shade400,
              fontSize: 13,
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.go('/'),
            child: const Text('Done'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => context.go(
              '/practice',
              extra: widget.args.practiceArgs,
            ),
            child: const Text('Play again'),
          ),
        ),
      ],
    );
  }
}

class _LevelUpOverlay extends StatelessWidget {
  const _LevelUpOverlay({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: FadeTransition(
        opacity: controller,
        child: Container(
          color: const Color(0xFF7B2FBE),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 16),
                Text(
                  'LEVEL UP!',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
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
