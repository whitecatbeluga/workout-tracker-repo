import 'dart:math';

import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/widgets/badge/badge.dart';

class ExerciseCard extends StatefulWidget {
  final String exerciseName;
  final bool withEquipment;
  final String exerciseCategory;
  final String exerciseDescription;
  final String? imageUrl;

  const ExerciseCard({
    super.key,
    required this.exerciseName,
    required this.withEquipment,
    required this.exerciseCategory,
    required this.exerciseDescription,
    this.imageUrl,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController = AnimationController(
    vsync: this,
  );
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10,
        ), // change this value to your desired radius
      ),
      color: const Color.fromARGB(255, 255, 255, 255),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            // Always visible header section
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                (widget.imageUrl == null || widget.imageUrl!.isEmpty)
                    ? Transform.rotate(
                        angle: -pi / 4,
                        child: Icon(
                          widget.withEquipment
                              ? Icons.fitness_center
                              : Icons.accessibility_new,
                          size: 80,
                          color: Color(0xFF434343),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Image.network(
                          widget.imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                const SizedBox(width: 14),
                Text(
                  widget.exerciseName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Collapsible details section
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Category
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Exercise Category: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.exerciseCategory,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF626262),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Badge
                  BadgeWidget(
                    label: widget.withEquipment
                        ? 'With Equipment'
                        : 'No Equipment',
                    color: widget.withEquipment
                        ? const Color(0xFF48A6A7)
                        : const Color(0xFFED1010),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    widget.exerciseDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF626262),
                    ),
                    softWrap: true,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            // Show Details button
            GestureDetector(
              onTap: _toggleExpansion,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isExpanded ? 'Hide Details' : 'Show Details',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF48A6A7),
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF48A6A7),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
