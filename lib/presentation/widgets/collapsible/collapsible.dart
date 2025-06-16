import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/widgets/buttons/button.dart';
import '../../domain/entities/program.dart';

class Collapsible extends StatefulWidget {
  const Collapsible({super.key, required this.title, required this.program});

  final String title;
  final ProgramState program;

  @override
  State<Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<Collapsible> {
  bool _isExpanded = true;

  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _toggleExpand,
                  child: Row(
                    spacing: 6,
                    children: [
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 30,
                        color: Color(0xFF323232),
                      ),
                      Text(widget.title, style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                child: Icon(
                  Icons.edit_note,
                  size: 30,
                  color: Color(0xFF323232),
                ),
                onTap: () {},
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Container(
              margin: const EdgeInsets.only(top: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                border: Border.all(color: Color(0xFFCBD5E1), width: 1.2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14.0),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.program.programs.first.programName ?? "",
                        style: TextStyle(
                          color: Color(0xFF323232),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.more_horiz,
                        size: 30,
                        color: Color(0xFF323232),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      widget.program.programs.length,
                      (index) => Text(
                        widget.program.programs[index].programName ?? "",
                        style: TextStyle(color: Color(0xFF626262)),
                      ),
                    ),
                  ),
                  Button(
                    label: "Start Routine",
                    onPressed: () {},
                    prefixIcon: Icons.play_arrow_rounded,
                    fullWidth: true,
                    size: ButtonSize.large,
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
