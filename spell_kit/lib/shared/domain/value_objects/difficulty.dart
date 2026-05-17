enum Difficulty {
  starter(1, 1.0),
  explorer(2, 1.5),
  challenger(3, 2.0),
  master(4, 2.5),
  expert(5, 3.0);

  const Difficulty(this.level, this.multiplier);

  final int level;
  final double multiplier;

  static Difficulty fromLevel(int level) =>
      Difficulty.values.firstWhere((d) => d.level == level);
}
