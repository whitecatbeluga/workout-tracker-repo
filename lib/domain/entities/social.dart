import 'package:cloud_firestore/cloud_firestore.dart';

class Social {
  final String id;
  final Timestamp createdAt;
  final List<String> imageUrls;
  final int totalSets;
  final int totalVolume;
  final String uid;
  final bool visibleToEveryone;
  final String workoutDescription;
  final String workoutDuration;
  final String workoutTitle;

  Social({
    required this.id,
    required this.createdAt,
    required this.imageUrls,
    required this.totalSets,
    required this.totalVolume,
    required this.uid,
    required this.visibleToEveryone,
    required this.workoutDescription,
    required this.workoutDuration,
    required this.workoutTitle,
  });
}
