import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';

class GraphFilter extends StatelessWidget {
  final String selectedValue;
  final Function(String) onChanged;

  GraphFilter({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  final List<String> items = ['Week', 'Month'];

  @override
  Widget build(BuildContext context) {
    void openFilterDrawer() {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Graph Progress',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Column(
                  spacing: 15,
                  children: [
                    Button(
                      label: 'This Week',
                      onPressed: () {
                        onChanged('Week');
                        Navigator.pop(context);
                      },
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      fullWidth: true,
                      prefixIcon: Icons.calendar_today,
                      textColor: selectedValue == 'Week'
                          ? Colors.white
                          : Color(0xFF48A6A7),
                      backgroundColor: selectedValue == 'Week'
                          ? Color(0xFF006A71)
                          : Colors.white,
                      borderColor: selectedValue == 'Week'
                          ? Colors.white
                          : Color(0xFF006A71),
                      borderWidth: 1,
                      size: ButtonSize.large,
                    ),
                    Button(
                      label: 'By Months',
                      onPressed: () {
                        onChanged('Month');
                        Navigator.pop(context);
                      },
                      fullWidth: true,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      prefixIcon: Icons.calendar_month,
                      textColor: selectedValue == 'Month'
                          ? Colors.white
                          : Color(0xFF48A6A7),
                      backgroundColor: selectedValue == 'Month'
                          ? Color(0xFF006A71)
                          : Colors.white,
                      borderColor: selectedValue == 'Month'
                          ? Colors.white
                          : Color(0xFF006A71),
                      borderWidth: 1,
                      size: ButtonSize.large,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Graph Progress',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        Container(
          width: 114,
          height: 50,
          decoration: BoxDecoration(
            color: const Color.fromARGB(0, 255, 255, 255),
          ),
          child: Button(
            fontSize: 15,
            label: selectedValue,
            onPressed: openFilterDrawer,
            backgroundColor: Colors.white,
            suffixIcon: Icons.arrow_downward,
            textColor: Color(0xFF006A71),
          ),
        ),
      ],
    );
  }
}
