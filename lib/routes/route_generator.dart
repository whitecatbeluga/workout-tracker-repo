import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/layouts/container.dart';
import 'package:workout_tracker_repo/presentation/pages/auth/landing_page.dart';
import 'package:workout_tracker_repo/presentation/pages/exercises/add_exercise.dart';
import 'package:workout_tracker_repo/presentation/pages/exercises/create_newexercise.dart';
import 'package:workout_tracker_repo/presentation/pages/profile/add_measurement.dart';
import 'package:workout_tracker_repo/presentation/pages/profile/exercise.dart';
import 'package:workout_tracker_repo/presentation/pages/profile/calendar.dart';
import 'package:workout_tracker_repo/presentation/pages/profile/measurement.dart';
import 'package:workout_tracker_repo/presentation/pages/profile/settings/edit_account.dart';
import 'package:workout_tracker_repo/presentation/pages/routine/create_routine.dart';
import 'package:workout_tracker_repo/presentation/pages/routine/log_routine.dart';
import 'package:workout_tracker_repo/presentation/pages/profile/settings.dart';
import 'package:workout_tracker_repo/presentation/pages/profile/statistics.dart';
import 'package:workout_tracker_repo/presentation/pages/social/social_view_profile.dart';
import 'package:workout_tracker_repo/presentation/pages/workout/log_workout.dart';
import 'package:workout_tracker_repo/presentation/pages/workout/save_workout_exercise.dart';
import 'package:workout_tracker_repo/routes/auth/auth.dart';
import 'package:workout_tracker_repo/routes/exercise/exercise.dart';
import 'package:workout_tracker_repo/routes/profile/profile.dart';
import 'package:workout_tracker_repo/routes/social/social.dart';
import 'package:workout_tracker_repo/routes/routine/routine.dart';
import 'package:workout_tracker_repo/routes/workout/workout.dart';
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
      case ProfileRoutes.statistics:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const StatisticsPage(),
          ifDenied: (_) => const LoginPage(),
        );
      case ProfileRoutes.calendar:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const CalendarPage(),
          ifDenied: (_) => const LoginPage(),
        );
      case ProfileRoutes.exercises:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const ExcercisesPage(),
          ifDenied: (_) => const LoginPage(),
        );
      case ProfileRoutes.measurements:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const MeasurementPage(),
          ifDenied: (_) => const LoginPage(),
        );
      case ProfileRoutes.addMeasurement:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const AddMeasurementPage(),
          ifDenied: (_) => const LoginPage(),
        );
      case ProfileRoutes.editAccount:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const EditAccountPage(),
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
          ifAllowed: (_) => const LogRoutine(),
          ifDenied: (_) => const LoginPage(),
        );
      case WorkoutRoutes.logWorkout:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const LogWorkout(),
          ifDenied: (_) => const LoginPage(),
        );
      case WorkoutRoutes.saveWorkout:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const SaveWorkout(),
          ifDenied: (_) => const LoginPage(),
        );
      case ExerciseRoutes.addWorkoutExercise:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const AddExercise(),
          ifDenied: (_) => const LoginPage(),
        );
      case ExerciseRoutes.createNewExercise:
        return guardedRoute(
          settings: settings,
          guard: () async => Authentication.isAuthenticated(),
          ifAllowed: (_) => const CreateNewExercisePage(),
          ifDenied: (_) => const LoginPage(),
        );

      default:
        return MaterialPageRoute(builder: (_) => const PageNotFound());
    }
  }
}
