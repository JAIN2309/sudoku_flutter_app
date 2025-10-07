import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_stats.dart';
import '../models/sudoku_cell.dart';

class StorageService {
  static const String _statsKey = 'sudoku_stats';
  static const String _currentGameKey = 'current_game';
  static const String _settingsKey = 'app_settings';
  static const String _achievementsKey = 'achievements';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Game Statistics
  static Future<void> saveGameStats(List<GameStats> stats) async {
    await init();
    List<Map<String, dynamic>> jsonStats = stats.map((stat) => stat.toJson()).toList();
    await _prefs!.setString(_statsKey, jsonEncode(jsonStats));
  }

  static Future<List<GameStats>> loadGameStats() async {
    await init();
    String? jsonString = _prefs!.getString(_statsKey);
    
    if (jsonString == null) {
      // Return default stats for all difficulties
      return Difficulty.values.map((difficulty) => GameStats(difficulty: difficulty)).toList();
    }
    
    List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => GameStats.fromJson(json)).toList();
  }

  static Future<void> updateGameStats(Difficulty difficulty, {
    int? newTime,
    bool? won,
    int? hintsUsed,
  }) async {
    List<GameStats> allStats = await loadGameStats();
    int index = allStats.indexWhere((stat) => stat.difficulty == difficulty);
    
    if (index == -1) {
      allStats.add(GameStats(difficulty: difficulty));
      index = allStats.length - 1;
    }
    
    GameStats currentStats = allStats[index];
    
    int newGamesPlayed = currentStats.gamesPlayed + 1;
    int newGamesWon = currentStats.gamesWon + (won == true ? 1 : 0);
    double newWinRate = newGamesWon / newGamesPlayed;
    
    int newBestTime = currentStats.bestTime;
    if (won == true && newTime != null) {
      if (currentStats.bestTime == 0 || newTime < currentStats.bestTime) {
        newBestTime = newTime;
      }
    }
    
    int newStreak = won == true ? currentStats.streak + 1 : 0;
    int newMaxStreak = newStreak > currentStats.maxStreak ? newStreak : currentStats.maxStreak;
    
    allStats[index] = currentStats.copyWith(
      gamesPlayed: newGamesPlayed,
      gamesWon: newGamesWon,
      winRate: newWinRate,
      bestTime: newBestTime,
      totalHintsUsed: currentStats.totalHintsUsed + (hintsUsed ?? 0),
      streak: newStreak,
      maxStreak: newMaxStreak,
    );
    
    await saveGameStats(allStats);
  }

  // Current Game State
  static Future<void> saveCurrentGame({
    required List<List<SudokuCell>> grid,
    required Difficulty difficulty,
    required int elapsedTime,
    required int hintsUsed,
    required bool isPaused,
  }) async {
    await init();
    
    Map<String, dynamic> gameData = {
      'grid': grid.map((row) => row.map((cell) => {
        'value': cell.value,
        'correctValue': cell.correctValue,
        'isFixed': cell.isFixed,
        'notes': cell.notes,
      }).toList()).toList(),
      'difficulty': difficulty.index,
      'elapsedTime': elapsedTime,
      'hintsUsed': hintsUsed,
      'isPaused': isPaused,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    await _prefs!.setString(_currentGameKey, jsonEncode(gameData));
  }

  static Future<Map<String, dynamic>?> loadCurrentGame() async {
    await init();
    String? jsonString = _prefs!.getString(_currentGameKey);
    
    if (jsonString == null) return null;
    
    Map<String, dynamic> gameData = jsonDecode(jsonString);
    
    // Convert grid data back to SudokuCell objects
    List<List<SudokuCell>> grid = [];
    for (List<dynamic> rowData in gameData['grid']) {
      List<SudokuCell> row = [];
      for (Map<String, dynamic> cellData in rowData) {
        row.add(SudokuCell(
          value: cellData['value'],
          correctValue: cellData['correctValue'],
          isFixed: cellData['isFixed'],
          notes: List<int>.from(cellData['notes']),
        ));
      }
      grid.add(row);
    }
    
    return {
      'grid': grid,
      'difficulty': Difficulty.values[gameData['difficulty']],
      'elapsedTime': gameData['elapsedTime'],
      'hintsUsed': gameData['hintsUsed'],
      'isPaused': gameData['isPaused'],
      'timestamp': gameData['timestamp'],
    };
  }

  static Future<void> clearCurrentGame() async {
    await init();
    await _prefs!.remove(_currentGameKey);
  }

  // App Settings
  static Future<void> saveSettings({
    bool? isDarkMode,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? autoSave,
    bool? showTimer,
    bool? highlightSimilar,
  }) async {
    await init();
    
    Map<String, dynamic> currentSettings = await loadSettings();
    
    if (isDarkMode != null) currentSettings['isDarkMode'] = isDarkMode;
    if (soundEnabled != null) currentSettings['soundEnabled'] = soundEnabled;
    if (vibrationEnabled != null) currentSettings['vibrationEnabled'] = vibrationEnabled;
    if (autoSave != null) currentSettings['autoSave'] = autoSave;
    if (showTimer != null) currentSettings['showTimer'] = showTimer;
    if (highlightSimilar != null) currentSettings['highlightSimilar'] = highlightSimilar;
    
    await _prefs!.setString(_settingsKey, jsonEncode(currentSettings));
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    await init();
    String? jsonString = _prefs!.getString(_settingsKey);
    
    if (jsonString == null) {
      // Return default settings
      return {
        'isDarkMode': false,
        'soundEnabled': true,
        'vibrationEnabled': true,
        'autoSave': true,
        'showTimer': true,
        'highlightSimilar': true,
      };
    }
    
    return jsonDecode(jsonString);
  }

  // Achievements
  static Future<void> saveAchievements(List<String> achievements) async {
    await init();
    await _prefs!.setStringList(_achievementsKey, achievements);
  }

  static Future<List<String>> loadAchievements() async {
    await init();
    return _prefs!.getStringList(_achievementsKey) ?? [];
  }

  static Future<void> unlockAchievement(String achievementId) async {
    List<String> achievements = await loadAchievements();
    if (!achievements.contains(achievementId)) {
      achievements.add(achievementId);
      await saveAchievements(achievements);
    }
  }

  // Utility methods
  static Future<void> clearAllData() async {
    await init();
    await _prefs!.clear();
  }

  static Future<bool> hasCurrentGame() async {
    await init();
    return _prefs!.containsKey(_currentGameKey);
  }
}
