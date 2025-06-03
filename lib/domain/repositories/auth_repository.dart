import 'package:workout_tracker_repo/data/models/user_model.dart';
import 'package:workout_tracker_repo/domain/entities/user.dart';

abstract class AuthRepository{
  Future<AppUser?> signIn(String email, String password);
  Future<AppUser?> signUp(UserModel data, String password);
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
}