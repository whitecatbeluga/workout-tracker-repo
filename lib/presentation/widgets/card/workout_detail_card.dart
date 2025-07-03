import 'package:flutter/material.dart';

class WorkoutSet {
  final int setNumber;
  final String weightAndReps;

  WorkoutSet({required this.setNumber, required this.weightAndReps});
}

class WorkoutDetail extends StatelessWidget {
  final String exerciseName;
  final List<WorkoutSet> sets;

  const WorkoutDetail({
    super.key,
    required this.exerciseName,
    required this.sets,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(0),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exerciseName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF48A6A7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      spacing: 25,
                      children: [
                        Text(
                          'Set',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'WEIGHT & REPS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...sets.asMap().entries.map((entry) {
                    final set = entry.value;
                    final isOdd = (set.setNumber % 2 == 1);

                    return Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 15,
                      ),
                      color: isOdd ? Color(0xFF48A6A7) : Colors.transparent,
                      child: Row(
                        spacing: 30,
                        children: [
                          Text(
                            set.setNumber.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            set.weightAndReps,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
