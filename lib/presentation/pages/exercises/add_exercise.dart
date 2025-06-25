import 'dart:async';
import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/core/providers/workout_exercise_provider.dart';
import 'package:workout_tracker_repo/domain/entities/exercise.dart';
import 'package:workout_tracker_repo/data/repositories_impl/exercise_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/exercise_service.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/routes/exercise/exercise.dart';

class AddExerciseArguments {
  final bool isLogWorkout;

  const AddExerciseArguments({required this.isLogWorkout});
}

class AddExercise extends StatefulWidget {
  const AddExercise({super.key});

  @override
  State<AddExercise> createState() => _AddExerciseState();
}

class _AddExerciseState extends State<AddExercise> {
  final user = authService.value.getCurrentUser();
  final TextEditingController _searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  final exerciseRepo = ExerciseRepositoryImpl(ExerciseService());
  final Set<Exercise> selectedExercises = <Exercise>{};

  // Add these for manual stream management
  List<Exercise> exercises = [];
  List<Exercise> originalExercises = [];
  List<Exercise> defaultExercises = [];
  List<Exercise> userExercises = [];
  bool isLoading = true;
  String? errorMessage;
  StreamSubscription<List<Exercise>>? _streamSubscription;
  StreamSubscription<List<Exercise>>? _userExercisesStreamSubscription;
  List<String> exerciseFilter = [
    'Default Exercises',
    'All Exercises',
    'My Exercises',
  ];
  String selectedFilter = 'Default Exercises';
  // Cache the arguments
  AddExerciseArguments? _arguments;
  bool get isLogWorkout => _arguments?.isLogWorkout ?? false;
  bool isEquipment = false;
  bool isFilter = false;

  @override
  void initState() {
    super.initState();
    // Don't call _getArguments here - ModalRoute might not be ready
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get arguments once and cache them
    if (_arguments == null) {
      _arguments = _getArguments(context);
      _listenToExercises();
    }
  }

  AddExerciseArguments? _getArguments(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    // Handle different argument types
    if (args is AddExerciseArguments) {
      return args;
    }

    if (args is Map<String, dynamic>) {
      return AddExerciseArguments(
        isLogWorkout: args['isLogWorkout'] as bool? ?? false,
      );
    }

    if (args is bool) {
      return AddExerciseArguments(isLogWorkout: args);
    }

    return null;
  }

  // void _listenToExercises() {
  //   _streamSubscription = exerciseRepo.getExercises().listen(
  //     (exerciseList) {
  //       if (mounted) {
  //         setState(() {
  //           exercises = exerciseList;
  //           if (isLogWorkout) {
  //             selectedExercises.addAll(
  //               workoutExercises.value.where(
  //                 (e) => exercises.any((ex) => ex.id == e.id),
  //               ),
  //             );
  //           } else {
  //             selectedExercises.addAll(
  //               routineExercises.value.where(
  //                 (e) => exercises.any((ex) => ex.id == e.id),
  //               ),
  //             );
  //           }
  //           isLoading = false;
  //           errorMessage = null;
  //         });
  //       }
  //     },
  //     onError: (error) {
  //       if (mounted) {
  //         setState(() {
  //           isLoading = false;
  //           errorMessage = error.toString();
  //         });
  //       }
  //     },
  //   );
  // }

  void _listenToExercises() {
    _streamSubscription = exerciseRepo.getExercises().listen((exerciseList) {
      _handleExercises(exerciseList, false);
    });

    _userExercisesStreamSubscription = exerciseRepo
        .getExercisesByUserId(user!.uid)
        .listen((userList) {
          _handleExercises(userList, true);
        });
  }

