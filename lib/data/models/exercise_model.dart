import '../../domain/entities/exercise.dart';

class ExerciseModel extends Exercise {
  ExerciseModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.category,
    required super.withoutEquipment,
  });

  factory ExerciseModel.fromMap(Map<String, dynamic> data, String docId) {
    return ExerciseModel(
      id: docId,
      name: data['name'],
      description: data['description'],
      imageUrl: data['image_url'],
      category: data['category'],
      withoutEquipment: data['with_out_equipment'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'withoutEquipment': withoutEquipment,
    };
  }
}
