import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/profile-menu.dart';
import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/menu_list.dart';
import 'package:workout_tracker_repo/presentation/widgets/charts/barchart.dart';
import 'package:workout_tracker_repo/routes/profile/profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = authService.value.getCurrentUser();

  final List<MenuItem> menuItems = const [
    MenuItem(
      title: "Statistics",
      icon: Icons.bar_chart,
      route: ProfileRoutes.statistics,
    ),
    MenuItem(
      title: "Exercises",
      icon: Icons.fitness_center,
      route: "/exercises",
    ),
    MenuItem(
      title: "Measurements",
      icon: Icons.health_and_safety,
      route: "/measurements",
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
        title: const Text('Profile'),
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
            spacing: 26,
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
              Padding(padding: EdgeInsets.all(16.0), child: BarChartWidget()),
              MenuList(menuItems: menuItems),
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
            ClipOval(
              child: SizedBox.fromSize(
                size: Size.fromRadius(22),
                child: Image.asset("assets/images/default.jpg"),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "John Smith Doe",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  "123",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text("Followers", style: TextStyle(fontSize: 14)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "56",
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
