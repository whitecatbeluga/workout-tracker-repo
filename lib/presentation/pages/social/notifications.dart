import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_tracker_repo/data/repositories_impl/social_repository_impl.dart';
import 'package:workout_tracker_repo/domain/entities/notifications_with_user.dart';
// Import your repository and entities
import 'package:workout_tracker_repo/domain/repositories/social_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:workout_tracker_repo/routes/social/social.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsState();
}

class _NotificationsState extends State<NotificationsPage> {
  late final SocialRepository _socialRepository;
  late final String _currentUserId;

  @override
  void initState() {
    super.initState();
    _socialRepository = SocialRepositoryImpl(FirebaseFirestore.instance);
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: const Text('Notifications'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<NotificationWithUser>>(
                stream: _socialRepository.fetchNotifications(_currentUserId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading notifications',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final notifications = snapshot.data ?? [];

                  if (notifications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            color: Colors.grey[400],
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationItem(notification);
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

  Widget _buildNotificationItem(NotificationWithUser notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[300],
          backgroundImage: notification.accountPicture.isNotEmpty
              ? NetworkImage(notification.accountPicture)
              : null,
          child: notification.accountPicture.isEmpty
              ? Text(
                  '${notification.firstName[0]}${notification.lastName[0]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 14),
            children: [
              TextSpan(
                text: '${notification.firstName} ${notification.lastName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: ' ${notification.title} ${notification.description}',
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        subtitle: Row(
          children: [
            const Spacer(),
            Text(
              _formatTimeAgo(notification.createdAt),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          // Handle notification tap
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return '1 day ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM d, yyyy').format(dateTime);
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(NotificationWithUser notification) async {
    // Handle different notification types
    switch (notification.type) {
      case 'post':
        // For post notifications, fetch the actual post data using the postId
        if (notification.postId != null) {
          final post = await _socialRepository.fetchSocialWithUserByWorkoutId(
            notification.postId!,
          );
          if (post != null) {
            Navigator.pushNamed(
              context,
              SocialRoutes.viewPost,
              arguments: post,
            );
          } else {
            // If post not found, navigate to user profile instead
            Navigator.pushNamed(
              context,
              SocialRoutes.visitProfile,
              arguments: {
                'id': notification.from,
                'accountPicture': notification.accountPicture,
                'firstName': notification.firstName,
                'lastName': notification.lastName,
                'userName': notification.userName,
                'email': notification.email,
              },
            );
          }
        } else {
          // If no postId, navigate to user profile
          Navigator.pushNamed(
            context,
            SocialRoutes.visitProfile,
            arguments: {
              'id': notification.from,
              'accountPicture': notification.accountPicture,
              'firstName': notification.firstName,
              'lastName': notification.lastName,
              'userName': notification.userName,
              'email': notification.email,
            },
          );
        }
        break;
      case 'follow':
        // Navigate to follower's profile
        Navigator.pushNamed(
          context,
          SocialRoutes.visitProfile,
          arguments: {
            'id': notification.from,
            'accountPicture': notification.accountPicture,
            'firstName': notification.firstName,
            'lastName': notification.lastName,
            'userName': notification.userName,
            'email': notification.email,
          },
        );
        break;
      default:
        print('Tapped notification: ${notification.title}');
    }
  }
}
