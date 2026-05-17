import 'package:flutter/material.dart';
import '../../domain/entities/word_list.dart';

class WordListCard extends StatelessWidget {
  const WordListCard({super.key, required this.list});

  final WordList list;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(list.name),
        subtitle: Text('${list.words.length} words'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
