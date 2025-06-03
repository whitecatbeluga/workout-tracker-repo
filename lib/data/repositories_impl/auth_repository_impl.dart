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
  Future<AppUser?> signUp(String email, String password) async {
    final user = await _authService.signUp(email, password);
    return user != null ? UserModel.fromFirebaseUser(user) : null;
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
