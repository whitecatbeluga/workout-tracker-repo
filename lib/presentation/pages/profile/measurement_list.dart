import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/domain/entities/measurement.dart';

class MeasurementListPage extends StatefulWidget {
  final List<Measurement> measurements;

  const MeasurementListPage({super.key, required this.measurements});

  @override
  MeasurementListPageState createState() => MeasurementListPageState();
}

class MeasurementListPageState extends State<MeasurementListPage> {
  List<Measurement> _sortedMeasurements = [];

  @override
  void initState() {
    super.initState();
    _sortedMeasurements = widget.measurements
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Measurements'),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.sort),
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
                              leading: Icon(Icons.arrow_upward),
                              title: Text('Newest first'),
                              onTap: () {
                                setState(() {
                                  _sortedMeasurements = widget.measurements
                                    ..sort((a, b) => b.date.compareTo(a.date));
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.arrow_downward),
                              title: Text('Oldest first'),
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    color: Colors.grey,
                  ),
                  child: Icon(
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
                    borderRadius: BorderRadius.vertical(
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
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
