import "../../domain/entities/comments.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class CommentsModel extends Comment {
  CommentsModel({
    required super.id,
    required super.from,
    required super.description,
    required super.createdAt,
  });

  factory CommentsModel.fromMap(Map<String, dynamic> data, String docId) {
    return CommentsModel(
      id: docId,
      from: data['from'] ?? '',
      description: data['description'] ?? '',
      createdAt: data['created_at'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'from': from, 'description': description, 'created_at': createdAt};
  }
}