  void _handleExercises(List<Exercise> newExercises, bool isCustom) {
    if (mounted) {
      if (isCustom) {
        setState(() {
          userExercises.addAll(
            newExercises.where(
              (ex) =>
                  !userExercises.any((e) => e.id == ex.id), // Avoid duplicates
            ),
          );
          selectedExercises.clear();
          // final source = isLogWorkout ? workoutExercises : routineExercises;
          // selectedExercises.addAll(
          //   source.value.where((e) => exercises.any((ex) => ex.id == e.id)),
          // );
          // isLoading = false;
          // errorMessage = null;
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          defaultExercises.addAll(
            newExercises.where(
              (ex) => !defaultExercises.any(
                (e) => e.id == ex.id,
              ), // Avoid duplicates
            ),
          );
          selectedExercises.clear();
          // final source = isLogWorkout ? workoutExercises : routineExercises;
          // selectedExercises.addAll(
          //   source.value.where((e) => exercises.any((ex) => ex.id == e.id)),
          // );
          exercises.addAll(defaultExercises);
          originalExercises.addAll(defaultExercises);
          isLoading = false;
          errorMessage = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _userExercisesStreamSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // This method now only updates selectedExercises, not the exercise list
  void _toggleExerciseSelection(Exercise exercise) {
    focusNode.unfocus();
    setState(() {
      final isSelected = selectedExercises.any((e) => e.id == exercise.id);
      if (isSelected) {
        selectedExercises.removeWhere((e) => e.id == exercise.id);
      } else {
        selectedExercises.add(exercise);
      }
    });
  }

  void _showFilterDrawer(BuildContext context) {
    focusNode.unfocus();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return _buildFilterDrawer(context);
      },
    );
  }

  void _checkExercises() {
    switch (selectedFilter) {
      case 'Default Exercises':
        exercises = defaultExercises;
        break;
      case 'My Exercises':
        exercises = userExercises;
        break;
      case 'All Exercises':
        exercises = [...defaultExercises, ...userExercises];
        break;
    }
    originalExercises = exercises;
  }

  void _showEquipmentDrawer(BuildContext context) {
    focusNode.unfocus();
    bool tempEquipment = isEquipment; // Local temp value

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Optional: for full height
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Filter',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'With Equipment',
                        style: TextStyle(fontSize: 16),
                      ),
                      Switch(
                        activeColor: const Color(0xFF006A71),
                        value: tempEquipment,
                        onChanged: (value) {
                          setModalState(() {
                            tempEquipment = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Button(
                            label: 'Apply',
                            backgroundColor: const Color(0xFF006A71),
                            onPressed: () {
                              setState(() {
                                isFilter = true;
                                isEquipment = tempEquipment;
                                _checkExercises();
                                exercises = isEquipment
                                    ? exercises
                                          .where(
                                            (e) => e.withoutEquipment == true,
                                          )
                                          .toList()
                                    : exercises
                                          .where(
                                            (e) => e.withoutEquipment == false,
                                          )
                                          .toList();
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Button(
                            label: 'Clear',
                            textColor: const Color(0xFF006A71),
                            backgroundColor: Colors.white,
                            onPressed: () {
                              setState(() {
                                isEquipment = false;
                                isFilter = false;
                                _searchController.text = '';
                                _checkExercises();
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _filterSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _checkExercises();
      });
      return;
    }

    final filteredExercises = originalExercises.where((exercise) {
      return exercise.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      exercises = filteredExercises;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF48A6A7), fontSize: 16),
                  ),
                ),
              ),
              const Text('Add Exercise', style: TextStyle(fontSize: 20)),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    ExerciseRoutes.createNewExercise,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 5),
                  child: const Text(
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
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                focusNode: focusNode,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filterSearch('');
                      focusNode.unfocus();
                    },
                  ),
                ),
                onChanged: (text) {
                  _filterSearch(text);
                },
              ),
            ),
          ),

          // Exercise Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Button(
                    height: 45,
                    prefixIcon: Icons.tune,
                    label: selectedFilter,
                    onPressed: () => _showFilterDrawer(context),
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Button(
                    height: 45,
                    label: isFilter
                        ? isEquipment
                              ? "With Equipment"
                              : "No Equipment"
                        : 'Select Filter',
                    onPressed: () {
                      _showEquipmentDrawer(context);
                    },
                    variant: ButtonVariant.secondary,
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    prefixIcon: isFilter
                        ? isEquipment
                              ? Icons.check
                              : Icons.close
                        : Icons.filter_list,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Exercises',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // List of Exercises
          Expanded(child: _buildExerciseList()),

          // Add Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: selectedExercises.isNotEmpty
                  ? () {
                      if (isLogWorkout) {
                        workoutExercises.value = [...selectedExercises];
                      } else {
                        routineExercises.value = [...selectedExercises];
                      }
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF48A6A7),
                disabledBackgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                selectedExercises.isEmpty
                    ? 'Add 0 Exercises'
                    : 'Add ${selectedExercises.length} Exercise${selectedExercises.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Error: $errorMessage',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                _listenToExercises();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (exercises.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No exercises found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return _buildExerciseCard(exercise);
      },
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    final isSelected = selectedExercises.any((e) => e.id == exercise.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
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
            // child: Icon(
            //   Icons.fitness_center,
            //   color: Colors.grey[600],
            //   size: 24,
            // ),
            child: exercise.imageUrl != null && exercise.imageUrl!.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(exercise.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.fitness_center,
                    color: Colors.grey,
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
                color: isSelected ? const Color(0xFF4ECDC4) : Colors.grey[400]!,
                width: 2,
              ),
              color: isSelected ? const Color(0xFF4ECDC4) : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
          onTap: () => _toggleExerciseSelection(exercise),
        ),
      ),
    );
  }

  Widget _buildFilterDrawer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select Exercises Filter',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: exerciseFilter.length,
              itemBuilder: (context, index) {
                final exercise = exerciseFilter[index];
                return ListTile(
                  title: Text(exercise),
                  onTap: () {
                    setState(() {
                      selectedFilter = exercise;
                      isFilter = false;
                      _checkExercises();
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
