import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/data/repositories_impl/social_repository_impl.dart';
import 'package:workout_tracker_repo/domain/entities/social_with_user.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/post_card.dart';
import 'package:workout_tracker_repo/routes/social/social.dart';

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
    final args = ModalRoute.of(context)?.settings.arguments;

    final repository = SocialRepositoryImpl(FirebaseFirestore.instance);

    if (args == null || args is! Map<String, dynamic>) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visit Profile')),
        body: const Center(child: Text('No profile data found')),
      );
    }

    final id = args['id'] as String?;
    final firstName = args['firstName'] as String?;
    final lastName = args['lastName'] as String?;
    final userName = args['userName'] as String?;
    final email = args['email'] as String?;

    if (id == null) {
      return const Scaffold(body: Center(child: Text('User ID not provided')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(userName ?? ''),
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
                  name: '${firstName ?? ''} ${lastName ?? ''}',
                  email: email ?? '',
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
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Button(
                  label: 'Follow',
                  onPressed: () {},
                  variant: ButtonVariant.secondary,
                ),
              ),
              Expanded(
                child: StreamBuilder<List<SocialWithUser>>(
                  stream: repository.fetchUserPublicWorkouts(id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final posts = snapshot.data ?? [];

                    if (posts.isEmpty) {
                      return const Center(
                        child: Text('No public posts found.'),
                      );
                    }

                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return PostCard(
                          data: post,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              SocialRoutes.viewPost,
                              arguments: post,
                            );
                          },
                          viewProfileOnTap: () {
                            Navigator.pushNamed(
                              context,
                              SocialRoutes.visitProfile,
                              arguments: {
                                'id': post.social.uid,
                                'firstName': post.firstName,
                                'lastName': post.lastName,
                                'userName': post.userName,
                                'email': post.email,
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
