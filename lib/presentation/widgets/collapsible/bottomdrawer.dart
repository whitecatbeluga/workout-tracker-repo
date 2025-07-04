import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/domain/entities/filter_item.dart';

class BottomDrawer extends StatelessWidget {
  const BottomDrawer({super.key, required this.filterItems});
  final List<FilterItem> filterItems;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Choose Filter',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          for (final item in filterItems)
            ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              onTap: () {
                item.onTap();
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}
