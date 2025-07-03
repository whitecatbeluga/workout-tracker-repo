import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/data/repositories_impl/predefined_routine_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/predefined_routine_service.dart';
import 'package:workout_tracker_repo/domain/entities/routine.dart';
import 'package:workout_tracker_repo/domain/entities/view_routine_args.dart';
import 'package:workout_tracker_repo/domain/repositories/predefined_routine_repository.dart';
import 'package:workout_tracker_repo/routes/routine/routine.dart';

class ExploreRoutines extends StatefulWidget {
  const ExploreRoutines({super.key});

  @override
  State<ExploreRoutines> createState() => _ExploreRoutinesState();
}

class _ExploreRoutinesState extends State<ExploreRoutines> {
  final PredefinedRoutineRepository _predefinedRoutineRepository =
      PredefinedRoutineRepositoryImpl(PredefinedRoutineService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Explore Routines'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: StreamBuilder<List<Routine>>(
          stream: _predefinedRoutineRepository.streamPredefinedRoutines(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final routines = snapshot.data;

            if (routines == null || routines.isEmpty) {
              return const Center(child: Text('No predefined routines found.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: routines.length,
              itemBuilder: (_, index) {
                final routine = routines[index];

                return Card(
                  elevation: 3,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RoutineRoutes.viewRoutine,
                        arguments: ViewRoutineArgs(
                          predefinedRoutineId: routine.id,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail image from first exercise (optional)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              routine.exercises.firstOrNull?.imageUrl ?? '',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Routine Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  routine.routineName ?? 'Untitled Routine',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  routine.exercises
                                      .map((e) => e.category)
                                      .toSet()
                                      .join(', '),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${routine.exercises.length} exercise(s)',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
