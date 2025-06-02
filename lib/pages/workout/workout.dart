import 'package:flutter/material.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Tracker')),
      body: const Center(child: Text('Workout Screen')),
    );
  }
}