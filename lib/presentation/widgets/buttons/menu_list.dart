import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/profile-menu.dart';

class MenuList extends StatelessWidget {
  const MenuList({super.key, this.menuItems = const []});

  final List<MenuItem> menuItems;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: menuItems.map((item) {
        return ListTile(
          leading: Icon(item.icon),
          title: Text(item.title),
          onTap: () => Navigator.pushNamedAndRemoveUntil(
            context,
            item.route,
            (route) => false,
          ),
          trailing: const Icon(Icons.chevron_right),
        );
      }).toList(),
    );
  }
}
