import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_tracker_repo/data/repositories_impl/routine_repository_impl.dart';
import 'package:workout_tracker_repo/data/repositories_impl/social_repository_impl.dart';
import 'package:workout_tracker_repo/data/repositories_impl/workout_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/routine_service.dart';
import 'package:workout_tracker_repo/data/services/workout_service.dart';
import 'package:workout_tracker_repo/domain/entities/routine.dart';
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
  final ValueNotifier<String> selectedF = ValueNotifier('Week');
  final user = authService.value.getCurrentUser();
  final workoutRepo = WorkoutRepositoryImpl(WorkoutService());
  final routineRepo = RoutineRepositoryImpl(RoutineService());

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
      icon: Icons.scale,
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
              StreamBuilder(
                stream: routineRepo.streamFolders(user!.uid),
                builder: (context, routinesnapshot) {
                  if (routinesnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return SkeletonLoader();
                  }
                  if (routinesnapshot.hasError) {
                    return Center(
                      child: Text('Error: ${routinesnapshot.error}'),
                    );
                  }
                  int count = 0;
                  if (routinesnapshot.hasData) {
                    List<Folder> folders = routinesnapshot.data!;
                    for (var folder in folders) {
                      count += folder.routineIds!.length;
                    }
                  }
                  return StreamBuilder(
                    stream: workoutRepo.getWorkoutsByUserId(user!.uid),
                    builder: (context, workoutsnapshot) {
                      if (workoutsnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return SkeletonLoader();
                      }
                      if (workoutsnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${workoutsnapshot.error}'),
                        );
                      }
                      final workouts = workoutsnapshot.data ?? [];
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Row(
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: ProfileCard(
                                    label: "Routine",
                                    count: count.toString(),
                                  ),
                                ),
                                Expanded(
                                  child: ProfileCard(
                                    label: "Workout",
                                    count: workoutsnapshot.data!.length
                                        .toString(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Column(
                              children: [
                                GraphFilter(
                                  selectedValue: selectedFilter,
                                  onChanged: (newValue) {
                                    selectedF.value = newValue;
                                  },
                                ),
                                ValueListenableBuilder(
                                  valueListenable: selectedF,
                                  builder: (context, value, child) {
                                    return BarChartWidget(
                                      filter: selectedF.value,
                                      workouts: workouts,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
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

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Cards Row Placeholder
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 70,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Filter and Graph Placeholder
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              // Filter Dropdown Placeholder
              Container(
                height: 40,
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              // Chart Placeholder
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ],
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
                  radius: 50,
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
                          style: TextStyle(fontSize: 40),
                        )
                      : null,
                );
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                ValueListenableBuilder<UserProfile?>(
                  valueListenable: currentUserProfile,
                  builder: (context, profile, _) {
                    if (profile == null) return CircularProgressIndicator();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${profile.firstName} ${profile.lastName}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.user?.email ?? "",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    );
                  },
                ),

                Row(
                  spacing: 20,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          followerCount.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text("Followers", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          followingCount.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text("Following", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key, this.label, this.count});

  final String? label;
  final String? count;
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
              "Total ${widget.label}s",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  widget.count.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                ),
                Text(
                  '${widget.label}${int.parse(widget.count!) > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
