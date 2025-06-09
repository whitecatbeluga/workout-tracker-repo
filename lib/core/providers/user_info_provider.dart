import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:workout_tracker_repo/domain/entities/user_profile.dart';
import 'auth_service_provider.dart';
import 'package:flutter/foundation.dart';

ValueNotifier<UserProfile?> currentUserProfile = ValueNotifier(null);

Future<void> loadCurrentUserProfile() async {
  final user = authService.value.getCurrentUser();
  if (user != null) {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    currentUserProfile.value = UserProfile(
      userName: data?['user_name'] ?? 'Unknown',
      firstName: data?['first_name'] ?? 'Unknown',
      lastName: data?['last_name'] ?? 'Unknown',
    );
  }
}
