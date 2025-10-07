class SudokuCell {
  int value;
  int correctValue;
  bool isFixed;
  bool isSelected;
  bool isHighlighted;
  bool hasError;
  List<int> notes;

  SudokuCell({
    this.value = 0,
    this.correctValue = 0,
    this.isFixed = false,
    this.isSelected = false,
    this.isHighlighted = false,
    this.hasError = false,
    List<int>? notes,
  }) : notes = notes ?? [];

  SudokuCell copyWith({
    int? value,
    int? correctValue,
    bool? isFixed,
    bool? isSelected,
    bool? isHighlighted,
    bool? hasError,
    List<int>? notes,
  }) {
    return SudokuCell(
      value: value ?? this.value,
      correctValue: correctValue ?? this.correctValue,
      isFixed: isFixed ?? this.isFixed,
      isSelected: isSelected ?? this.isSelected,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      hasError: hasError ?? this.hasError,
      notes: notes ?? List.from(this.notes),
    );
  }

  bool get isEmpty => value == 0;
  bool get isCorrect => value == correctValue;
  bool get hasNotes => notes.isNotEmpty;

  @override
  String toString() {
    return 'SudokuCell(value: $value, correctValue: $correctValue, isFixed: $isFixed)';
  }
}
