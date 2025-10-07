import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/theme_controller.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.find<GameController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;

    return Obx(() => Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeController.cardBackground,
            themeController.cardBackground.withOpacity(0.8),
          ],
        ),
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
          // Numbers 1-9
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: isSmallScreen ? 8 : 12,
                mainAxisSpacing: isSmallScreen ? 8 : 12,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                int number = index + 1;
                return _buildNumberButton(
                  number,
                  gameController,
                  themeController,
                  isSmallScreen,
                );
              },
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 16),
          
          // Action buttons row
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.clear,
                  label: 'Clear',
                  onTap: gameController.clearCell,
                  themeController: themeController,
                  color: themeController.errorColor,
                  isSmallScreen: isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 6 : 12),
              Expanded(
                child: _buildActionButton(
                  icon: gameController.notesMode.value 
                      ? Icons.edit_note 
                      : Icons.note_add,
                  label: 'Notes',
                  onTap: gameController.toggleNotesMode,
                  themeController: themeController,
                  color: gameController.notesMode.value 
                      ? themeController.primaryGradientStart 
                      : themeController.textSecondary,
                  isActive: gameController.notesMode.value,
                  isSmallScreen: isSmallScreen,
                ),
              ),
              SizedBox(width: isSmallScreen ? 6 : 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.lightbulb_outline,
                  label: 'Hint (${gameController.remainingHints})',
                  onTap: gameController.canUseHint ? gameController.useHint : null,
                  themeController: themeController,
                  color: gameController.canUseHint 
                      ? themeController.warningColor 
                      : themeController.textSecondary,
                  isActive: gameController.canUseHint,
                  isSmallScreen: isSmallScreen,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(
      begin: 1,
      duration: 600.ms,
      curve: Curves.easeOutBack,
    ));
  }

  Widget _buildNumberButton(
    int number,
    GameController gameController,
    ThemeController themeController,
    bool isSmallScreen,
  ) {
    // Count how many times this number appears in the grid
    int count = 0;
    for (var row in gameController.grid) {
      for (var cell in row) {
        if (cell.value == number) count++;
      }
    }
    
    bool isComplete = count >= 9;
    
    return GestureDetector(
      onTap: isComplete ? null : () => gameController.inputNumber(number),
      child: Container(
        decoration: BoxDecoration(
          gradient: isComplete
              ? LinearGradient(
                  colors: [
                    themeController.textSecondary.withOpacity(0.3),
                    themeController.textSecondary.withOpacity(0.1),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    themeController.primaryGradientStart,
                    themeController.primaryGradientEnd,
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isComplete ? null : [
            BoxShadow(
              color: themeController.primaryGradientStart.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 24,
                  fontWeight: FontWeight.bold,
                  color: isComplete 
                      ? themeController.textSecondary 
                      : Colors.white,
                ),
              ),
            ),
            if (count > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isComplete 
                        ? themeController.successColor 
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 8 : 10,
                      fontWeight: FontWeight.bold,
                      color: isComplete ? Colors.white : themeController.textPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ).animate(target: isComplete ? 0 : 1)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(0.95, 0.95),
            duration: 200.ms,
          ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required ThemeController themeController,
    required Color color,
    bool isActive = false,
    bool isSmallScreen = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 8 : 12, 
          horizontal: isSmallScreen ? 4 : 8,
        ),
        decoration: BoxDecoration(
          color: isActive 
              ? color.withOpacity(0.2) 
              : themeController.cellBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : themeController.borderColor,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: onTap != null ? color : themeController.textSecondary,
              size: isSmallScreen ? 16 : 20,
            ),
            SizedBox(height: isSmallScreen ? 2 : 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 8 : 10,
                fontWeight: FontWeight.w600,
                color: onTap != null ? color : themeController.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate(target: isActive ? 1 : 0)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 200.ms,
          ),
    );
  }
}
