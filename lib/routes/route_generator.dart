import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/layouts/container.dart';
import 'package:workout_tracker_repo/presentation/pages/auth/landing_page.dart';
import 'package:workout_tracker_repo/routes/auth/auth.dart';
import 'package:workout_tracker_repo/routes/social/social.dart';

import '../presentation/pages/auth/login.dart';
import '../presentation/pages/auth/register.dart';
import '../presentation/pages/page_not_found/page_not_found.dart';
import '../presentation/pages/workout/workout.dart';
import '../presentation/pages/social/social_page.dart';
import '../presentation/pages/social/social_view_post.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final user = FirebaseAuth.instance.currentUser;

    switch (settings.name) {
      case AuthRoutes.home:
        return MaterialPageRoute(
          builder: (_) => user != null ? ContainerTree() : const LandingPage(),
        );
      case AuthRoutes.login:
        return MaterialPageRoute(
          builder: (_) =>
              user == null ? const LoginPage() : const WorkoutPage(),
        );
      case AuthRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case SocialRoutes.socialPage:
        return MaterialPageRoute(builder: (_) => const SocialPage());
      case SocialRoutes.viewPost:
        return MaterialPageRoute(builder: (_) => const ViewPost());
      default:
        return MaterialPageRoute(builder: (_) => const PageNotFound());
    }
  }
}
