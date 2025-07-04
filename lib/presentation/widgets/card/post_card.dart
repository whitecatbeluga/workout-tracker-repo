import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/social_repository_impl.dart';
import 'package:workout_tracker_repo/domain/entities/comments_with_user.dart';
import 'package:workout_tracker_repo/domain/repositories/social_repository.dart';
import 'package:workout_tracker_repo/presentation/pages/profile/settings/edit_account.dart';
import 'package:workout_tracker_repo/routes/social/social.dart';
import '../../../domain/entities/social_with_user.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LikesBottomSheet extends StatefulWidget {
  final String workoutId;
  final SocialRepository repository;

  const LikesBottomSheet({
    super.key,
    required this.workoutId,
    required this.repository,
  });

  @override
  State<LikesBottomSheet> createState() => _LikesBottomSheetState();
}

class _LikesBottomSheetState extends State<LikesBottomSheet> {
  late Future<List<Map<String, dynamic>>> _likesFuture;

  @override
  void initState() {
    super.initState();
    _likesFuture = _fetchLikedUsers();
  }

  Future<List<Map<String, dynamic>>> _fetchLikedUsers() async {
    final firestore = FirebaseFirestore.instance;

    final likesSnapshot = await firestore
        .collection('workouts')
        .doc(widget.workoutId)
        .collection('likes')
        .get();

    final likedUserIds = likesSnapshot.docs
        .map((doc) => doc.data()['liked_by'] as String?)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toList();

    final users = <Map<String, dynamic>>[];

    for (final uid in likedUserIds) {
      final userDoc = await firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        users.add({
          'id': uid,
          'userName': data['user_name'] ?? '',
          'name': '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'
              .trim(),
          'firstName': data['first_name'] ?? '',
          'lastName': data['last_name'] ?? '',
          'picture': data['account_picture'] ?? '',
          'email': data['email'] ?? '',
        });
      }
    }

    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: 500,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _likesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading likes'));
            }

            final users = snapshot.data ?? [];

            if (users.isEmpty) {
              return const Center(child: Text('No likes yet'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final user = users[index];
                final id = user['id'] ?? '';
                final name = user['name'] ?? 'Unknown';
                final picture = user['picture'] ?? '';
                final firstName = user['firstName'] ?? '';
                final lastName = user['lastName'] ?? '';
                final userName = user['userName'] ?? '';
                final email = user['email'] ?? '';

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      SocialRoutes.visitProfile,
                      arguments: {
                        'id': id,
                        'accountPicture': picture,
                        'firstName': firstName,
                        'lastName': lastName,
                        'userName': userName,
                        'email': email,
                      },
                    );
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: picture.isNotEmpty
                            ? NetworkImage(picture)
                            : null,
                        child: picture.isEmpty
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CommentsBottomSheet extends StatefulWidget {
  final String workoutId;
  final SocialRepository repository;

  const CommentsBottomSheet({
    super.key,
    required this.workoutId,
    required this.repository,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final user = authService.value.getCurrentUser();
  final TextEditingController _controller = TextEditingController();
  bool _isPosting = false;

  Future<void> _handlePostComment() async {
    final commentText = _controller.text.trim();
    if (commentText.isEmpty) return;

    setState(() {
      _isPosting = true;
    });

    bool stillMounted = mounted;

    try {
      final currentUserId = user?.uid;

      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception('User not authenticated');
      }

      await widget.repository.postComment(
        workoutId: widget.workoutId,
        userId: currentUserId,
        description: commentText,
      );

      if (!mounted) return;

      _controller.clear();
    } catch (e) {
      if (mounted) {
        debugPrint('Error posting comment: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to post comment. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (stillMounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: 500,
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<CommentsWithUser>>(
                future: widget.repository.fetchCommentsWithUserData(
                  widget.workoutId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading comments'));
                  }

                  final comments = snapshot.data ?? [];

                  if (comments.isEmpty) {
                    return const Center(child: Text('No comments yet'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: comments.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final formattedDate = DateFormat(
                        'MMMM d, y h:mm a',
                      ).format(comment.createdAt.toDate());

                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            SocialRoutes.visitProfile,
                            arguments: {
                              'id': comment.from,
                              'accountPicture': comment.accountPicture,
                              'firstName': comment.firstName,
                              'lastName': comment.lastName,
                              'userName': comment.userName,
                              'email': comment.email,
                            },
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: comment.accountPicture.isNotEmpty
                                  ? NetworkImage(comment.accountPicture)
                                  : null,
                              child: comment.accountPicture.isEmpty
                                  ? Text(
                                      comment.firstName.isNotEmpty
                                          ? comment.firstName[0].toUpperCase()
                                          : '?',
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${comment.firstName} ${comment.lastName}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    comment.description,
                                    style: const TextStyle(
                                      color: Color(0xFF444444),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _handlePostComment,
                    icon: _isPosting
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.send),
                    color: Color(0xFF48A6A7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShareBottomSheet extends StatelessWidget {
  const ShareBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 160,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Workout',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20),
              Row(
                spacing: 20,
                children: [
                  Column(
                    children: [
                      FaIcon(FontAwesomeIcons.facebook, size: 40),
                      Text('Facebook', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      FaIcon(FontAwesomeIcons.instagram, size: 40),
                      Text('Instagram', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Column(
                    children: [
                      FaIcon(FontAwesomeIcons.xTwitter, size: 40),
                      Text('X', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final SocialWithUser data;
  final VoidCallback? onTap;
  final VoidCallback? viewProfileOnTap;

  const PostCard({
    super.key,
    required this.data,
    this.onTap,
    this.viewProfileOnTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool isLiked;
  late int likeCount;
  bool isFollowing = false;
  final user = authService.value.getCurrentUser();

  @override
  void initState() {
    super.initState();
    isLiked = widget.data.likedByUids.contains(user?.uid);
    likeCount = widget.data.likedByUids.length;
    _loadFollowingStatus();
  }

  Future<void> _handleLike() async {
    if (user == null) return;

    final repository = SocialRepositoryImpl(FirebaseFirestore.instance);

    try {
      await repository.toggleLike(
        workoutId: widget.data.social.id,
        userId: user!.uid,
      );

      if (!mounted) return;

      setState(() {
        if (isLiked) {
          isLiked = false;
          likeCount--;
        } else {
          isLiked = true;
          likeCount++;
        }
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to toggle like')));
    }
  }

  Future<void> _handleFollow() async {
    if (user == null || widget.data.social.uid == user!.uid) return;

    final repository = SocialRepositoryImpl(FirebaseFirestore.instance);

    try {
      await repository.toggleFollowing(
        userId: user!.uid,
        followingId: widget.data.social.uid,
      );

      if (!mounted) return;

      await _loadFollowingStatus();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Follow/unfollow action failed. Please try again.'),
        ),
      );
    }
  }

  Future<void> _loadFollowingStatus() async {
    if (user == null || widget.data.social.uid == user!.uid) return;

    final repository = SocialRepositoryImpl(FirebaseFirestore.instance);

    try {
      final following = await repository.checkIfFollowing(
        user!.uid,
        widget.data.social.uid,
      );

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

  @override
  Widget build(BuildContext context) {
    final createdAt = widget.data.social.createdAt.toDate();
    final timeAgo = timeago.format(createdAt);

    Stream<UserAccount> getUserAccount(String userId) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots()
          .map(
            (doc) => UserAccount(
              // password: doc.data()?['password'],
              email: doc.data()?['email'],
              accountPicture: doc.data()?['account_picture'],
              username: doc.data()?['user_name'],
            ),
          );
    }

    return InkWell(
      onTap: widget.onTap,
      child: Card(
        margin: EdgeInsets.only(top: 10),
        color: Colors.white,
        elevation: 0,
        child: Column(
          spacing: 10,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                spacing: 10,
                children: [
                  Container(
                    padding: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: widget.viewProfileOnTap,
                            child: Container(
                              padding: EdgeInsets.zero,
                              child: Row(
                                spacing: 10,
                                children: [
                                  StreamBuilder(
                                    stream: getUserAccount(user!.uid),
                                    builder: (context, res) {
                                      if (res.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(height: 10),
                                            ],
                                          ),
                                        );
                                      }

                                      if (res.hasError) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                                size: 60,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                'Error: ${res.error}',
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      UserAccount account = res.data!;
                                      return CircleAvatar(
                                        backgroundColor: Color(0xFF9ACBD0),
                                        backgroundImage:
                                            (account.accountPicture != null &&
                                                account
                                                    .accountPicture!
                                                    .isNotEmpty)
                                            ? NetworkImage(
                                                account.accountPicture!,
                                              )
                                            : null,
                                        child:
                                            (account.accountPicture == null ||
                                                account.accountPicture!.isEmpty)
                                            ? Text(
                                                account.accountPicture == "" ||
                                                        account.accountPicture ==
                                                            null
                                                    ? account.username![0]
                                                          .toUpperCase()
                                                    : '?',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF006A71),
                                                ),
                                              )
                                            : null,
                                      );
                                    },
                                  ),
                                  Container(
                                    padding: EdgeInsets.zero,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.data.userName,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        Text(
                                          timeAgo,
                                          style: TextStyle(
                                            color: Color(0xFFA7A7A7),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        (!isFollowing && widget.data.social.uid != user?.uid)
                            ? Container(
                                padding: EdgeInsets.zero,
                                child: TextButton(
                                  onPressed: _handleFollow,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: Color(0xFF006A71),
                                        size: 18,
                                      ),
                                      Text(
                                        'Follow',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF006A71),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.zero,
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data.social.workoutTitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(widget.data.social.workoutDescription),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.zero,
                    child: Row(
                      spacing: 50,
                      children: [
                        Container(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Time'),
                              Text(widget.data.social.workoutDuration),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Volume'),
                              Text(widget.data.social.totalVolume.toString()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.zero,
              child: widget.data.social.imageUrls.isNotEmpty
                  ? Image.network(widget.data.social.imageUrls[0])
                  : null,
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return LikesBottomSheet(
                            workoutId: widget.data.social.id,
                            repository: SocialRepositoryImpl(
                              FirebaseFirestore.instance,
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      '$likeCount likes',
                      style: TextStyle(color: Color(0xFF2C2C2C)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return CommentsBottomSheet(
                            workoutId: widget.data.social.id,
                            repository: SocialRepositoryImpl(
                              FirebaseFirestore.instance,
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      '${widget.data.commentCount} comments',
                      style: TextStyle(color: Color(0xFF2C2C2C)),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey, width: 1),
                  bottom: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _handleLike,
                    icon: Icon(
                      isLiked ? Icons.thumb_up_sharp : Icons.thumb_up_outlined,
                      color: isLiked ? Color(0xFF48A6A7) : null,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) => CommentsBottomSheet(
                          workoutId: widget.data.social.id,
                          repository: SocialRepositoryImpl(
                            FirebaseFirestore.instance,
                          ),
                        ),
                      );
                    },

                    icon: Icon(Icons.comment_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) => ShareBottomSheet(),
                      );
                    },
                    icon: Icon(Icons.ios_share),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
