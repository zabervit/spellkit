import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/presentation/providers/profile_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('🔥 ${profile.streak}-day streak',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: profile.dailyGoal > 0
                    ? profile.todayWordCount / profile.dailyGoal
                    : 0,
              ),
              const SizedBox(height: 4),
              Text(
                  '${profile.todayWordCount} / ${profile.dailyGoal} words today'),
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
        ),
      ),
    );
  }
}
