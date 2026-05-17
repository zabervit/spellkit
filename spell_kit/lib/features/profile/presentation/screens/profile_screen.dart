import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Level ${profile.level}',
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: profile.levelProgress),
              const SizedBox(height: 4),
              Text('${profile.xp} XP · ${profile.xpToNextLevel} to next level'),
              const SizedBox(height: 24),
              Text('🔥 ${profile.streak}-day streak',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('📚 ${profile.todayWordCount} / ${profile.dailyGoal} words today'),
            ],
          ),
        ),
      ),
    );
  }
}
