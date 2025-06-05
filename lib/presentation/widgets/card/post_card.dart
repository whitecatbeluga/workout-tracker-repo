import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../domain/entities/social_with_user.dart';

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
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.zero,
                    child: Row(children: [Text('20 likes')]),
                  ),
                  Text('0 comments'),
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
                      print('Pressed comment');
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
