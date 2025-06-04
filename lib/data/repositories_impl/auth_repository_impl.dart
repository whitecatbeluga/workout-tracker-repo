import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_tracker_repo/data/errors/custom_exception.dart';
import 'package:workout_tracker_repo/data/services/auth_service.dart';
import 'package:workout_tracker_repo/domain/entities/user.dart';
import 'package:workout_tracker_repo/domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<AppUser?> signIn(String email, String password) async {
    try {
      final user = await _authService.signIn(email, password);
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    } on CustomErrorException catch (e) {
      throw CustomErrorException.fromCode(e.code);
    } catch (e) {
      throw const CustomErrorException(
        code: 'unknown',
        message: 'Unexpected error occurred.',
      );
    }
  }

  @override
  Future<AppUser?> signUp(UserModel data, String password) async {
    try {
      final user = await _authService.signUp(data.email, password);

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
    } on CustomErrorException catch (e) {
      throw CustomErrorException.fromCode(e.code);
    } catch (e) {
      throw const CustomErrorException(
        code: 'unknown',
        message: 'Unexpected error occurred.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } on CustomErrorException catch (e) {
      throw CustomErrorException.fromCode(e.code);
    } catch (e) {
      throw const CustomErrorException(
        code: 'unknown',
        message: 'Unexpected error occurred.',
      );
    }
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final user = _authService.getCurrentUser();
      return user != null ? UserModel.fromFirebaseUser(user) : null;
    } on CustomErrorException catch (e) {
      throw CustomErrorException.fromCode(e.code);
    } catch (e) {
      throw const CustomErrorException(
        code: 'unknown',
        message: 'Unexpected error occurred.',
      );
    }
  }
}
