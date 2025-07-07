import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_tracker_repo/domain/entities/measurement.dart';
import 'package:workout_tracker_repo/presentation/pages/profile/measurements/comparison.dart';

class MeasurementListPage extends StatefulWidget {
  final List<Measurement> measurements;

  const MeasurementListPage({super.key, required this.measurements});

  @override
  MeasurementListPageState createState() => MeasurementListPageState();
}

class MeasurementListPageState extends State<MeasurementListPage> {
  List<Measurement> _sortedMeasurements = [];
  Measurement? _beforeMeasurement;
  Measurement? _afterMeasurement;

  @override
  void initState() {
    super.initState();
    _sortedMeasurements = widget.measurements
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void _showComparisonDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Generate Before and After',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Measurement>(
                    value: _beforeMeasurement,
                    hint: const Text('Select BEFORE month'),
                    items: _sortedMeasurements
                        .where(
                          (m) => m.imageUrl != null && m.imageUrl!.isNotEmpty,
                        )
                        .where((m) => m != _sortedMeasurements.first)
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(DateFormat('MMMM yyyy').format(m.date)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _beforeMeasurement = value);
                      setModalState(() => _afterMeasurement = null);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Measurement>(
                    value: _afterMeasurement,
                    hint: const Text('Select AFTER month'),
                    items: _sortedMeasurements
                        .where(
                          (m) => m.imageUrl != null && m.imageUrl!.isNotEmpty,
                        )
                        .where(
                          (m) =>
                              _beforeMeasurement == null ||
                              m.date.isAfter(_beforeMeasurement!.date),
                        )
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(DateFormat('MMMM yyyy').format(m.date)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setModalState(() => _afterMeasurement = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.compare_arrows,
                      color: Color(0xFF006A71),
                    ),
                    label: const Text(
                      'Generate Image',
                      style: TextStyle(fontSize: 16, color: Color(0xFF006A71)),
                    ),
                    onPressed:
                        _beforeMeasurement != null && _afterMeasurement != null
                        ? () => _navigateToComparisonPage(
                            _beforeMeasurement!,
                            _afterMeasurement!,
                          )
                        : null,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToComparisonPage(Measurement before, Measurement after) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComparisonImagePage(before: before, after: after),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Measurements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _showComparisonDrawer,
          ),
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.sort),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.arrow_upward),
                              title: const Text('Newest first'),
                              onTap: () {
                                setState(() {
                                  _sortedMeasurements = widget.measurements
                                    ..sort((a, b) => b.date.compareTo(a.date));
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.arrow_downward),
                              title: const Text('Oldest first'),
                              onTap: () {
                                setState(() {
                                  _sortedMeasurements = widget.measurements
                                    ..sort((a, b) => a.date.compareTo(b.date));
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _sortedMeasurements.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
            child: MeasurementCard(
              imageUrl: _sortedMeasurements[index].imageUrl ?? '',
              weight: _sortedMeasurements[index].weight,
              height: _sortedMeasurements[index].height,
              date: _sortedMeasurements[index].date,
            ),
          );
        },
      ),
    );
  }
}

class MeasurementCard extends StatelessWidget {
  final String imageUrl;
  final double weight;
  final double height;
  final DateTime date;

  const MeasurementCard({
    super.key,
    required this.imageUrl,
    required this.weight,
    required this.height,
    required this.date,
  });

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageUrl.isEmpty
              ? Container(
                  height: 100,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    color: Colors.grey,
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Color(0xFF505050),
                    size: 100,
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(child: Image.network(imageUrl));
                      },
                    );
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      imageUrl,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${date.day} ${_getMonthName(date.month)} ${date.year}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Weight: $weight kg",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                Text(
                  "Height: $height cm",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
