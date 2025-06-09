import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/layouts/container.dart';
import 'package:workout_tracker_repo/presentation/pages/auth/landing_page.dart';
import 'package:workout_tracker_repo/presentation/pages/routine/add_exercise_routine.dart';
import 'package:workout_tracker_repo/presentation/pages/routine/create_routine.dart';
import 'package:workout_tracker_repo/presentation/pages/routine/log_workout.dart';
<<<<<<< HEAD
import 'package:workout_tracker_repo/presentation/pages/profile/settings.dart';
=======
>>>>>>> c6af73c (Routine Pages:)
import 'package:workout_tracker_repo/presentation/pages/social/social_view_profile.dart';
import 'package:workout_tracker_repo/routes/auth/auth.dart';
import 'package:workout_tracker_repo/routes/profile/profile.dart';
import 'package:workout_tracker_repo/routes/social/social.dart';
import 'package:workout_tracker_repo/routes/routine/routine.dart';
import 'package:workout_tracker_repo/utils/authentication.dart';
import 'package:workout_tracker_repo/utils/guardedRoute.dart';

import '../presentation/pages/auth/login.dart';
import '../presentation/pages/auth/register.dart';
import '../presentation/pages/page_not_found/page_not_found.dart';
import '../presentation/pages/social/social_page.dart';
import '../presentation/pages/social/social_view_post.dart';
import '../presentation/pages/social/search.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AuthRoutes.home:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const ContainerTree(),
          ifDenied: (_) => const LandingPage(),
        );
      case AuthRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AuthRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case SocialRoutes.socialPage:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const SocialPage(),
          ifDenied: (_) => const LoginPage(),
        );
      case SocialRoutes.viewPost:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const ViewPost(),
          ifDenied: (_) => const LoginPage(),
        );
      case SocialRoutes.visitProfile:
<<<<<<< HEAD
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const VisitProfilePage(),
          ifDenied: (_) => const LoginPage(),
        );
      case SocialRoutes.search:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const SearchPage(),
          ifDenied: (_) => const LoginPage(),
        );
      case ProfileRoutes.settings:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const Settings(),
          ifDenied: (_) => const LoginPage(),
        );
      case RoutineRoutes.createRoutinePage:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const CreateRoutine(),
          ifDenied: (_) => const LoginPage(),
        );
      case RoutineRoutes.logWorkoutPage:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const LogWorkout(),
          ifDenied: (_) => const LoginPage(),
        );
      case RoutineRoutes.addExercisePage:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const AddExerciseRoutine(),
          ifDenied: (_) => const LoginPage(),
        );
=======
        return guardedRoute(guard: () async => Authentication.isAuthenticated(), ifAllowed: (_) => const VisitProfilePage(), ifDenied: (_) => const LoginPage());
      case RoutineRoutes.createRoutinePage:
        return guardedRoute(guard: () async => Authentication.isAuthenticated(), ifAllowed: (_) => const CreateRoutine(), ifDenied: (_) => const LoginPage());
      case RoutineRoutes.logWorkoutPage:
        return guardedRoute(guard: () async => Authentication.isAuthenticated(), ifAllowed: (_) => const LogWorkout(), ifDenied: (_) => const LoginPage());
      case RoutineRoutes.addExercisePage:
        return guardedRoute(guard: () async => Authentication.isAuthenticated(), ifAllowed: (_) => const AddExerciseRoutine(), ifDenied: (_) => const LoginPage());
>>>>>>> c6af73c (Routine Pages:)
      default:
        return MaterialPageRoute(builder: (_) => const PageNotFound());
    }
  }
}
