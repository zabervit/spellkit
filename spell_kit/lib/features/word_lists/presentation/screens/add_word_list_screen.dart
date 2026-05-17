import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/word_lists_providers.dart';

class AddWordListScreen extends ConsumerStatefulWidget {
  const AddWordListScreen({super.key});

  @override
  ConsumerState<AddWordListScreen> createState() => _AddWordListScreenState();
}

class _AddWordListScreenState extends ConsumerState<AddWordListScreen> {
  final _nameController = TextEditingController();
  final _wordController = TextEditingController();
  final _words = <String>[];

  @override
  void dispose() {
    _nameController.dispose();
    _wordController.dispose();
    super.dispose();
  }

  void _addWord() {
    final word = _wordController.text.trim().toLowerCase();
    if (word.isEmpty || _words.contains(word)) return;
    setState(() => _words.add(word));
    _wordController.clear();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _words.isEmpty) return;
    await ref.read(wordListsProvider.notifier).add(name, _words);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Word List')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'List name'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _wordController,
                    decoration: const InputDecoration(labelText: 'Add word'),
                    onSubmitted: (_) => _addWord(),
                  ),
                ),
                IconButton(onPressed: _addWord, icon: const Icon(Icons.add)),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _words.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text(_words[i]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => setState(() => _words.removeAt(i)),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _words.isEmpty ? null : _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
