import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/game_stats.dart';
import '../widgets/game_header.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.put(GameController());
    final ThemeController themeController = Get.find<ThemeController>();
    
    // Get difficulty from arguments or default to easy
    final Difficulty difficulty = Get.arguments ?? Difficulty.easy;
    
    // Start new game if not already active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!gameController.isGameActive.value) {
        gameController.startNewGame(difficulty);
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              themeController.primaryGradientStart.withOpacity(0.05),
              themeController.primaryGradientEnd.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Obx(() => gameController.isPaused.value 
              ? _buildPausedScreen(gameController, themeController)
              : _buildGameScreen(gameController, themeController)),
        ),
      ),
    );
  }

  Widget _buildGameScreen(
    GameController gameController,
    ThemeController themeController,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxHeight < 700;
        
        return Column(
          children: [
            // Game Header
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
              child: const GameHeader(),
            ),
            
            // Sudoku Grid
            Expanded(
              flex: isSmallScreen ? 4 : 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: const SudokuGrid(),
                  ),
                ),
              ),
            ),
            
            // Number Pad
            Flexible(
              flex: isSmallScreen ? 3 : 2,
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
                child: const NumberPad(),
              ),
            ),
            
            // Game Controls
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
              child: _buildGameControls(gameController, themeController),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPausedScreen(
    GameController gameController,
    ThemeController themeController,
  ) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              themeController.cardBackground,
              themeController.cardBackground.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pause_circle_filled,
              size: 80,
              color: themeController.primaryGradientStart,
            ).animate().scale(
              begin: const Offset(0.5, 0.5),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Game Paused',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: themeController.textPrimary,
              ),
            ).animate().fadeIn(duration: 800.ms),
            
            const SizedBox(height: 12),
            
            Text(
              'Take your time and resume when ready',
              style: TextStyle(
                fontSize: 16,
                color: themeController.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 1000.ms),
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: _buildPauseButton(
                    'Resume',
                    Icons.play_arrow,
                    gameController.resumeFromPause,
                    themeController.primaryGradientStart,
                    themeController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPauseButton(
                    'New Game',
                    Icons.refresh,
                    () => _showNewGameDialog(gameController, themeController),
                    themeController.warningColor,
                    themeController,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: _buildPauseButton(
                'Home',
                Icons.home,
                () => Get.offAllNamed('/'),
                themeController.textSecondary,
                themeController,
              ),
            ),
          ],
        ),
      ).animate().scale(
        begin: const Offset(0.8, 0.8),
        duration: 400.ms,
        curve: Curves.easeOutBack,
      ),
    );
  }

  Widget _buildGameControls(
    GameController gameController,
    ThemeController themeController,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildControlButton(
            'Pause',
            Icons.pause,
            gameController.pauseGame,
            themeController.warningColor,
            themeController,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildControlButton(
            'New Game',
            Icons.refresh,
            () => _showNewGameDialog(gameController, themeController),
            themeController.primaryGradientStart,
            themeController,
          ),
        ),
        const SizedBox(width: 12),
        _buildIconControlButton(
          Icons.home,
          () => _showExitDialog(themeController),
          themeController.textSecondary,
          themeController,
        ),
      ],
    );
  }

  Widget _buildControlButton(
    String label,
    IconData icon,
    VoidCallback onTap,
    Color color,
    ThemeController themeController,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconControlButton(
    IconData icon,
    VoidCallback onTap,
    Color color,
    ThemeController themeController,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: themeController.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeController.borderColor,
            width: 1,
          ),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildPauseButton(
    String label,
    IconData icon,
    VoidCallback onTap,
    Color color,
    ThemeController themeController,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
      begin: const Offset(0.9, 0.9),
      duration: 200.ms,
    );
  }

  void _showNewGameDialog(
    GameController gameController,
    ThemeController themeController,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: themeController.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Start New Game?',
          style: TextStyle(
            color: themeController.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Your current progress will be lost.',
          style: TextStyle(
            color: themeController.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: themeController.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              gameController.startNewGame(gameController.currentDifficulty.value);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeController.primaryGradientStart,
            ),
            child: const Text(
              'New Game',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(ThemeController themeController) {
    Get.dialog(
      AlertDialog(
        backgroundColor: themeController.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Exit Game?',
          style: TextStyle(
            color: themeController.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Your progress will be saved automatically.',
          style: TextStyle(
            color: themeController.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: themeController.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeController.primaryGradientStart,
            ),
            child: const Text(
              'Exit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
