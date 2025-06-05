import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';

class LogWorkout extends StatefulWidget {
  const LogWorkout({super.key});

  @override
  State<LogWorkout> createState() => _LogWorkoutState();
}

class _LogWorkoutState extends State<LogWorkout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false, // disable default back button
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xFF323232)),
            onPressed: () {},
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Log Workout', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () {}, // your save action
                child: Row(
                  children: [
                    Icon(Icons.timer, color: Color(0xFF000000)),
                    SizedBox(width: 5),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF48A6A7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Duration',
                      style: TextStyle(fontSize: 16, color: Color(0xFF626262)),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      '0s',
                      style: TextStyle(fontSize: 16, color: Color(0xFF000000)),
                    ),
                  ],
                ),
                SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Volume',
                      style: TextStyle(fontSize: 16, color: Color(0xFF626262)),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      '0kg',
                      style: TextStyle(fontSize: 16, color: Color(0xFF000000)),
                    ),
                  ],
                ),
                SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sets',
                      style: TextStyle(fontSize: 16, color: Color(0xFF626262)),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      '0',
                      style: TextStyle(fontSize: 16, color: Color(0xFF000000)),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 10.0),
                  Icon(
                    Icons.fitness_center_rounded,
                    size: 90.0,
                    color: Color(0xFF626262),
                  ),
                  SizedBox(height: 10.0),
                  SizedBox(height: 10.0),
                  Text(
                    'Get Started',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    'Get started by adding an exercise to your routine.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF000000)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Button(
              label: 'Add Exercise',
              prefixIcon: Icons.add,
              onPressed: () {},
              variant: ButtonVariant.secondary,
            ),
            SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFFEEEEEE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFEEEEEE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Discard Workout',
                      style: TextStyle(color: Color(0xFFDB141F)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
