import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/core/providers/user_info_provider.dart';
import 'package:workout_tracker_repo/domain/entities/user_profile.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/profile-menu.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/menu_list.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/routes/profile/profile.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final user = authService.value.getCurrentUser();
  final List<MenuItem> menuItems = const [
    MenuItem(
      title: "Account Details",
      icon: Icons.account_circle_rounded,
      route: ProfileRoutes.accountDetails,
    ),
    MenuItem(
        title: "Contact Us",
        icon: Icons.call,
        route:ProfileRoutes.contactUs
    ),
    MenuItem(
      title: "Terms and Service",
      icon: Icons.info,
      route: ProfileRoutes.termsOfService,
    ),
    MenuItem(
      title: "About Us",
      icon: Icons.supervisor_account_rounded,
      route: ProfileRoutes.aboutUs,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Settings'),
        leading: BackButton(
          onPressed: Navigator.canPop(context)
              ? () => Navigator.pop(context)
              : () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
        ),
      ),
      body: Center(
        child: Column(
          spacing: 20,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    ProfileRoutes.editAccount,
                    (route) => false,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                              ? profile!.userName[0]
                                                    .toUpperCase()
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
                                    if (profile == null)
                                      return CircularProgressIndicator();
                                    return Text(
                                      '${profile.firstName} ${profile.lastName}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    );
                                  },
                                ),
                                Text(
                                  user?.email ?? "",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right, size: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text("Other Settings", style: TextStyle(fontSize: 16)),
                ),
                MenuList(menuItems: menuItems),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Button(
                      label: "Logout",
                      onPressed: () async {
                        await authService.value.signOut();
                        // Navigate to login and remove all previous routes
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      variant: ButtonVariant.danger,
                      size: ButtonSize.medium,
                    ),
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
