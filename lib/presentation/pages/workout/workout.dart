import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/services/auth-service/auth_service.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authService.value.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authService.value.signOut();
              // Navigate to login and remove all previous routes
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
