import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/routine_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/routine_service.dart';
import 'package:workout_tracker_repo/domain/repositories/routine_repository.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import '../../../domain/entities/routine.dart';

class Collapsible extends StatefulWidget {
  const Collapsible({super.key, required this.folderContent});

  final Folder folderContent;

  @override
  State<Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<Collapsible> {
  bool _isExpanded = true;
  final user = authService.value.getCurrentUser();
  final TextEditingController _folderNameController = TextEditingController();
  final RoutineRepository _routineRepository = RoutineRepositoryImpl(
    RoutineService(),
  );

  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
  }

  void _updateFolder() async {
    final newFolderName = _folderNameController.text.trim();

    if (newFolderName.isNotEmpty) {
      try {
        await _routineRepository.updateFolderName(
          user!.uid,
          widget.folderContent.id,
          newFolderName,
        );

        Navigator.of(context).pop();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Folder updated successfully!')));

        setState(() {
          _folderNameController.clear();
        });
      } catch (e) {
        print('Error creating folder: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update folder. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Folder name cannot be empty.')));
    }
  }

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _toggleExpand,
                  child: Row(
                    spacing: 6,
                    children: [
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 30,
                        color: Color(0xFF323232),
                      ),
                      Text(
                        widget.folderContent.folderName ?? "",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                child: Icon(
                  Icons.edit_note,
                  size: 30,
                  color: Color(0xFF323232),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 20,
                            children: [
                              Text(
                                'Update Folder',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextField(
                                controller: _folderNameController,
                                decoration: InputDecoration(
                                  // hintText: 'Folder Name',
                                  hintText:
                                      widget.folderContent.folderName ?? "",
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                              Column(
                                spacing: 10,
                                children: [
                                  Button(
                                    label: 'Save',
                                    width: double.infinity,
                                    onPressed: () => _updateFolder(),
                                  ),
                                  Button(
                                    label: 'Cancel',
                                    textColor: Color(0xFF323232),
                                    width: double.infinity,
                                    variant: ButtonVariant.gray,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: (widget.folderContent.routines?.isEmpty ?? true)
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF323232),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          icon: const Icon(
                            Icons.add,
                            size: 20,
                            color: Color(0xFF006A71),
                          ),
                          label: const Text(
                            "Add Routine",
                            style: TextStyle(color: Color(0xFF006A71)),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    // ✅ Replaced Flexible with Container
                    constraints: const BoxConstraints(
                      maxHeight: 400, // set your desired height here
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.folderContent.routines?.length ?? 0,
                      itemBuilder: (context, index) {
                        final routine = widget.folderContent.routines?[index];
                        final exercises = routine?.exercises ?? [];

                        return Container(
                          margin: const EdgeInsets.only(top: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                              width: 1.2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(14.0),
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    routine?.routineName ?? 'Unnamed Routine',
                                    style: const TextStyle(
                                      color: Color(0xFF323232),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.more_horiz,
                                    size: 30,
                                    color: Color(0xFF323232),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Exercises
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: exercises.map((exercise) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text(
                                      exercise.name,
                                      style: const TextStyle(
                                        color: Color(0xFF626262),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              // Start Button
                              Button(
                                label: "Start Routine",
                                onPressed: () {},
                                prefixIcon: Icons.play_arrow_rounded,
                                fullWidth: true,
                                size: ButtonSize.large,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
