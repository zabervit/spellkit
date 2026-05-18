import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wordController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty && _words.length >= 3;

  String _capitalise(String raw) =>
      raw.isEmpty ? raw : raw[0].toUpperCase() + raw.substring(1).toLowerCase();

  void _addWord() {
    final raw = _wordController.text.trim();
    if (raw.isEmpty) return;
    final word = _capitalise(raw);
    if (_words.any((w) => w.toLowerCase() == word.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$word" is already in the list'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _words.add(word);
    _listKey.currentState?.insertItem(_words.length - 1);
    _wordController.clear();
    setState(() {});
  }

  void _removeWord(int index) {
    final word = _words[index];
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildTile(word, animation),
      duration: const Duration(milliseconds: 200),
    );
    setState(() => _words.removeAt(index));
  }

  Widget _buildTile(String word, Animation<double> animation) {
    final slide = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: animation,
        child: ListTile(
          leading: const Icon(Icons.check_circle_outline),
          title: Text(word),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _removeWord(_words.indexOf(word)),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_canSave) return;
    await ref
        .read(wordListsProvider.notifier)
        .add(_nameController.text.trim(), _words);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = 3 - _words.length;
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
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _wordController,
                    decoration: InputDecoration(
                      labelText: 'Add word',
                      hintText: remaining > 0
                          ? '$remaining more to unlock Save'
                          : null,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _addWord(),
                  ),
                ),
                IconButton(
                  onPressed: _addWord,
                  icon: const Icon(Icons.add_circle),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedList(
                key: _listKey,
                initialItemCount: 0,
                itemBuilder: (context, index, animation) =>
                    _buildTile(_words[index], animation),
              ),
            ),
            ElevatedButton(
              onPressed: _canSave ? _save : null,
              child: Text(
                _canSave
                    ? 'Save'
                    : 'Add $remaining more word${remaining == 1 ? '' : 's'}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
