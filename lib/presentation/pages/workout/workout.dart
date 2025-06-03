import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/routes/auth/auth.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authService.value.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authService.value.signOut();
              Navigator.pushNamedAndRemoveUntil(context, AuthRoutes.login, (route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          user != null ? 'Welcome, ${user.email}' : 'No user signed in',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
