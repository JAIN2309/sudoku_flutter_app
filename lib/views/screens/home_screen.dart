import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/theme_controller.dart';
import '../../models/game_stats.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // App Title
                _buildAppTitle(themeController),
                
                const SizedBox(height: 40),
                
                // Difficulty Selection
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Choose Difficulty',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: themeController.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Difficulty Cards
                      Expanded(
                        child: ListView.builder(
                          itemCount: Difficulty.values.length,
                          itemBuilder: (context, index) {
                            Difficulty difficulty = Difficulty.values[index];
                            return _buildDifficultyCard(
                              difficulty,
                              themeController,
                              index,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Bottom Actions
                _buildBottomActions(themeController),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppTitle(ThemeController themeController) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
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
          child: const Icon(
            Icons.grid_3x3,
            size: 40,
            color: Colors.white,
          ),
        ).animate().scale(
          begin: const Offset(0.5, 0.5),
          duration: 600.ms,
          curve: Curves.easeOutBack,
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Sudoku Master',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: themeController.textPrimary,
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(
          begin: 0.3,
          duration: 600.ms,
        ),
        
        Text(
          'Challenge Your Mind',
          style: TextStyle(
            fontSize: 16,
            color: themeController.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(duration: 1000.ms).slideY(
          begin: 0.3,
          duration: 600.ms,
        ),
      ],
    );
  }

  Widget _buildDifficultyCard(
    Difficulty difficulty,
    ThemeController themeController,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => Get.toNamed('/game', arguments: difficulty),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getDifficultyColor(difficulty).withOpacity(0.8),
                _getDifficultyColor(difficulty),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _getDifficultyColor(difficulty).withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getDifficultyIcon(difficulty),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      difficulty.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _getDifficultyDescription(difficulty),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${difficulty.minClues}-${difficulty.maxClues} clues • ${difficulty.maxHints} hints',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 100).ms).slideX(
      begin: 1,
      duration: 600.ms,
      curve: Curves.easeOutBack,
    ).fadeIn(duration: 400.ms);
  }

  Widget _buildBottomActions(ThemeController themeController) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Continue Game',
            Icons.play_arrow,
            () => Get.toNamed('/game'),
            themeController.primaryGradientStart,
            themeController,
          ),
        ),
        const SizedBox(width: 12),
        // Expanded(
        //   child: _buildActionButton(
        //     'Statistics',
        //     Icons.bar_chart,
        //     () => Get.toNamed('/statistics'),
        //     themeController.successColor,
        //     themeController,
        //   ),
        // ),
        const SizedBox(width: 12),
        _buildIconButton(
          Icons.settings,
          () => Get.toNamed('/settings'),
          themeController.textSecondary,
          themeController,
        ),
      ],
    );
  }

  Widget _buildActionButton(
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
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
      begin: const Offset(0.9, 0.9),
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback onTap,
    Color color,
    ThemeController themeController,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeController.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: themeController.borderColor,
            width: 1,
          ),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return const Color(0xFF10B981); // Green
      case Difficulty.medium:
        return const Color(0xFF3B82F6); // Blue
      case Difficulty.hard:
        return const Color(0xFFF59E0B); // Orange
      case Difficulty.expert:
        return const Color(0xFFEF4444); // Red
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

  String _getDifficultyDescription(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Perfect for beginners';
      case Difficulty.medium:
        return 'A balanced challenge';
      case Difficulty.hard:
        return 'For experienced players';
      case Difficulty.expert:
        return 'Ultimate brain test';
    }
  }
}
