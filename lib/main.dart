import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workout_tracker_repo/core/providers/user_info_provider.dart';
import 'package:workout_tracker_repo/routes/route_generator.dart';
import 'config/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await loadCurrentUserProfile();
  runApp(const WorkoutTracker());
}

class WorkoutTracker extends StatelessWidget {
  const WorkoutTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Workout Tracker",
      initialRoute: '/',
      theme: ThemeData(fontFamily: 'Inter', useMaterial3: true),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
