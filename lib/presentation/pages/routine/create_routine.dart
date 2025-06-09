import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
=======
import 'package:workout_tracker_repo/presentation/widgets/buttons/primary_button.dart';
>>>>>>> c6af73c (Routine Pages:)

class CreateRoutine extends StatefulWidget {
  const CreateRoutine({super.key});

  @override
  State<CreateRoutine> createState() => _CreateRoutineState();
}

class _CreateRoutineState extends State<CreateRoutine> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false, // disable default back button
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {}, // your cancel action
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF48A6A7), fontSize: 16),
                  ),
                ),
              ),
              Text('Create Routine', style: TextStyle(fontSize: 20)),
              GestureDetector(
                onTap: () {}, // your save action
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    color: Color(0xFF48A6A7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
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
            TextFormField(
              style: TextStyle(
                color: Color(0xFF626262),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Routine Title',
                hintStyle: TextStyle(
                  color: Color(0xFF626262).withValues(alpha: 0.5),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),

                border: InputBorder.none,
              ),
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

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Button(
          label: 'Add Exercise',
          prefixIcon: Icons.add,
          onPressed: () {},
          variant: ButtonVariant.secondary,
        ),
      ),
    );
  }
}
