import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_tracker_repo/data/repositories_impl/social_repository_impl.dart';
import 'package:workout_tracker_repo/data/repositories_impl/workout_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/workout_service.dart';
import 'package:workout_tracker_repo/domain/entities/user_profile.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/profile-menu.dart';
import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/graphfilter.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/menu_list.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/post_card.dart';
import 'package:workout_tracker_repo/presentation/widgets/charts/barchart.dart';
import 'package:workout_tracker_repo/routes/profile/profile.dart';
import 'package:workout_tracker_repo/routes/social/social.dart';
import '../../../core/providers/user_info_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String selectedFilter = 'Week';
  final user = authService.value.getCurrentUser();
  final workoutRepo = WorkoutRepositoryImpl(WorkoutService());

  final repository = SocialRepositoryImpl(FirebaseFirestore.instance);

  final List<MenuItem> menuItems = const [
    MenuItem(
      title: "Statistics",
      icon: Icons.bar_chart,
      route: ProfileRoutes.statistics,
    ),
    MenuItem(
      title: "Exercises",
      icon: Icons.fitness_center,
      route: ProfileRoutes.exercises,
    ),
    MenuItem(
      title: "Measurements",
      icon: Icons.health_and_safety,
      route: ProfileRoutes.measurements,
    ),
    MenuItem(title: "Routines", icon: Icons.fitness_center, route: "/routines"),
    MenuItem(
      title: "Calendar",
      icon: Icons.calendar_month,
      route: ProfileRoutes.calendar,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: ValueListenableBuilder<UserProfile?>(
          valueListenable: currentUserProfile,
          builder: (context, profile, _) {
            return Text(
              profile?.userName ?? '',
              style: const TextStyle(fontWeight: FontWeight.w600),
            );
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                ProfileRoutes.settings,
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            spacing: 15,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ProfileHeader(user: user),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  spacing: 10,
                  children: [
                    Expanded(child: ProfileCard(label: "Routines")),
                    Expanded(child: ProfileCard(label: "Exercises")),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GraphFilter(
                        selectedValue: selectedFilter,
                        onChanged: (newValue) {
                          setState(() {
                            selectedFilter = newValue;
                          });
                        },
                      ),
                    ),
                    StreamBuilder(
                      stream: workoutRepo.getWorkoutsByUserId(user!.uid),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                CircularProgressIndicator(),
                                SizedBox(height: 10),
                                Text('Fetching your workouts...'),
                              ],
                            ),
                          );
                        }
                        final workouts = snapshot.data ?? [];
                        return BarChartWidget(
                          filter: selectedFilter,
                          workouts: workouts,
                        );
                      },
                    ),
                  ],
                ),
              ),
              MenuList(menuItems: menuItems),
              StreamBuilder(
                stream: repository.fetchMyWorkouts(user!.uid),
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
                    physics:
                        const NeverScrollableScrollPhysics(), // Prevent nested scroll
                    shrinkWrap:
                        true, // Let ListView size itself based on content
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
                              'accountPicture': post.accountPicture,
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
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key, this.user});

  final User? user;

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  int followerCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    if (widget.user?.uid == null) return;
    final uid = widget.user!.uid;

    final followersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('followers')
        .get();
    final followingSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();

    setState(() {
      followerCount = followersSnapshot.docs.length;
      followingCount = followingSnapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            ValueListenableBuilder<UserProfile?>(
              valueListenable: currentUserProfile,
              builder: (context, profile, _) {
                return CircleAvatar(
                  backgroundImage:
                      (profile != null &&
                          profile.accountPicture != null &&
                          profile.accountPicture!.isNotEmpty)
                      ? NetworkImage(profile.accountPicture!)
                      : null,
                  child:
                      (profile == null ||
                          profile.accountPicture == null ||
                          profile.accountPicture!.isEmpty)
                      ? Text(
                          profile?.userName.isNotEmpty == true
                              ? profile!.userName[0].toUpperCase()
                              : '?',
                        )
                      : null,
                );
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<UserProfile?>(
                  valueListenable: currentUserProfile,
                  builder: (context, profile, _) {
                    if (profile == null) return CircularProgressIndicator();
                    return Text(
                      '${profile.firstName} ${profile.lastName}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    );
                  },
                ),

                Text(widget.user?.email ?? "", style: TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
        Row(
          spacing: 20,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  followerCount.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text("Followers", style: TextStyle(fontSize: 14)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  followingCount.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text("Following", style: TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key, this.label});

  final String? label;

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFDEDEDE), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Card(
        elevation: 0,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total ${widget.label}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "14",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                ),
                Text('${widget.label}', style: TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
