import 'package:flutter/material.dart';

class WorkoutCard extends StatelessWidget {
  final String title;
  final String time;
  final String volume;
  final String sets;
  final String description;
  final String reminderText;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final double? elevation;

  const WorkoutCard({
    super.key,
    required this.title,
    required this.time,
    required this.volume,
    required this.sets,
    required this.description,
    required this.reminderText,
    this.onTap,
    this.margin,
    this.elevation = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 5),

                // Stats Row
                Row(
                  children: [
                    // Time Column
                    Expanded(
                      child: _buildStatColumn(label: 'Time', value: time),
                    ),

                    // Volume Column
                    Expanded(
                      child: _buildStatColumn(label: 'Volume', value: volume),
                    ),

                    // Sets Column
                    Expanded(
                      child: _buildStatColumn(label: 'Sets', value: sets),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Reminder with icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.access_time_filled,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      reminderText,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}
