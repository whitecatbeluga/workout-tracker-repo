import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String from;
  final String description;
  final Timestamp createdAt;

  Comment({
    required this.id,
    required this.from,
    required this.description,
    required this.createdAt,
  });
}
