import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/word_lists_providers.dart';
import '../widgets/word_list_card.dart';

class WordListsScreen extends ConsumerWidget {
  const WordListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(wordListsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Word Lists')),
      body: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (lists) => lists.isEmpty
            ? const Center(child: Text('No word lists yet. Add one!'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lists.length,
                itemBuilder: (context, i) => WordListCard(
                  list: lists[i],
                  onDelete: () =>
                      ref.read(wordListsProvider.notifier).delete(lists[i].id),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/lists/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
