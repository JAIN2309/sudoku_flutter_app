import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/game_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/sudoku_cell.dart';

class SudokuGrid extends StatelessWidget {
  const SudokuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.find<GameController>();
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() {
      if (gameController.grid.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeController.primaryGradientStart.withOpacity(0.1),
              themeController.primaryGradientEnd.withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: themeController.borderColor,
            width: 2,
          ),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 9,
              childAspectRatio: 1,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemCount: 81,
            itemBuilder: (context, index) {
              int row = index ~/ 9;
              int col = index % 9;
              return _buildCell(
                gameController.grid[row][col],
                row,
                col,
                gameController,
                themeController,
              );
            },
          ),
        ),
      ).animate().fadeIn(duration: 600.ms).scale(
        begin: const Offset(0.8, 0.8),
        duration: 400.ms,
        curve: Curves.easeOutBack,
      );
    });
  }

  Widget _buildCell(
    SudokuCell cell,
    int row,
    int col,
    GameController gameController,
    ThemeController themeController,
  ) {
    return GestureDetector(
      onTap: () => gameController.selectCell(row, col),
      child: Container(
        decoration: BoxDecoration(
          color: _getCellColor(cell, themeController),
          border: Border.all(
            color: _getBorderColor(row, col, themeController),
            width: _getBorderWidth(row, col),
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: cell.isSelected
              ? [
                  BoxShadow(
                    color: themeController.primaryGradientStart.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: cell.hasNotes && cell.value == 0
              ? _buildNotesWidget(cell, themeController)
              : _buildValueWidget(cell, themeController),
        ),
      ).animate(target: cell.isSelected ? 1 : 0)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 200.ms,
          )
          .animate(target: cell.hasError ? 1 : 0)
          .shake(
            duration: 300.ms,
            hz: 4,
          ),
    );
  }

  Widget _buildValueWidget(SudokuCell cell, ThemeController themeController) {
    if (cell.value == 0) return const SizedBox.shrink();

    return Text(
      cell.value.toString(),
      style: TextStyle(
        fontSize: 20,
        fontWeight: cell.isFixed ? FontWeight.bold : FontWeight.w600,
        color: cell.hasError
            ? themeController.errorColor
            : cell.isFixed
                ? themeController.textSecondary
                : themeController.textPrimary,
      ),
    ).animate().fadeIn(duration: 200.ms).scale(
      begin: const Offset(0.5, 0.5),
      duration: 200.ms,
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildNotesWidget(SudokuCell cell, ThemeController themeController) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        int noteValue = index + 1;
        bool hasNote = cell.notes.contains(noteValue);
        
        return Center(
          child: hasNote
              ? Text(
                  noteValue.toString(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: themeController.textSecondary,
                  ),
                )
              : null,
        );
      },
    );
  }

  Color _getCellColor(SudokuCell cell, ThemeController themeController) {
    if (cell.hasError) {
      return themeController.errorCellBackground;
    }
    if (cell.isSelected) {
      return themeController.selectedCellBackground;
    }
    if (cell.isHighlighted) {
      return themeController.highlightedCellBackground;
    }
    if (cell.isFixed) {
      return themeController.fixedCellBackground;
    }
    return themeController.cellBackground;
  }

  Color _getBorderColor(int row, int col, ThemeController themeController) {
    // Thick borders for 3x3 box boundaries
    bool isThickBorder = (row % 3 == 0 && row != 0) ||
                        (col % 3 == 0 && col != 0) ||
                        row == 8 ||
                        col == 8;
    
    return isThickBorder
        ? themeController.primaryGradientStart
        : themeController.borderColor;
  }

  double _getBorderWidth(int row, int col) {
    // Thick borders for 3x3 box boundaries
    bool isThickBorder = (row % 3 == 0 && row != 0) ||
                        (col % 3 == 0 && col != 0) ||
                        row == 8 ||
                        col == 8;
    
    return isThickBorder ? 2.0 : 0.5;
  }
}
