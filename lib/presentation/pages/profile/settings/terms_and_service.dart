import 'package:flutter/material.dart';

import '../../../../routes/profile/profile.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Terms of Service'),
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
            Text(
              "Terms of Service",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 25),
            ),
            Text(
              "Effective Date: April 15, 2025",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "1. Acceptance of Terms",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              "By accessing or using the Workout Tracker mobile application (the “App”), "
              "you agree to be bound by these Terms of Service (“Terms”). "
              "If you do not agree, please do not use the App.",
            ),

            SizedBox(height: 20),
            Text(
              "2. Description of Service",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              "Workout Tracker is a mobile app designed to help users track workouts,"
              " monitor progress, and manage fitness routines. The app may include "
              "features such as exercise logging, statistics tracking, calendar "
              "planning, and body measurements.",
            ),

            SizedBox(height: 20),
            Text(
              "3. User Accounts",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              "To use certain features of the App, you may be required to create an account. You agree to: \n"
              "\u2022 Provide accurate and complete information\n"
              "\u2022 Keep your login credentials secure\n"
              "\u2022 Be responsible for all activity under your account\n",
            ),

            SizedBox(height: 20),
            Text(
              "4. Use of the App",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              "You agree to use the App only for lawful purposes and in a way "
              "that does not infringe on the rights of others. You may not:\n"
                  "\u2022 Attempt to reverse-engineer or tamper with the app's code\n"
                  "\u2022 Use the app for commercial purposes without permission\n"
                  "\u2022 Upload any harmful, misleading, or offensive content\n",
            ),

            SizedBox(height: 20),
            Text(
              "5. Data & Privacy",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              "Your privacy is important to us. Please refer to our Privacy"
              " Policy for information on how we collect, use, and protect your "
              "data.",
            ),

            SizedBox(height: 20),
            Text(
              "6. Health Disclaimer",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              "Workout Tracker does not provide medical advice. Always consult with "
              "a qualified healthcare provider before starting any new fitness program. Use the app at your own risk.",
            ),

            SizedBox(height: 20),
            Text(
              "7. Limitation of Liability",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              "We strive to provide a reliable service, but we make no guarantees"
              " that the app will always be available or error-free. "
              "Workout Tracker is provided “as is,” and we are not liable for any"
              " damages resulting from your use of the app.",
            ),

            SizedBox(height: 20),
            Text(
              "8. Updates & Changes",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              "We may update these Terms from time to time. "
              "If we make significant changes, we’ll notify you through the "
              "app or by email. Continued use of the app after changes means"
              " you accept the new terms.",
            ),

            SizedBox(height: 20),
            Text(
              "9. Contact Us",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              "If you have any questions or concerns about these Terms, "
              "feel free to reach out at workouttracker-support@gmail.com",
            ),
          ],
        ),
      ),
    );
  }
}
