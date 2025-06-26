import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:workout_tracker_repo/data/errors/auth_custom_exception.dart';
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
    } on AuthErrorException catch (e) {
      throw AuthErrorException.fromCode(e.code);
    } catch (e) {
      throw const AuthErrorException(
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
    } on AuthErrorException catch (e) {
      throw AuthErrorException.fromCode(e.code);
    } catch (e) {
      throw const AuthErrorException(
        code: 'unknown',
        message: 'Unexpected error occurred.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } on AuthErrorException catch (e) {
      throw AuthErrorException.fromCode(e.code);
    } catch (e) {
      throw const AuthErrorException(
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
    } on AuthErrorException catch (e) {
      throw AuthErrorException.fromCode(e.code);
    } catch (e) {
      throw const AuthErrorException(
        code: 'unknown',
        message: 'Unexpected error occurred.',
      );
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Email does not exist');
      }

      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updateUserAvatar(String userId, File imageFile) async {
    String avatarUrl = '';
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    final currentAvatar = userDoc.data()?['account_picture'];
    if (currentAvatar != null && currentAvatar.isNotEmpty) {
      //if user has existing avatar
      final storageRef = FirebaseStorage.instance.refFromURL(currentAvatar);
      await storageRef.delete(); //delete existing avatar

      await storageRef.putFile(imageFile); //upload new avatar

      final downloadUrl = await storageRef
          .getDownloadURL(); //get new avatar url
      avatarUrl = downloadUrl;
    } else {
      //if user has no existing avatar
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child('$userId.jpg');
      await storageRef.putFile(imageFile); //upload new avatar

      final downloadUrl = await storageRef
          .getDownloadURL(); //get new avatar url
      avatarUrl = downloadUrl;
    }

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'account_picture': avatarUrl,
    });
  }

  @override
  Future<void> removeUserAvatar(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'account_picture': '',
    });
    final currentAvatar = userDoc.data()?['account_picture'];
    if (currentAvatar != null && currentAvatar.isNotEmpty) {
      //if user has existing avatar
      final storageRef = FirebaseStorage.instance.refFromURL(currentAvatar);
      await storageRef.delete(); //delete existing avatar
    }
  }
}
