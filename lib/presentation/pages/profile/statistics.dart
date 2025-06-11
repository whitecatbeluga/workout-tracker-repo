import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Statistics', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout Frequency Section
            _buildWorkoutFrequencySection(),
            const SizedBox(height: 15),

            // Workout Summary Section
            _buildWorkoutSummarySection(),
            const SizedBox(height: 15),

            // // Volume over time Section
            _buildVolumeOverTimeSection(),
            const SizedBox(height: 15),

            // // Routine usage stats Section
            _buildRoutineUsageStatsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutFrequencySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Workout Frequency',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  const Text(
                    'Filter',
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, color: Colors.teal, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFrequencyCard(
                  'This week',
                  '12',
                  'exercises',
                  3,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFrequencyCard(
                  'This week',
                  '20',
                  'workouts',
                  9,
                  Colors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyCard(
    String period,
    String number,
    String type,
    int change,
    Color changeColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(period, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                type,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: changeColor.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _statIndicator(
                  icon: Icons.arrow_upward,
                  value: change.toString(),
                  color: changeColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSummarySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workout Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Circular Progress Chart
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: 0.6,
                        strokeWidth: 17,
                        backgroundColor: Color(0xFF48A6A7),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF006A71),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow('Total Workouts:', '4 workouts'),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Total Duration:', '6h 24min'),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Total Volume:', '59 kg'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildVolumeOverTimeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Volume over time',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildVolumeCard(
                  'Total Reps',
                  '70',
                  'reps',
                  12,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVolumeCard(
                  'Weight Lifted',
                  '79',
                  'kg',
                  1,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVolumeCard(
                  'Total Sets',
                  '35',
                  'sets',
                  23,
                  Colors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeCard(
    String title,
    String value,
    String unit,
    int change,
    Color changeColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: changeColor.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _statIndicator(
              icon: Icons.arrow_upward,
              value: change.toString(),
              color: changeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statIndicator({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRoutineUsageStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Routine usage stats',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  const Text(
                    'Filter',
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, color: Colors.teal, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Most used routines',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 0.1),
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Routine Name',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Time Used',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Last Used',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Data Rows
          _buildRoutineRow('Push Day', '12', 'Apr 5, 2025'),
          _buildRoutineRow('Pull Day', '10', 'Apr 4, 2025'),
          _buildRoutineRow('Legs & Core', '6', 'Apr 1, 2025'),
          _buildRoutineRow('Mobility Flow', '2', 'Mar 5, 2025'),
        ],
      ),
    );
  }

  Widget _buildRoutineRow(
    String routineName,
    String timeUsed,
    String lastUsed,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              routineName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(timeUsed, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              lastUsed,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
