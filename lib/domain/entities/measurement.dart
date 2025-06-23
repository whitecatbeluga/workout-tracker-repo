class Measurement {
  final String? id;
  final String userId;
  final DateTime date;
  final double weight;
  final double height;
  String? imageUrl;

  Measurement({
    this.id,
    required this.userId,
    required this.date,
    required this.weight,
    required this.height,
    this.imageUrl,
  });
}
