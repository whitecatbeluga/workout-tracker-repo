import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/pages/auth/login.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/primary_button.dart';
import 'package:workout_tracker_repo/presentation/widgets/images/logo_hero.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                HeroLogo(),
                Image.asset("assets/images/landing-page.jpg"),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: const Text(
                    "The Repository for your Reps. Record your workouts, track your progress, and build consistent results.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Button(
                    label: "Get Started",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return LoginPage();
                          },
                        ),
                      );
                    },
                    size: ButtonSize.large,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Button(
                    label: "Continue as Guest",
                    onPressed: () {},
                    variant: ButtonVariant.white,
                    size: ButtonSize.large,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
