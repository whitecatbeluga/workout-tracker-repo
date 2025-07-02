import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:workout_tracker_repo/core/providers/navbar_screen_provider.dart';
import 'package:workout_tracker_repo/core/providers/workout_exercise_provider.dart';
import 'package:workout_tracker_repo/presentation/pages/profile/profile.dart';
import 'package:workout_tracker_repo/presentation/pages/social/social_page.dart';
import 'package:workout_tracker_repo/presentation/pages/workout/workout.dart';
import 'package:workout_tracker_repo/presentation/widgets/navigation/navbar.dart';
import 'package:workout_tracker_repo/presentation/widgets/navigation/workout_nav.dart';

class ContainerTree extends StatefulWidget {
  const ContainerTree({super.key});

  @override
  State<ContainerTree> createState() => _ContainerTreeState();
}

class _ContainerTreeState extends State<ContainerTree>
    with SingleTickerProviderStateMixin {
  bool _showFab = true;
  late final AnimationController _animationController;
  late final Animation<Offset> _offsetAnimation;

  final List<Widget> pages = [];
  Timer? _fabShowDelayTimer;

  @override
  void initState() {
    super.initState();
    pages.addAll([
      _wrapWithScrollListener(WorkoutPage()),
      _wrapWithScrollListener(SocialPage()),
      _wrapWithScrollListener(ProfilePage()),
    ]);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, 2.0), // Adjusted to fully slide off screen
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  Widget _wrapWithScrollListener(Widget page) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is UserScrollNotification) {
          final direction = notification.direction;

          if (direction == ScrollDirection.reverse && _showFab) {
            // Cancel any pending show
            _fabShowDelayTimer?.cancel();
            setState(() => _showFab = false);
            _animationController.forward();
          } else if (direction == ScrollDirection.forward && !_showFab) {
            // Delay showing the FAB
            _fabShowDelayTimer?.cancel(); // cancel any existing timer
            _fabShowDelayTimer = Timer(const Duration(milliseconds: 300), () {
              if (!_showFab) {
                setState(() => _showFab = true);
                _animationController.reverse();
              }
            });
          }
        }
        return false;
      },
      child: page,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: currentScreenIndex,
        builder: (context, value, child) {
          return pages.elementAt(value);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SlideTransition(
        position: _offsetAnimation,
        child: ValueListenableBuilder(
          valueListenable: workoutExercises,
          builder: (context, exercises, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [if (exercises.isNotEmpty) WorkoutNav(), Navbar()],
            );
          },
        ),
      ),
    );
  }
}
