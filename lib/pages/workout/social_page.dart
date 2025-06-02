import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/widgets/post_card.dart';

class ButtonPick extends StatefulWidget {
  const ButtonPick({super.key});

  @override
  State<ButtonPick> createState() => SocialPage();
}

class SocialPage extends State<ButtonPick> {
  bool isFollowingSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
              Text(
                'John Smith Doe',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              print('Search pressed');
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
            Container(
              padding: EdgeInsets.all(0),
              child: PostCard(
                name: 'Philippe',
                email: 'philippetan99@gmail.com',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
