import 'package:flutter/material.dart';

// Step model to define each step's content
class StepperStep {
  final String title;
  final String subtitle;
  final Widget content;
  final bool Function()? validator;

  StepperStep({
    required this.title,
    this.subtitle = '',
    required this.content,
    this.validator,
  });
}

class CustomStepper extends StatefulWidget {
  const CustomStepper({
    super.key,
    required this.steps,
    this.onStepChanged,
    this.onCompleted,
    this.primaryColor = const Color(0xFF0D7377),
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.all(20.0),
  });

  final List<StepperStep> steps;
  final Function(int)? onStepChanged;
  final Function()? onCompleted;
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  State<CustomStepper> createState() => _CustomStepperState();
}

class _CustomStepperState extends State<CustomStepper> {
  int currentStep = 0;

  void _nextStep() {
    // Validate current step if validator exists
    if (widget.steps[currentStep].validator != null) {
      if (!widget.steps[currentStep].validator!()) {
        return; // Don't proceed if validation fails
      }
    }

    if (currentStep < widget.steps.length - 1) {
      setState(() {
        currentStep++;
      });
      widget.onStepChanged?.call(currentStep);
    } else {
      // Last step completed
      widget.onCompleted?.call();
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      widget.onStepChanged?.call(currentStep);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Indicator
          _buildStepIndicator(),
          const SizedBox(height: 32),

          // Step Content
          Expanded(child: widget.steps[currentStep].content),

          const SizedBox(height: 24),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Column(
      children: [
        // Step circles and connecting lines
        Row(
          children: List.generate(widget.steps.length, (index) {
            final isActive = index == currentStep;
            final isCompleted = index < currentStep;

            return Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Step Circle
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? widget.primaryColor
                          : isActive
                          ? Colors.transparent
                          : Colors.grey.shade300,
                      border: isActive
                          ? Border.all(color: widget.primaryColor, width: 2)
                          : null,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(Icons.check, color: Colors.white, size: 20)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive
                                    ? widget.primaryColor
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),

                  // Connector Line (except for last step)
                  // if (index < widget.steps.length - 1)
                  //   Expanded(
                  //     child: Container(
                  //       height: 2,
                  //       color: isCompleted
                  //           ? widget.primaryColor
                  //           : Colors.grey.shade300,
                  //       margin: const EdgeInsets.symmetric(horizontal: 8),
                  //     ),
                  //   ),
                ],
              ),
            );
          }),
        ),

        const SizedBox(height: 12),

        // Step labels
        Row(
          children: List.generate(widget.steps.length, (index) {
            final isActive = index == currentStep;
            final isCompleted = index < currentStep;

            return Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.steps[index].title,
                    style: TextStyle(
                      color: isActive || isCompleted
                          ? widget.primaryColor
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.steps[index].subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        // Previous Button
        if (currentStep > 0)
          OutlinedButton(
            onPressed: _previousStep,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: widget.primaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Previous',
              style: TextStyle(color: widget.primaryColor),
            ),
          ),

        const Spacer(),

        // Next/Complete Button
        ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            currentStep == widget.steps.length - 1 ? 'Complete' : 'Next',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
