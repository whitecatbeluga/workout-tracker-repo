import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_tracker_repo/core/providers/navbar_screen_provider.dart';
import 'package:workout_tracker_repo/core/providers/workout_exercise_provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<User?> signUp(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<void> signOut() async {
    workoutExercises.value = [];
    routineExercises.value = [];
    savedExerciseSets = {};
    currentScreenIndex.value = 0;

    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
