import 'dart:io';

import 'package:workout_tracker_repo/data/models/user_model.dart';
import 'package:workout_tracker_repo/domain/entities/user.dart';

abstract class AuthRepository {
  Future<AppUser?> signIn(String email, String password);
  Future<AppUser?> signUp(UserModel data, String password);
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
  Future<void> forgotPassword(String email);
  Future<void> updateUserAvatar(String userId, File imageFile);
  Future<void> removeUserAvatar(String userId);
  Stream<UserModel> getUserDetails(String userId);
  Future<void> updateUserDetails(String userId, Map<String, dynamic> data);
}
