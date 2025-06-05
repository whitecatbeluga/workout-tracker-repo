import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/post_card.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String imagePath;
  final int followers;
  final int following;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.imagePath,
    required this.followers,
    required this.following,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.all(0),
          child: Row(
            spacing: 10,
            children: [
              CircleAvatar(backgroundImage: AssetImage(imagePath)),
              Container(
                padding: EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(email, style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(0),
          child: Row(
            spacing: 14,
            children: [
              Container(
                padding: EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      followers.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text('Followers', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      following.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text('Following', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TotalCount extends StatelessWidget {
  final int routineCount;
  final int workoutCount;

  const TotalCount({
    super.key,
    required this.routineCount,
    required this.workoutCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(right: 8), // spacing between cards
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFDEDEDE), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Routines',
                  style: TextStyle(
                    color: Color(0xFF626262),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      routineCount.toString(),
                      style: TextStyle(
                        color: Color(0xFF323232),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'routines',
                      style: TextStyle(
                        color: Color(0xFF626262),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(left: 8), // spacing between cards
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFDEDEDE), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Workouts',
                  style: TextStyle(
                    color: Color(0xFF626262),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      workoutCount.toString(),
                      style: TextStyle(
                        color: Color(0xFF323232),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'workouts',
                      style: TextStyle(
                        color: Color(0xFF626262),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class VisitProfilePage extends StatelessWidget {
  final String? name;

  const VisitProfilePage({super.key, this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(name ?? 'Visit Profile'),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(0),
          child: Column(
            spacing: 20,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ProfileHeader(
                  name: 'John Smith Doe',
                  email: 'john@email.com',
                  imagePath: 'assets/images/guy1.png',
                  followers: 123,
                  following: 52,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: TotalCount(routineCount: 14, workoutCount: 12),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Button(
                  label: 'Follow',
                  onPressed: () {},
                  variant: ButtonVariant.secondary,
                ),
              ),
              // Fetch each posts made by the visited profile
              // PostCard(name: 'John Smith Doe', email: 'john@email.com'),
            ],
          ),
        ),
      ),
    );
  }
}
