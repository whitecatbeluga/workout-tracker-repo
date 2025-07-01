import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/core/providers/auth_service_provider.dart';
import 'package:workout_tracker_repo/data/repositories_impl/measurement_repository_impl.dart';
import 'package:workout_tracker_repo/data/services/measurement_service.dart';
import 'package:workout_tracker_repo/domain/entities/measurement.dart';
import 'package:workout_tracker_repo/presentation/pages/profile/measurement_list.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import 'package:workout_tracker_repo/presentation/widgets/card/measurement_image_card.dart';
import 'package:workout_tracker_repo/presentation/widgets/charts/linechart.dart';
import 'package:intl/intl.dart';
import 'package:workout_tracker_repo/routes/profile/profile.dart';

class MeasurementPage extends StatefulWidget {
  const MeasurementPage({super.key});

  @override
  State<MeasurementPage> createState() => _MeasurementPageState();
}

class _MeasurementPageState extends State<MeasurementPage> {
  final user = authService.value.getCurrentUser();
  final measurementrepo = MeasurementRepositoryImpl(MeasurementService());
  List<Measurement> measurements = [];
  List<Measurement> filteredMeasurements = []; // Add this line
  bool isWeight = false;
  late Stream<List<Measurement>> measurementStream;
  String selectedFilter = 'All time';
  DateTime? latestLog;

  @override
  void initState() {
    super.initState();
    measurementStream = measurementrepo.fetchMeasurements(user!.uid);
  }

  // Move filter logic to a separate method
  List<Measurement> _applyFilter(List<Measurement> allMeasurements) {
    latestLog = allMeasurements.isNotEmpty
        ? allMeasurements.reversed.first.date
        : null;
    if (selectedFilter == 'Last 3 months') {
      return allMeasurements
          .where(
            (element) => element.date.isAfter(
              DateTime.now().subtract(const Duration(days: 90)),
            ),
          )
          .toList();
    } else if (selectedFilter == 'Year') {
      return allMeasurements
          .where((element) => element.date.year == DateTime.now().year)
          .toList();
    }
    return allMeasurements; // 'All time' - return all measurements
  }

  void _showFilterDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _FilterDrawer(
          onSelect: (filter) {
            setState(() {
              selectedFilter = filter;
              // Apply filter immediately when selection changes
              filteredMeasurements = _applyFilter(measurements);
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Measurements'),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: Navigator.canPop(context)
              ? () => Navigator.pop(context)
              : () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: StreamBuilder<List<Measurement>>(
        stream: measurementStream,
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Fetching Measurements...'),
                ],
              ),
            );
          }

          // Handle error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        measurementStream = measurementrepo.fetchMeasurements(
                          user!.uid,
                        );
                      });
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Handle case where there's no data yet
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No measurements found'),
                ],
              ),
            );
          }

          // Update measurements and apply current filter
          measurements = snapshot.data!;
          if (measurements.length == 1) {
            return Center(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hourglass_empty_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'You have only one measurement recorded, \nplease add more measurements to see improvements',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          filteredMeasurements = _applyFilter(measurements);

          // Handle empty list
          if (measurements.isEmpty) {
            return Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.scale, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No measurements recorded yet'),
                    SizedBox(height: 8),
                    Text('Tap "Log Measurements" to get started'),
                  ],
                ),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: double.infinity,
            color: Color(0xFFFFFFFF),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress Images',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MeasurementListPage(
                                      measurements: measurements,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'See All',
                                style: TextStyle(
                                  color: Color(0xFF006A71),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: measurements.isEmpty
                              ? const Center(
                                  child: Text('No measurements found'),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MeasurementListPage(
                                              measurements: measurements,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    spacing: 10,
                                    children: [
                                      ...measurements.map(
                                        (measurement) => MeasurementImageCard(
                                          imageUrl: measurement.imageUrl ?? '',
                                          date: measurement.date,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      bottom: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filter',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              selectedFilter,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF505050),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _showFilterDrawer(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF006A71),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Change",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.tune,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: LinechartWidget(
                      showWeight: isWeight,
                      measurements: filteredMeasurements, // Use filtered data
                    ),
                  ),
                  Row(
                    spacing: 20,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomTextButton(
                        text: 'Weight',
                        activeColor: Color(0xFF006A71),
                        inactiveColor: Color.fromARGB(255, 240, 240, 240),
                        activeTextColor: Colors.white,
                        inactiveTextColor: Colors.black,
                        isActive: isWeight,
                        onPressed: () {
                          setState(() {
                            isWeight = true;
                          });
                        },
                      ),
                      CustomTextButton(
                        text: 'Height',
                        activeColor: Color(0xFF006A71),
                        inactiveColor: Color.fromARGB(255, 240, 240, 240),
                        activeTextColor: Colors.white,
                        inactiveTextColor: Colors.black,
                        isActive: !isWeight,
                        onPressed: () {
                          setState(() {
                            isWeight = false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "${isWeight ? "Weight" : "Height"} History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF505050),
                    ),
                  ),
                  Column(
                    spacing: 8,
                    children: [
                      // Use filtered data here too
                      for (var measurement in filteredMeasurements.reversed)
                        HistoryTile(
                          date: DateFormat(
                            'MMM dd, yyyy',
                          ).format(measurement.date),
                          hw: isWeight
                              ? '${measurement.weight} kg'
                              : '${measurement.height} cm',
                          isWeight: isWeight,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Center(
          child: Button(
            label: 'Log Measurements',
            onPressed: () {
              print('\x1B[2J\x1B[1;1H');
              final sortedMeasurements = measurements
                ..sort((a, b) => b.date.compareTo(a.date));
              if (sortedMeasurements.isEmpty) {
                Navigator.pushNamed(context, ProfileRoutes.addMeasurement);
                return;
              }

              if (sortedMeasurements.first.date.month == DateTime.now().month) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'You have already logged measurement for this month. For better results, log once a month.',
                      textAlign: TextAlign.center,
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                Navigator.pushNamed(context, ProfileRoutes.addMeasurement);
              }
            },
            prefixIcon: Icons.add,
            size: ButtonSize.large,
            fullWidth: true,
          ),
        ),
      ),
    );
  }
}

class _FilterDrawer extends StatelessWidget {
  final Function(String) onSelect;
  // Remove filterList parameter - no longer needed
  const _FilterDrawer({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {'label': 'Last 3 months', 'icon': Icons.calendar_today},
      {'label': 'Year', 'icon': Icons.event},
      {'label': 'All time', 'icon': Icons.timeline},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Row(
            children: [
              const Text(
                'Select Filter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...options.map((option) {
            return Button(
              fullWidth: true,
              label: option['label'],
              prefixIcon: option['icon'],
              onPressed: () => onSelect(option['label']),
            );
          }),
        ],
      ),
    );
  }
}

class HistoryTile extends StatelessWidget {
  final String date;
  final String hw;
  final bool isWeight;
  const HistoryTile({
    super.key,
    required this.date,
    required this.hw,
    required this.isWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color.fromARGB(255, 202, 202, 202),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(date), Text(hw)],
      ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final String text;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeTextColor;
  final Color inactiveTextColor;
  final bool isActive;
  final VoidCallback onPressed;

  const CustomTextButton({
    super.key,
    required this.text,
    required this.activeColor,
    required this.inactiveColor,
    required this.activeTextColor,
    required this.inactiveTextColor,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            isActive ? activeColor : inactiveColor,
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? activeTextColor : inactiveTextColor,
          ),
        ),
      ),
    );
  }
}
