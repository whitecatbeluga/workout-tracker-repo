import '../../domain/entities/measurement.dart';

class MeasurementModel extends Measurement {
  MeasurementModel({
    required super.id,
    required super.userId,
    required super.date,
    required super.weight,
    required super.height,
    super.imageUrl,
  });

  factory MeasurementModel.fromMap(Map<String, dynamic> data, String docId) {
    return MeasurementModel(
      id: docId,
      userId: data['user_id'],
      date: (data['created_at']).toDate(),
      weight: data['weight'].toDouble(),
      height: data['height'].toDouble(),
      imageUrl: data['image_url'],
    );
  }

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'created_at': date,
    'weight': weight,
    'height': height,
    'image_url': imageUrl,
  };

  @override
  String toString() {
    return 'MeasurementModel{id: $id, userId: $userId, date: $date, weight: $weight, height: $height, imageUrl: $imageUrl} }';
  }
}
