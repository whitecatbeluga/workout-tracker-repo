import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_tracker_repo/data/services/auth_service.dart';
import 'package:workout_tracker_repo/domain/entities/user.dart';
import 'package:workout_tracker_repo/domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<AppUser?> signIn(String email, String password) async {
    final user = await _authService.signIn(email, password);
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }

  @override
  Future<AppUser?> signUp(UserModel data, String password) async {
    final user = await _authService.signUp(data.email,password);

    if (user != null) {
      final newUser = UserModel(
        uid: user.uid,
        email: data.email,
        userName: data.userName,
        firstName: data.firstName,
        lastName: data.lastName,
        gender: data.gender,
        address: data.address,
        activityLevel: data.activityLevel,
        birthDate: data.birthDate,
        bmi: data.bmi,
        height: data.height,
        weight: data.weight,
        workoutType: data.workoutType,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(newUser.toMap());
      return newUser;
    }

    return null;
  }


  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _authService.getCurrentUser();
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }
}
