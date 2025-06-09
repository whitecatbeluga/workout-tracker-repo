import 'dart:async';

import 'package:flutter/material.dart';

class WorkoutTimer extends StatefulWidget {
  const WorkoutTimer({super.key});

  @override
  _WorkoutTimerState createState() => _WorkoutTimerState();
}

class _WorkoutTimerState extends State<WorkoutTimer> {
  int _seconds = 0;
  Timer? _timer;
  bool isRunning = false;

  void startTimer() {
    if (isRunning) return;
    isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void pauseTimer() {
    isRunning = false;
    _timer?.cancel();
  }

  void resetTimer() {
    pauseTimer();
    setState(() {
      _seconds = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}",
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: startTimer, child: Text("Start")),
            SizedBox(width: 10),
            ElevatedButton(onPressed: pauseTimer, child: Text("Pause")),
            SizedBox(width: 10),
            ElevatedButton(onPressed: resetTimer, child: Text("Reset")),
          ],
        ),
      ],
    );
  }
}
