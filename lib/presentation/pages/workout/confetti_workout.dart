import 'dart:math';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:workout_tracker_repo/presentation/layouts/container.dart';
import '../../widgets/buttons/button.dart';

class ConfettiWorkout extends StatefulWidget {
  const ConfettiWorkout({super.key});

  @override
  State<ConfettiWorkout> createState() => _ConfettiWorkoutState();
}

class _ConfettiWorkoutState extends State<ConfettiWorkout> {
  late ConfettiController _confettiController;

  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
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
                    Text("This is your 1st workout!",
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
