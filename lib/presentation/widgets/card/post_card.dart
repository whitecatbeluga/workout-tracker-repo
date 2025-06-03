import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.name,
    required this.email,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                    padding: EdgeInsets.all(0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(0),
                          child: Row(
                            spacing: 10,
                            children: [
                              Container(
                                padding: EdgeInsets.all(0),
                                child: CircleAvatar(
                                  backgroundImage: AssetImage(
                                    'assets/images/guy1.png',
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Text(
                                      '2 hours ago',
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
                        Container(
                          padding: EdgeInsets.all(0),
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
                    padding: EdgeInsets.all(0),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Leg Day!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text('No skip leg day.'),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(0),
                    child: Row(
                      spacing: 50,
                      children: [
                        Container(
                          padding: EdgeInsets.all(0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Text('Time'), Text('42 min')],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Text('Volume'), Text('3,780 kg')],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(0),
              child: Image.asset('assets/images/legday.png'),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(0),
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
