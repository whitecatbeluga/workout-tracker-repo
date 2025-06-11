import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_tracker_repo/domain/entities/user.dart';

class UserModel extends AppUser {
  final String userName;
  final String firstName;
  final String lastName;
  final String gender;
  final String address;
  final String activityLevel;
  final DateTime birthDate;
  final double bmi;
  final double height;
  final double weight;
  final List<String> workoutType;

  UserModel({
    required super.uid,
    required super.email,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.address,
    required this.activityLevel,
    required this.birthDate,
    required this.bmi,
    required this.height,
    required this.weight,
    required this.workoutType,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'user_name': userName,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'address': address,
      'activity_level': activityLevel,
      'birthdate': birthDate,
      'bmi': bmi,
      'height': height,
      'weight': weight,
      'workout_type': workoutType,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      userName: map['user_name'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      gender: map['gender'],
      address: map['address'],
      activityLevel: map['activity_level'],
      birthDate: (map['birthdate'] as Timestamp).toDate(),
      bmi: map['bmi'],
      height: map['height'],
      weight: map['weight'],
      workoutType: List<String>.from(map['workout_type']),
    );
  }

  factory UserModel.fromFirebaseUser(dynamic user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      userName: '',
      firstName: '',
      lastName: '',
      gender: '',
      address: '',
      activityLevel: '',
      birthDate: DateTime(2000, 1, 1),
      bmi: 0,
      height: 0,
      weight: 0,
      workoutType: [],
    );
  }
}
