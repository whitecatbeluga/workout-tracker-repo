import '../../domain/entities/social.dart';

class SocialModel extends Social {
  SocialModel({
    required super.id,
    required super.createdAt,
    required super.imageUrls,
    required super.totalSets,
    required super.totalVolume,
    required super.uid,
    required super.visibleToEveryone,
    required super.workoutDescription,
    required super.workoutDuration,
    required super.workoutTitle,
  });

  factory SocialModel.fromMap(Map<String, dynamic> data, String docId) {
    return SocialModel(
      id: docId,
      createdAt: data['created_at'],
      imageUrls: List<String>.from(data['image_urls']),
      totalSets: (data['total_sets'] as num).toInt(),
      totalVolume: (data['total_volume'] as num).toInt(),
      uid: data['user_id'].toString(),
      visibleToEveryone: data['visible_to_everyone'] ?? false,
      workoutDescription: data['workout_description'].toString(),
      workoutDuration: data['workout_duration'].toString(),
      workoutTitle: data['workout_title'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'created_at': createdAt,
      'image_urls': imageUrls,
      'total_sets': totalSets,
      'total_volume': totalVolume,
      'user_id': uid,
      'visible_to_everyone': visibleToEveryone,
      'workout_description': workoutDescription,
      'workout_duration': workoutDuration,
      'workout_title': workoutTitle,
    };
  }
}
