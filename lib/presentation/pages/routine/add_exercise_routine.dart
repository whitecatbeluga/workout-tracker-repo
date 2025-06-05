import 'package:flutter/material.dart';

class AddExerciseRoutine extends StatefulWidget {
  const AddExerciseRoutine({super.key});

  @override
  State<AddExerciseRoutine> createState() => _AddExerciseRoutineState();
}

class _AddExerciseRoutineState extends State<AddExerciseRoutine> {
  final TextEditingController _searchController = TextEditingController();
  Set<String> selectedExercises = {};

  final List<Exercise> exercises = [
    Exercise(
      name: 'Beginner Routine',
      description:
          'A routine designed for beginners to ease into fitness and build foundational strength.',
      icon: Icons.fitness_center,
    ),
    Exercise(
      name: 'Dumbbell Goblet Squat',
      description:
          'A routine designed for beginners to ease into fitness and build foundational strength.',
      icon: Icons.fitness_center,
    ),
    Exercise(
      name: 'Dumbbell Goblet Press',
      description:
          'A routine designed for beginners to ease into fitness and build foundational strength.',
      icon: Icons.fitness_center,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF48A6A7), fontSize: 16),
                  ),
                ),
              ),
              Text('Add Exercise', style: TextStyle(fontSize: 20)),
              GestureDetector(
                onTap: () {},
                child: Container(
                  margin: EdgeInsets.only(right: 5),
                  child: Text(
                    'Create',
                    style: TextStyle(color: Color(0xFF48A6A7), fontSize: 16),
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
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            // Add Exercise Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Add Exercise',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Add Exercise',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // All Exercises Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'All Exercises',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Exercise List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  final isSelected = selectedExercises.contains(exercise.name);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFCBD5E1), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          exercise.icon,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                      ),
                      title: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          exercise.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                      ),
                      trailing: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4ECDC4)
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                          color: isSelected
                              ? const Color(0xFF4ECDC4)
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedExercises.remove(exercise.name);
                          } else {
                            selectedExercises.add(exercise.name);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // Bottom Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: selectedExercises.isNotEmpty ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF48A6A7),
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    selectedExercises.isEmpty
                        ? 'Add 2 Exercises'
                        : 'Add ${selectedExercises.length} Exercise${selectedExercises.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Exercise {
  final String name;
  final String description;
  final IconData icon;

  Exercise({required this.name, required this.description, required this.icon});
}
