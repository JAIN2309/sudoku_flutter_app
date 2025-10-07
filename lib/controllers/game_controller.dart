import 'dart:async';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import '../models/sudoku_cell.dart';
import '../models/game_stats.dart';
import '../services/sudoku_generator.dart';
import '../services/storage_service.dart';

class GameController extends GetxController {
  // Game State
  final RxList<List<SudokuCell>> grid = <List<SudokuCell>>[].obs;
  final Rx<Difficulty> currentDifficulty = Difficulty.easy.obs;
  final RxInt selectedRow = (-1).obs;
  final RxInt selectedCol = (-1).obs;
  final RxBool isGameActive = false.obs;
  final RxBool isGameComplete = false.obs;
  final RxBool isPaused = false.obs;
  
  // Timer
  final RxInt elapsedSeconds = 0.obs;
  Timer? _gameTimer;
  
  // Game Features
  final RxInt hintsUsed = 0.obs;
  final RxInt maxHints = 3.obs;
  final RxBool notesMode = false.obs;
  final RxBool showErrors = true.obs;
  
  // Statistics
  final RxList<GameStats> gameStats = <GameStats>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadGameStats();
    _checkForSavedGame();
  }

  @override
  void onClose() {
    _gameTimer?.cancel();
    super.onClose();
  }

  // Game Management
  Future<void> startNewGame(Difficulty difficulty) async {
    currentDifficulty.value = difficulty;
    maxHints.value = difficulty.maxHints;
    hintsUsed.value = 0;
    elapsedSeconds.value = 0;
    isGameComplete.value = false;
    isPaused.value = false;
    selectedRow.value = -1;
    selectedCol.value = -1;
    
    // Generate new puzzle
    grid.value = SudokuGenerator.generatePuzzle(difficulty);
    isGameActive.value = true;
    
    // Start timer
    _startTimer();
    
    // Clear any saved game
    await StorageService.clearCurrentGame();
    
    // Trigger haptic feedback
    _vibrate();
  }

  Future<void> resumeGame() async {
    Map<String, dynamic>? savedGame = await StorageService.loadCurrentGame();
    
    if (savedGame != null) {
      grid.value = savedGame['grid'];
      currentDifficulty.value = savedGame['difficulty'];
      elapsedSeconds.value = savedGame['elapsedTime'];
      hintsUsed.value = savedGame['hintsUsed'];
      isPaused.value = savedGame['isPaused'];
      maxHints.value = currentDifficulty.value.maxHints;
      isGameActive.value = true;
      isGameComplete.value = false;
      
      if (!isPaused.value) {
        _startTimer();
      }
    }
  }

  void pauseGame() {
    if (isGameActive.value && !isGameComplete.value) {
      isPaused.value = true;
      _stopTimer();
      _saveCurrentGame();
    }
  }

  void resumeFromPause() {
    if (isPaused.value) {
      isPaused.value = false;
      _startTimer();
    }
  }

  // Cell Selection and Input
  void selectCell(int row, int col) {
    if (!isGameActive.value || isGameComplete.value || isPaused.value) return;
    
    // Clear previous selection
    _clearSelection();
    
    selectedRow.value = row;
    selectedCol.value = col;
    
    // Update cell selection state
    grid[row][col].isSelected = true;
    
    // Highlight similar numbers
    if (showErrors.value) {
      _highlightSimilarNumbers(grid[row][col].value);
    }
    
    grid.refresh();
    _vibrate();
  }

  void inputNumber(int number) {
    if (selectedRow.value == -1 || selectedCol.value == -1) return;
    if (!isGameActive.value || isGameComplete.value || isPaused.value) return;
    
    SudokuCell selectedCell = grid[selectedRow.value][selectedCol.value];
    
    if (selectedCell.isFixed) return;
    
    if (notesMode.value) {
      _toggleNote(selectedRow.value, selectedCol.value, number);
    } else {
      _setNumber(selectedRow.value, selectedCol.value, number);
    }
    
    _checkGameCompletion();
    _saveCurrentGame();
    _vibrate();
  }

  void clearCell() {
    if (selectedRow.value == -1 || selectedCol.value == -1) return;
    if (!isGameActive.value || isGameComplete.value || isPaused.value) return;
    
    SudokuCell selectedCell = grid[selectedRow.value][selectedCol.value];
    
    if (selectedCell.isFixed) return;
    
    selectedCell.value = 0;
    selectedCell.notes.clear();
    selectedCell.hasError = false;
    
    grid.refresh();
    _saveCurrentGame();
    _vibrate();
  }

  // Hint System
  void useHint() {
    if (hintsUsed.value >= maxHints.value) return;
    if (selectedRow.value == -1 || selectedCol.value == -1) return;
    if (!isGameActive.value || isGameComplete.value || isPaused.value) return;
    
    SudokuCell selectedCell = grid[selectedRow.value][selectedCol.value];
    
    if (selectedCell.isFixed || selectedCell.value == selectedCell.correctValue) return;
    
    selectedCell.value = selectedCell.correctValue;
    selectedCell.notes.clear();
    selectedCell.hasError = false;
    hintsUsed.value++;
    
    grid.refresh();
    _checkGameCompletion();
    _saveCurrentGame();
    _vibrate();
  }

  // Notes Mode
  void toggleNotesMode() {
    notesMode.value = !notesMode.value;
    _vibrate();
  }

  // Private Methods
  void _setNumber(int row, int col, int number) {
    SudokuCell cell = grid[row][col];
    
    if (number == cell.value) {
      cell.value = 0; // Clear if same number
    } else {
      cell.value = number;
    }
    
    cell.notes.clear();
    
    // Check for errors
    if (showErrors.value && cell.value != 0) {
      cell.hasError = !_isValidMove(row, col, cell.value);
    } else {
      cell.hasError = false;
    }
    
    grid.refresh();
  }

  void _toggleNote(int row, int col, int number) {
    SudokuCell cell = grid[row][col];
    
    if (cell.value != 0) return; // Can't add notes to filled cells
    
    if (cell.notes.contains(number)) {
      cell.notes.remove(number);
    } else {
      cell.notes.add(number);
      cell.notes.sort();
    }
    
    grid.refresh();
  }

  bool _isValidMove(int row, int col, int number) {
    // Create temporary grid for validation
    List<List<int>> tempGrid = grid.map((row) => 
        row.map((cell) => cell.value).toList()).toList();
    
    return SudokuGenerator.isValidSudoku(grid.value);
  }

  void _clearSelection() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        grid[i][j].isSelected = false;
        grid[i][j].isHighlighted = false;
      }
    }
  }

  void _highlightSimilarNumbers(int number) {
    if (number == 0) return;
    
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (grid[i][j].value == number) {
          grid[i][j].isHighlighted = true;
        }
      }
    }
  }

  void _checkGameCompletion() {
    if (SudokuGenerator.isComplete(grid.value)) {
      _completeGame();
    }
  }

  void _completeGame() {
    isGameComplete.value = true;
    isGameActive.value = false;
    _stopTimer();
    
    // Update statistics
    _updateGameStats(true);
    
    // Clear saved game
    StorageService.clearCurrentGame();
    
    // Trigger celebration
    _vibrate(duration: 500);
  }

  // Timer Management
  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused.value && isGameActive.value) {
        elapsedSeconds.value++;
      }
    });
  }

  void _stopTimer() {
    _gameTimer?.cancel();
  }

  // Data Persistence
  Future<void> _saveCurrentGame() async {
    if (!isGameActive.value) return;
    
    await StorageService.saveCurrentGame(
      grid: grid.value,
      difficulty: currentDifficulty.value,
      elapsedTime: elapsedSeconds.value,
      hintsUsed: hintsUsed.value,
      isPaused: isPaused.value,
    );
  }

  Future<void> _loadGameStats() async {
    gameStats.value = await StorageService.loadGameStats();
  }

  Future<void> _updateGameStats(bool won) async {
    await StorageService.updateGameStats(
      currentDifficulty.value,
      newTime: won ? elapsedSeconds.value : null,
      won: won,
      hintsUsed: hintsUsed.value,
    );
    
    // Reload stats
    await _loadGameStats();
  }

  Future<void> _checkForSavedGame() async {
    bool hasSavedGame = await StorageService.hasCurrentGame();
    if (hasSavedGame) {
      // You can show a dialog here to ask if user wants to resume
      await resumeGame();
    }
  }

  // Utility Methods
  void _vibrate({int duration = 50}) async {
    Map<String, dynamic> settings = await StorageService.loadSettings();
    if (settings['vibrationEnabled'] == true) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: duration);
      }
    }
  }

  String get formattedTime {
    int minutes = elapsedSeconds.value ~/ 60;
    int seconds = elapsedSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  GameStats? getStatsForDifficulty(Difficulty difficulty) {
    try {
      return gameStats.firstWhere((stat) => stat.difficulty == difficulty);
    } catch (e) {
      return null;
    }
  }

  bool get canUseHint => hintsUsed.value < maxHints.value;
  
  int get remainingHints => maxHints.value - hintsUsed.value;
}
