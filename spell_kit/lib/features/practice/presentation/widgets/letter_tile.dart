import 'package:flutter/material.dart';
import '../../../../shared/presentation/theme/app_colors.dart';

enum TileVariant { correct, decoy, slot }

class LetterTile extends StatelessWidget {
  const LetterTile({
    super.key,
    required this.letter,
    this.variant = TileVariant.correct,
    this.onTap,
  });

  final String letter;
  final TileVariant variant;
  final VoidCallback? onTap;

  static const _size = 46.0;

  Color get _bg => switch (variant) {
        TileVariant.correct => AppColors.electricBlue,
        TileVariant.decoy => AppColors.muted,
        TileVariant.slot => AppColors.coral,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _size,
        height: _size + 6,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: _bg.withValues(alpha: 0.45),
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          letter.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class EmptySlot extends StatelessWidget {
  const EmptySlot({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 52,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.muted, width: 2),
        ),
      ),
    );
  }
}
