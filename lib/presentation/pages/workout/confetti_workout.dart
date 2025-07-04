import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:workout_tracker_repo/presentation/layouts/container.dart';
import '../../../core/providers/auth_service_provider.dart';
import '../../widgets/buttons/button.dart';

class ConfettiWorkout extends StatefulWidget {
  const ConfettiWorkout({super.key});


  @override
  State<ConfettiWorkout> createState() => _ConfettiWorkoutState();
}

class _ConfettiWorkoutState extends State<ConfettiWorkout> {
  late ConfettiController _confettiController;
  int workoutCount = 0;
  bool isLoading = true;

  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    fetchWorkoutCount();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
  Future<void> fetchWorkoutCount() async {
    final user = authService.value.getCurrentUser();

    if (user == null) {
      print("No user logged in.");
      return;
    };

    print("Fetching user: ${user.uid}");

    final querySnapshot = await FirebaseFirestore.instance
        .collection('workouts')
        .where('user_id', isEqualTo: user.uid)
        .get();

    setState(() {
      workoutCount = querySnapshot.docs.length;
      isLoading = false;
    });

  }

  String getOrdinalSuffix(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              emissionFrequency: 0.15,
              numberOfParticles: 100,
              gravity: 0.1,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    Text(
                      "Good Job!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("This is your ${getOrdinalSuffix(workoutCount)} workout!",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 550),
                  ],
                ),
              ),
            ),
            Button(
              label: 'Done',
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const ContainerTree()),
                      (route) => false,
                );
              },
              variant: ButtonVariant.secondary,
              size: ButtonSize.medium,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
