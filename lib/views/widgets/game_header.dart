import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/game_stats.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.find<GameController>();
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeController.primaryGradientStart,
            themeController.primaryGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeController.primaryGradientStart.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: Difficulty and Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDifficultyChip(gameController, themeController),
              _buildMenuButton(themeController),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Middle row: Timer and Game Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimerWidget(gameController, themeController),
              _buildGameStatusWidget(gameController, themeController),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Bottom row: Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                'Hints Left',
                gameController.remainingHints.toString(),
                Icons.lightbulb_outline,
                themeController,
              ),
              _buildStatItem(
                'Best Time',
                _getBestTimeText(gameController),
                Icons.timer,
                themeController,
              ),
              _buildStatItem(
                'Win Rate',
                _getWinRateText(gameController),
                Icons.trending_up,
                themeController,
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(
      begin: -1,
      duration: 600.ms,
      curve: Curves.easeOutBack,
    ));
  }

  Widget _buildDifficultyChip(
    GameController gameController,
    ThemeController themeController,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getDifficultyIcon(gameController.currentDifficulty.value),
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            gameController.currentDifficulty.value.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().scale(
      begin: const Offset(0.8, 0.8),
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildMenuButton(ThemeController themeController) {
    return GestureDetector(
      onTap: () => Get.toNamed('/settings'),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.menu,
          color: Colors.white,
          size: 20,
        ),
      ),
    ).animate().rotate(
      begin: 0,
      end: 0.1,
      duration: 200.ms,
    );
  }

  Widget _buildTimerWidget(
    GameController gameController,
    ThemeController themeController,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            gameController.isPaused.value ? Icons.pause : Icons.timer,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            gameController.formattedTime,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    ).animate(target: gameController.isPaused.value ? 1 : 0)
        .tint(color: Colors.orange);
  }

  Widget _buildGameStatusWidget(
    GameController gameController,
    ThemeController themeController,
  ) {
    if (gameController.isGameComplete.value) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: themeController.successColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              'Complete!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ).animate().scale(
        begin: const Offset(0.5, 0.5),
        duration: 400.ms,
        curve: Curves.easeOutBack,
      ).then().shake(duration: 300.ms);
    }

    if (gameController.isPaused.value) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: themeController.warningColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pause,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              'Paused',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ThemeController themeController,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  IconData _getDifficultyIcon(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Icons.sentiment_satisfied;
      case Difficulty.medium:
        return Icons.sentiment_neutral;
      case Difficulty.hard:
        return Icons.sentiment_dissatisfied;
      case Difficulty.expert:
        return Icons.whatshot;
    }
  }

  String _getBestTimeText(GameController gameController) {
    GameStats? stats = gameController.getStatsForDifficulty(
      gameController.currentDifficulty.value,
    );
    
    if (stats == null || stats.bestTime == 0) {
      return '--:--';
    }
    
    int minutes = stats.bestTime ~/ 60;
    int seconds = stats.bestTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getWinRateText(GameController gameController) {
    GameStats? stats = gameController.getStatsForDifficulty(
      gameController.currentDifficulty.value,
    );
    
    if (stats == null || stats.gamesPlayed == 0) {
      return '0%';
    }
    
    return '${(stats.winRate * 100).toInt()}%';
  }
}
