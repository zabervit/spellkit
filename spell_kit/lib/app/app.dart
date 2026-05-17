import 'package:flutter/material.dart';
import '../shared/presentation/theme/app_theme.dart';
import 'router.dart';

class SpellKitApp extends StatelessWidget {
  const SpellKitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SpellKit',
      theme: AppTheme.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
