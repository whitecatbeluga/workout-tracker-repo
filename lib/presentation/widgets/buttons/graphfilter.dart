import 'package:flutter/material.dart';

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

          child: DropdownMenu<String>(
            initialSelection: selectedValue,
            onSelected: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            dropdownMenuEntries: items.map((value) {
              return DropdownMenuEntry<String>(
                style: ButtonStyle(),
                value: value,
                label: value,
                labelWidget: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          color: Color(0xFF006A71),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (value == selectedValue)
                        const Icon(
                          Icons.check,
                          color: Color(0xFF006A71),
                          size: 16,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
            menuStyle: MenuStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              elevation: WidgetStateProperty.all(8),
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
            ),
            textStyle: const TextStyle(
              color: Color(0xFF006A71),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            trailingIcon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF006A71),
              size: 20,
            ),
            selectedTrailingIcon: const Icon(
              Icons.keyboard_arrow_up,
              color: Color(0xFF006A71),
              size: 20,
            ),
            inputDecorationTheme: const InputDecorationTheme(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              filled: false,
            ),
          ),
        ),
      ],
    );
  }
}
