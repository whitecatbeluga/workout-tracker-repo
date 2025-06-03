import 'package:workout_tracker_repo/domain/entities/user.dart';

class UserModel extends AppUser{
  UserModel({required super.uid, required super.email});
  factory UserModel.fromFirebaseUser(dynamic user){
    return UserModel(uid: user.uid, email: user.email ?? '');
  }
}