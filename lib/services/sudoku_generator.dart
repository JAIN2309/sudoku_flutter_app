import 'dart:math';
import '../models/sudoku_cell.dart';
import '../models/game_stats.dart';

class SudokuGenerator {
  static final Random _random = Random();

  static List<List<SudokuCell>> generatePuzzle(Difficulty difficulty) {
    // Create a complete valid Sudoku grid
    List<List<int>> completeGrid = _generateCompleteGrid();
    
    // Remove numbers based on difficulty
    List<List<int>> puzzle = _removeCells(completeGrid, difficulty);
    
    // Convert to SudokuCell grid
    List<List<SudokuCell>> cellGrid = [];
    for (int row = 0; row < 9; row++) {
      List<SudokuCell> cellRow = [];
      for (int col = 0; col < 9; col++) {
        cellRow.add(SudokuCell(
          value: puzzle[row][col],
          correctValue: completeGrid[row][col],
          isFixed: puzzle[row][col] != 0,
        ));
      }
      cellGrid.add(cellRow);
    }
    
    return cellGrid;
  }

  static List<List<int>> _generateCompleteGrid() {
    List<List<int>> grid = List.generate(9, (_) => List.filled(9, 0));
    
    // Fill the grid using backtracking
    _fillGrid(grid);
    
    return grid;
  }

  static bool _fillGrid(List<List<int>> grid) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          List<int> numbers = List.generate(9, (i) => i + 1);
          numbers.shuffle(_random);
          
          for (int num in numbers) {
            if (_isValidMove(grid, row, col, num)) {
              grid[row][col] = num;
              
              if (_fillGrid(grid)) {
                return true;
              }
              
              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  static bool _isValidMove(List<List<int>> grid, int row, int col, int num) {
    // Check row
    for (int i = 0; i < 9; i++) {
      if (grid[row][i] == num) return false;
    }
    
    // Check column
    for (int i = 0; i < 9; i++) {
      if (grid[i][col] == num) return false;
    }
    
    // Check 3x3 box
    int boxRow = (row ~/ 3) * 3;
    int boxCol = (col ~/ 3) * 3;
    
    for (int i = boxRow; i < boxRow + 3; i++) {
      for (int j = boxCol; j < boxCol + 3; j++) {
        if (grid[i][j] == num) return false;
      }
    }
    
    return true;
  }

  static List<List<int>> _removeCells(List<List<int>> completeGrid, Difficulty difficulty) {
    List<List<int>> puzzle = completeGrid.map((row) => List<int>.from(row)).toList();
    
    int cellsToRemove = 81 - _random.nextInt(difficulty.maxClues - difficulty.minClues + 1) - difficulty.minClues;
    
    List<List<int>> positions = [];
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        positions.add([row, col]);
      }
    }
    positions.shuffle(_random);
    
    int removed = 0;
    for (List<int> pos in positions) {
      if (removed >= cellsToRemove) break;
      
      int row = pos[0];
      int col = pos[1];
      int backup = puzzle[row][col];
      
      puzzle[row][col] = 0;
      
      // Check if puzzle still has unique solution
      if (_hasUniqueSolution(puzzle)) {
        removed++;
      } else {
        puzzle[row][col] = backup;
      }
    }
    
    return puzzle;
  }

  static bool _hasUniqueSolution(List<List<int>> puzzle) {
    List<List<int>> testGrid = puzzle.map((row) => List<int>.from(row)).toList();
    int solutions = _countSolutions(testGrid, 0);
    return solutions == 1;
  }

  static int _countSolutions(List<List<int>> grid, int maxSolutions) {
    if (maxSolutions > 1) return maxSolutions;
    
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          int solutions = 0;
          
          for (int num = 1; num <= 9; num++) {
            if (_isValidMove(grid, row, col, num)) {
              grid[row][col] = num;
              solutions += _countSolutions(grid, maxSolutions - solutions);
              grid[row][col] = 0;
              
              if (solutions > 1) return solutions;
            }
          }
          return solutions;
        }
      }
    }
    return 1; // Complete grid found
  }

  static bool isValidSudoku(List<List<SudokuCell>> grid) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col].value != 0) {
          int value = grid[row][col].value;
          grid[row][col].value = 0; // Temporarily remove to check validity
          
          if (!_isValidMove(_cellGridToIntGrid(grid), row, col, value)) {
            grid[row][col].value = value; // Restore value
            return false;
          }
          
          grid[row][col].value = value; // Restore value
        }
      }
    }
    return true;
  }

  static List<List<int>> _cellGridToIntGrid(List<List<SudokuCell>> cellGrid) {
    return cellGrid.map((row) => row.map((cell) => cell.value).toList()).toList();
  }

  static bool isComplete(List<List<SudokuCell>> grid) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col].value == 0) return false;
      }
    }
    return isValidSudoku(grid);
  }

  static List<int> getPossibleValues(List<List<SudokuCell>> grid, int row, int col) {
    if (grid[row][col].value != 0) return [];
    
    List<int> possible = [];
    List<List<int>> intGrid = _cellGridToIntGrid(grid);
    
    for (int num = 1; num <= 9; num++) {
      if (_isValidMove(intGrid, row, col, num)) {
        possible.add(num);
      }
    }
    
    return possible;
  }
}
