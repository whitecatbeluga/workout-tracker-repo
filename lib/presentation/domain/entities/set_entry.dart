class SetEntry {
  final int setNumber;
  final String previous;
  double kg;
  int reps;
  bool isCompleted;

  SetEntry({
    required this.setNumber,
    required this.previous,
    this.kg = 0,
    this.reps = 0,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'previous': previous,
      'kg': kg,
      'reps': reps,
      'isCompleted': isCompleted,
    };
  }
}
