class UserMeasurement {
  final DateTime date;
  final double weight;
  final double height;

  UserMeasurement({
    required this.date,
    required this.weight,
    required this.height,
  });

  @override
  String toString() {
    return 'UserMeasurement{date: $date, weight: $weight, height: $height}';
  }
}
