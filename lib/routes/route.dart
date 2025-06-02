import 'package:flutter/cupertino.dart';
import 'package:workout_tracker_repo/pages/auth/login.dart';
import 'package:workout_tracker_repo/pages/auth/register.dart';
import 'package:workout_tracker_repo/pages/workout/workout.dart';

final Map<String,WidgetBuilder> appRoutes ={
  '/':(context) => const WorkoutPage(),
  '/login':(context)=> const LoginPage(),
  '/register':(context)=> const RegisterPage()
};