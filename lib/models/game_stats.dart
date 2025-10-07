enum Difficulty { easy, medium, hard, expert }

class GameStats {
  final Difficulty difficulty;
  final int bestTime;
  final int gamesPlayed;
  final int gamesWon;
  final double winRate;
  final int totalHintsUsed;
  final int averageTime;
  final int streak;
  final int maxStreak;

  GameStats({
    required this.difficulty,
    this.bestTime = 0,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.winRate = 0.0,
    this.totalHintsUsed = 0,
    this.averageTime = 0,
    this.streak = 0,
    this.maxStreak = 0,
  });

  GameStats copyWith({
    Difficulty? difficulty,
    int? bestTime,
    int? gamesPlayed,
    int? gamesWon,
    double? winRate,
    int? totalHintsUsed,
    int? averageTime,
    int? streak,
    int? maxStreak,
  }) {
    return GameStats(
      difficulty: difficulty ?? this.difficulty,
      bestTime: bestTime ?? this.bestTime,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      winRate: winRate ?? this.winRate,
      totalHintsUsed: totalHintsUsed ?? this.totalHintsUsed,
      averageTime: averageTime ?? this.averageTime,
      streak: streak ?? this.streak,
      maxStreak: maxStreak ?? this.maxStreak,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty.index,
      'bestTime': bestTime,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'winRate': winRate,
      'totalHintsUsed': totalHintsUsed,
      'averageTime': averageTime,
      'streak': streak,
      'maxStreak': maxStreak,
    };
  }

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      difficulty: Difficulty.values[json['difficulty'] ?? 0],
      bestTime: json['bestTime'] ?? 0,
      gamesPlayed: json['gamesPlayed'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
      winRate: json['winRate']?.toDouble() ?? 0.0,
      totalHintsUsed: json['totalHintsUsed'] ?? 0,
      averageTime: json['averageTime'] ?? 0,
      streak: json['streak'] ?? 0,
      maxStreak: json['maxStreak'] ?? 0,
    );
  }
}

extension DifficultyExtension on Difficulty {
  String get name {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
    }
  }

  int get minClues {
    switch (this) {
      case Difficulty.easy:
        return 40;
      case Difficulty.medium:
        return 30;
      case Difficulty.hard:
        return 25;
      case Difficulty.expert:
        return 17;
    }
  }

  int get maxClues {
    switch (this) {
      case Difficulty.easy:
        return 50;
      case Difficulty.medium:
        return 39;
      case Difficulty.hard:
        return 29;
      case Difficulty.expert:
        return 24;
    }
  }

  int get maxHints {
    switch (this) {
      case Difficulty.easy:
        return 5;
      case Difficulty.medium:
        return 3;
      case Difficulty.hard:
        return 2;
      case Difficulty.expert:
        return 1;
    }
  }
}
