import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/social_repository_impl.dart';
import 'package:workout_tracker_repo/domain/entities/comments_with_user.dart';
import 'package:workout_tracker_repo/domain/repositories/social_repository.dart';
import '../../../domain/entities/social_with_user.dart';
import 'package:intl/intl.dart';

class LikesBottomSheet extends StatelessWidget {
  const LikesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Likes close'),
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

                      return Row(
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

class PostCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final createdAt = data.social.createdAt.toDate();
    final timeAgo = timeago.format(createdAt);

    return InkWell(
      onTap: onTap,
      child: Card(
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
                            onTap: viewProfileOnTap,
                            child: Container(
                              padding: EdgeInsets.zero,
                              child: Row(
                                spacing: 10,
                                children: [
                                  Container(
                                    padding: EdgeInsets.zero,
                                    child: CircleAvatar(
                                      backgroundImage: AssetImage(
                                        'assets/images/guy1.png',
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.zero,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data.userName,
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

                        Container(
                          padding: EdgeInsets.zero,
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
                          data.social.workoutTitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(data.social.workoutDescription),
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
                              Text(data.social.workoutDuration),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Volume'),
                              Text(data.social.totalVolume.toString()),
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
              child: data.social.imageUrls.isNotEmpty
                  ? Image.network(data.social.imageUrls[0])
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
                          return const LikesBottomSheet();
                        },
                      );
                    },
                    child: Text(
                      '${data.likedByUids.length} likes',
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
                            workoutId: data.social.id,
                            repository: SocialRepositoryImpl(
                              FirebaseFirestore.instance,
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      '${data.commentCount} comments',
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
                    onPressed: () {
                      print('Pressed like');
                    },
                    icon: Icon(Icons.thumb_up_outlined),
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
                          workoutId: data.social.id,
                          repository: SocialRepositoryImpl(
                            FirebaseFirestore.instance,
                          ),
                        ),
                      );
                    },

                    icon: Icon(Icons.comment),
                  ),
                  IconButton(
                    onPressed: () {
                      print('Pressed share');
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
