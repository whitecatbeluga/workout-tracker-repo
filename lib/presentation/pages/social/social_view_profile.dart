import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
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
  final String userName;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.imagePath,
    required this.followers,
    required this.following,
    required this.userName,
  });

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
            CircleAvatar(
              radius: 50,
              backgroundImage: (imagePath.isNotEmpty)
                  ? NetworkImage(imagePath)
                  : null,
              child: (imagePath.isEmpty)
                  ? Text(
                      name.isNotEmpty == true ? name[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 40),
                    )
                  : null,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(email, style: TextStyle(fontSize: 14)),
                  ],
                ),

                Row(
                  spacing: 20,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          followers.toString(),
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
                          following.toString(),
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

class VisitProfilePage extends StatefulWidget {
  final String? name;

  const VisitProfilePage({super.key, this.name});

  @override
  State<VisitProfilePage> createState() => _VisitProfilePageState();
}

class _VisitProfilePageState extends State<VisitProfilePage> {
  bool isFollowing = false;
  final user = authService.value.getCurrentUser();

  String? id;
  String? accountPicture;
  String? firstName;
  String? lastName;
  String? userName;
  String? email;

  @override
  void initState() {
    super.initState();

    // Delay until context is available, then extract route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        setState(() {
          id = args['id'] as String?;
          accountPicture = args['accountPicture'] as String?;
          firstName = args['firstName'] as String?;
          lastName = args['lastName'] as String?;
          userName = args['userName'] as String?;
          email = args['email'] as String?;
        });

        fetchCounts();
        _loadFollowingStatus();
      }
    });
  }

  int followerCount = 0;
  int followingCount = 0;
  int workoutPostCount = 0;

  Future<void> fetchCounts() async {
    if (id == null) return;

    final followersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('followers')
        .get();
    final followingSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('following')
        .get();

    setState(() {
      followerCount = followersSnapshot.docs.length;
      followingCount = followingSnapshot.docs.length;
    });
  }

  Future<void> _loadFollowingStatus() async {
    if (user == null) return;

    final repository = SocialRepositoryImpl(FirebaseFirestore.instance);

    try {
      final following = await repository.checkIfFollowing(user!.uid, id!);

      if (mounted) {
        setState(() {
          isFollowing = following;
        });
      }
    } catch (e) {
      debugPrint('Error checking follow status: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not check follow status')));
    }
  }

  Future<void> _handleFollow() async {
    if (user == null) return;

    final repository = SocialRepositoryImpl(FirebaseFirestore.instance);

    try {
      await repository.toggleFollowing(userId: user!.uid, followingId: id!);

      if (!mounted) return;

      await _loadFollowingStatus();
      await fetchCounts();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Follow/unfollow action failed. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = SocialRepositoryImpl(FirebaseFirestore.instance);

    if (id == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                  userName: userName ?? '',
                  name: '${firstName ?? ''} ${lastName ?? ''}',
                  email: email ?? '',
                  imagePath: accountPicture ?? '',
                  followers: followerCount,
                  following: followingCount,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: FutureBuilder<int>(
                  future: repository.countRoutines(id!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return TotalCount(
                        routineCount: 0,
                        workoutCount: workoutPostCount,
                      );
                    }

                    if (snapshot.hasError) {
                      return TotalCount(
                        routineCount: 0,
                        workoutCount: workoutPostCount,
                      );
                    }

                    final routineCount = snapshot.data ?? 0;

                    return TotalCount(
                      routineCount: routineCount,
                      workoutCount: workoutPostCount,
                    );
                  },
                ),
              ),
              if (id != user!.uid)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Button(
                    label: !isFollowing ? 'Follow' : 'Following',
                    onPressed: _handleFollow,
                    variant: !isFollowing
                        ? ButtonVariant.secondary
                        : ButtonVariant.gray,
                  ),
                ),

              Expanded(
                child: StreamBuilder<List<SocialWithUser>>(
                  stream: repository.fetchUserPublicWorkouts(id!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final posts = snapshot.data ?? [];

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (workoutPostCount != posts.length) {
                        setState(() {
                          workoutPostCount = posts.length;
                        });
                      }
                    });

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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
