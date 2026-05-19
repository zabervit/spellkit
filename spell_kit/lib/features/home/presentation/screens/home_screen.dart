import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _goalBannerCtrl;
  bool _showGoalBanner = false;

  @override
  void initState() {
    super.initState();
    _goalBannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _goalBannerCtrl.dispose();
    super.dispose();
  }

  Future<void> _showGoalComplete() async {
    if (_showGoalBanner) return;
    setState(() => _showGoalBanner = true);
    await _goalBannerCtrl.forward();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await _goalBannerCtrl.reverse();
    if (!mounted) return;
    setState(() => _showGoalBanner = false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<UserProfile>>(profileProvider, (prev, next) {
      final wasReached = prev?.valueOrNull?.dailyGoalReached ?? false;
      final isReached = next.valueOrNull?.dailyGoalReached ?? false;
      if (!wasReached && isReached) _showGoalComplete();
    });

    final profileAsync = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpellKit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Stack(
        children: [
          profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (profile) => _HomeBody(profile: profile),
          ),
          if (_showGoalBanner) _GoalCompleteBanner(controller: _goalBannerCtrl),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final goalProgress = profile.dailyGoal > 0
        ? (profile.todayWordCount / profile.dailyGoal).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '🔥 ${profile.streak}-day streak',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          _SectionLabel(
            label: 'Level ${profile.level}',
            trailing: '${profile.xp} XP',
          ),
          const SizedBox(height: 6),
          _AnimatedBar(value: profile.levelProgress),
          const SizedBox(height: 4),
          Text(
            '${profile.xpToNextLevel} XP to next level',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          _SectionLabel(
            label: 'Daily goal',
            trailing:
                '${profile.todayWordCount} / ${profile.dailyGoal} words',
          ),
          const SizedBox(height: 6),
          _AnimatedBar(
            value: goalProgress,
            color: profile.dailyGoalReached
                ? Colors.green.shade500
                : Theme.of(context).colorScheme.primary,
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => context.push('/lists'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
            ),
            child: Text(
              'Practice!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.trailing});
  final String label;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        Text(trailing, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Progress bar that smoothly animates to a new value whenever it changes.
class _AnimatedBar extends StatelessWidget {
  const _AnimatedBar({required this.value, this.color});
  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      builder: (context, v, _) => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: v,
          minHeight: 10,
          color: color,
        ),
      ),
    );
  }
}

class _GoalCompleteBanner extends StatelessWidget {
  const _GoalCompleteBanner({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: slide,
        child: SafeArea(
          child: Material(
            color: Colors.green.shade600,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Text(
                    'Daily goal reached!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
