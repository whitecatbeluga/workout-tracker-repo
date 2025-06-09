import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/domain/entities/user_profile.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/post_card.dart';
import 'package:workout_tracker_repo/routes/social/social.dart';
import '../../../data/repositories_impl/social_repository_impl.dart';
import '../../../domain/entities/social_with_user.dart';
import '../../../core/providers/user_info_provider.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => SocialPageState();
}

class SocialPageState extends State<SocialPage> {
  bool isFollowingSelected = true;

  final user = authService.value.getCurrentUser();
  final repository = SocialRepositoryImpl(FirebaseFirestore.instance);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Row(
            spacing: 10,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage("assets/images/guy1.png"),
              ),
              ValueListenableBuilder<UserProfile?>(
                valueListenable: currentUserProfile,
                builder: (context, profile, _) {
                  return Text(
                    profile?.userName ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, SocialRoutes.search);
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              print('Notifications pressed');
            },
            icon: Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowingSelected
                            ? Color(0xFF006A71)
                            : Color(0xFFD9D9D9),
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            bottomLeft: Radius.circular(6),
                          ),
                        ),
                      ),
                      onPressed: () {
                        print('Following button pressed');
                        setState(() {
                          isFollowingSelected = true;
                        });
                      },
                      child: Text(
                        'Following',
                        style: TextStyle(
                          color: isFollowingSelected
                              ? Colors.white
                              : Color(0xFF323232),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowingSelected
                            ? Color(0xFFD9D9D9)
                            : Color(0xFF006A71),
                        padding: EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                          ),
                        ),
                      ),
                      onPressed: () {
                        print('Discover button pressed');
                        setState(() {
                          isFollowingSelected = false;
                        });
                      },
                      child: Text(
                        'Discover',
                        style: TextStyle(
                          color: isFollowingSelected
                              ? Color(0xFF323232)
                              : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<SocialWithUser>>(
                stream: repository.fetchPublicWorkouts(user!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final posts = snapshot.data ?? [];

                  if (posts.isEmpty) {
                    return const Center(child: Text('No public posts found.'));
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
    );
  }
}
