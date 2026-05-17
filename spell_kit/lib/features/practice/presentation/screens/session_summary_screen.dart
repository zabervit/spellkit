import 'package:flutter/material.dart';
import '../../domain/entities/practice_session.dart';

class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({super.key, required this.session});

  final PracticeSession session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Summary')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '⭐' * session.stars,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text('+${session.xpEarned} XP',
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
