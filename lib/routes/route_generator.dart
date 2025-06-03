import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/pages/auth/login.dart';
import 'package:workout_tracker_repo/pages/auth/register.dart';
import 'package:workout_tracker_repo/pages/page_not_found/page_not_found.dart';
import 'package:workout_tracker_repo/pages/workout/workout.dart';

class RouteGenerator{
  static Route<dynamic> generateRoute(RouteSettings settings){
    final user = FirebaseAuth.instance.currentUser;
    
    switch(settings.name){
      case'/':
        return MaterialPageRoute(builder: (_)=> user != null ? const WorkoutPage() : const LoginPage());
      case '/login':
        return MaterialPageRoute(builder: (_) => user == null ? const LoginPage(): const WorkoutPage());
      case "/register":
        return MaterialPageRoute(builder: (_)=> const RegisterPage());
      default:
        return MaterialPageRoute(builder: (_)=> const PageNotFound());
    }
  }
}