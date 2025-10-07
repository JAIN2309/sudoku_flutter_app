import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/game_stats.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.find<GameController>();
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeController.primaryGradientStart.withOpacity(0.1),
              themeController.primaryGradientEnd.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() => Column(
              children: [
                // Overall Stats Header
                _buildOverallStatsCard(gameController, themeController),
                
                const SizedBox(height: 20),
                
                // Difficulty Stats
                Expanded(
                  child: ListView.builder(
                    itemCount: Difficulty.values.length,
                    itemBuilder: (context, index) {
                      Difficulty difficulty = Difficulty.values[index];
                      GameStats? stats = gameController.getStatsForDifficulty(difficulty);
                      return _buildDifficultyStatsCard(
                        difficulty,
                        stats,
                        themeController,
                        index,
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Reset Button
                _buildResetButton(themeController),
              ],
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildOverallStatsCard(
    GameController gameController,
    ThemeController themeController,
  ) {
    int totalGames = 0;
    int totalWins = 0;
    int totalTime = 0;
    int bestOverallTime = 0;

    for (GameStats stats in gameController.gameStats) {
      totalGames += stats.gamesPlayed;
      totalWins += stats.gamesWon;
      if (stats.bestTime > 0) {
        if (bestOverallTime == 0 || stats.bestTime < bestOverallTime) {
          bestOverallTime = stats.bestTime;
        }
      }
    }

    double overallWinRate = totalGames > 0 ? (totalWins / totalGames) * 100 : 0;

    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            'Overall Statistics',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildOverallStatItem(
                  'Games Played',
                  totalGames.toString(),
                  Icons.games,
                ),
              ),
              Expanded(
                child: _buildOverallStatItem(
                  'Games Won',
                  totalWins.toString(),
                  Icons.emoji_events,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildOverallStatItem(
                  'Win Rate',
                  '${overallWinRate.toInt()}%',
                  Icons.trending_up,
                ),
              ),
              Expanded(
                child: _buildOverallStatItem(
                  'Best Time',
                  _formatTime(bestOverallTime),
                  Icons.timer,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(
      begin: -0.5,
      duration: 600.ms,
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildOverallStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDifficultyStatsCard(
    Difficulty difficulty,
    GameStats? stats,
    ThemeController themeController,
    int index,
  ) {
    Color difficultyColor = _getDifficultyColor(difficulty);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeController.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: difficultyColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getDifficultyIcon(difficulty),
                  color: difficultyColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                difficulty.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeController.textPrimary,
                ),
              ),
              const Spacer(),
              if (stats != null && stats.streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeController.successColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${stats.streak} streak',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: themeController.successColor,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (stats == null || stats.gamesPlayed == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No games played yet',
                  style: TextStyle(
                    color: themeController.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            // Stats Grid
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Games',
                        stats.gamesPlayed.toString(),
                        themeController,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Won',
                        stats.gamesWon.toString(),
                        themeController,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Win Rate',
                        '${(stats.winRate * 100).toInt()}%',
                        themeController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Best Time',
                        _formatTime(stats.bestTime),
                        themeController,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Max Streak',
                        stats.maxStreak.toString(),
                        themeController,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Hints Used',
                        stats.totalHintsUsed.toString(),
                        themeController,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    ).animate(delay: (index * 100).ms).slideX(
      begin: 1,
      duration: 600.ms,
      curve: Curves.easeOutBack,
    ).fadeIn(duration: 400.ms);
  }

  Widget _buildStatItem(
    String label,
    String value,
    ThemeController themeController,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: themeController.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: themeController.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton(ThemeController themeController) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showResetDialog(themeController),
        style: ElevatedButton.styleFrom(
          backgroundColor: themeController.errorColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Reset All Statistics',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _showResetDialog(ThemeController themeController) {
    Get.dialog(
      AlertDialog(
        backgroundColor: themeController.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Reset Statistics?',
          style: TextStyle(
            color: themeController.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will permanently delete all your game statistics. This action cannot be undone.',
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
              // TODO: Implement reset statistics
              Get.snackbar(
                'Statistics Reset',
                'All statistics have been cleared',
                backgroundColor: themeController.successColor,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeController.errorColor,
            ),
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return const Color(0xFF10B981);
      case Difficulty.medium:
        return const Color(0xFF3B82F6);
      case Difficulty.hard:
        return const Color(0xFFF59E0B);
      case Difficulty.expert:
        return const Color(0xFFEF4444);
    }
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

  String _formatTime(int seconds) {
    if (seconds == 0) return '--:--';
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
