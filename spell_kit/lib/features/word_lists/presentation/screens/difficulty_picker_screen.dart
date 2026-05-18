import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../shared/data/hive_config.dart';
import '../../../../shared/domain/value_objects/difficulty.dart';
import '../../../../shared/presentation/theme/app_colors.dart';
import '../../domain/entities/word_list.dart';
import '../../../practice/presentation/providers/practice_providers.dart';

class DifficultyPickerScreen extends StatefulWidget {
  const DifficultyPickerScreen({super.key, required this.wordList});

  final WordList wordList;

  @override
  State<DifficultyPickerScreen> createState() => _DifficultyPickerScreenState();
}

class _DifficultyPickerScreenState extends State<DifficultyPickerScreen> {
  late Difficulty _selected;

  static const _descriptions = {
    Difficulty.starter: 'All the letters are there — just put them in order!',
    Difficulty.explorer: '2 sneaky extra letters are hiding in the mix',
    Difficulty.challenger: 'Lots of sneaky extra letters to ignore!',
    Difficulty.master: 'Type the word from memory — length hint shown',
    Difficulty.expert: 'No hints at all — pure dictation!',
  };

  static const _cardColors = [
    AppColors.mint,
    AppColors.yellow,
    AppColors.coral,
    AppColors.electricBlue,
    Color(0xFF7B2FBE),
  ];

  @override
  void initState() {
    super.initState();
    final saved =
        Hive.box<dynamic>(HiveBoxes.settings).get('lastDifficulty', defaultValue: 1) as int;
    _selected = Difficulty.fromLevel(saved);
  }

  Future<void> _start(Difficulty difficulty) async {
    setState(() => _selected = difficulty);
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    Hive.box<dynamic>(HiveBoxes.settings).put('lastDifficulty', difficulty.level);
    context.push(
      '/practice',
      extra: PracticeArgs(widget.wordList.id, widget.wordList.words, difficulty),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.wordList.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            'Choose your level',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...Difficulty.values.map((d) {
            final isSelected = d == _selected;
            final color = _cardColors[d.level - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color,
                    width: isSelected ? 2.5 : 1.5,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _start(d),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d.name[0].toUpperCase() + d.name.substring(1),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.onSurface,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _descriptions[d]!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: isSelected
                                          ? Colors.white70
                                          : AppColors.muted,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : color.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '×${d.multiplier % 1 == 0 ? d.multiplier.toInt() : d.multiplier}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
