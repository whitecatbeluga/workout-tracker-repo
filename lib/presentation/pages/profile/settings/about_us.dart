import 'package:flutter/material.dart';

import '../../../../routes/profile/profile.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('About Us'),
        leading: IconButton(
          onPressed: Navigator.canPop(context)
              ? () => Navigator.pop(context)
              : () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    ProfileRoutes.settings,
                    (route) => false,
                  );
                },
          icon: const Icon(Icons.arrow_back),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE0E0E0), // Light gray border
            height: 1.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(text: "The Story Behind the "),
                    WidgetSpan(
                      child: Container(
                        color: Colors.yellow,
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          "Sweat",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Who we are",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 5),
            Text(
              "We're a small team of fitness enthusiasts and developers "
              "on a mission to make fitness tracking simple, powerful, and motivating. "
              "Workout Tracker was born out of the frustration with overcomplicated "
              "or cluttered workout apps.",
            ),
            SizedBox(height: 20),
            Text(
              "Why We Built This",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 5),
            Text(
              "We believe fitness progress should be easy to track and fun to "
              "follow. Whether you're lifting weights, running, or just getting "
              "started with a new routine, our goal is to give you the tools you need "
              "to stay consistent and celebrate your progress.",
            ),
            SizedBox(height: 20),
            Text(
              "Our Philosophy",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 5),
            Text(
              "Fitness is personal. That's why our app is built to adapt to your "
              "journey-no matter your goals. We focus on clean design, smooth experience, "
              "and features that matter.",
            ),
            SizedBox(height: 20),
            Text(
              "What's Next",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 5),
            Text(
              "We're constantly improving and adding new features based on your "
              "feedback. Expect updates that make tracking smarter, insights deeper, "
              "and workouts more rewarding.",
            ),
            SizedBox(height: 20),
            Text(
              "Get in Touch",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 5),
            Text(
              "We'd love to hear from you! If you have suggestions, ideas, "
              "or just want to say hello, drop us a message through the app or "
              "email us at workouttrackersupport@gmail.com",
            ),
            SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}
