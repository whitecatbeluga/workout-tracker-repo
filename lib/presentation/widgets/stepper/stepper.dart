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
    this.isLoading = false,
    this.loadingText = 'Processing...',
  });

  final List<StepperStep> steps;
  final Function(int)? onStepChanged;
  final Function()? onCompleted;
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final bool isLoading;
  final String loadingText;

  @override
  State<CustomStepper> createState() => _CustomStepperState();
}

class _CustomStepperState extends State<CustomStepper> {
  int currentStep = 0;
  late ValueNotifier<bool> _validationNotifier;

  @override
  void initState() {
    super.initState();
    _validationNotifier = ValueNotifier<bool>(_isCurrentStepValid());

    // Listen for validation changes periodically
    _startValidationListener();
  }

  @override
  void dispose() {
    _validationNotifier.dispose();
    super.dispose();
  }

  // Check if current step is valid without triggering error messages
  bool _isCurrentStepValid() {
    if (widget.steps[currentStep].validator != null) {
      return widget.steps[currentStep].validator!();
    }
    return true; // If no validator, consider it valid
  }

  // Start periodic validation checking
  void _startValidationListener() {
    // Check validation every 500ms
    Future.doWhile(() async {
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          final isValid = _isCurrentStepValid();
          if (_validationNotifier.value != isValid) {
            _validationNotifier.value = isValid;
          }
        }
        return mounted;
      }
      return false;
    });
  }

  // Method to trigger validation and show error messages (for button press)
  bool _validateAndShowErrors() {
    if (widget.steps[currentStep].validator != null) {
      return widget.steps[currentStep].validator!();
    }
    return true;
  }

  void _nextStep() {
    // Validate and show errors when user tries to proceed
    if (!_validateAndShowErrors()) {
      return;
    }

    if (currentStep < widget.steps.length - 1) {
      setState(() {
        currentStep++;
      });
      _validationNotifier.value = _isCurrentStepValid();
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
      _validationNotifier.value = _isCurrentStepValid();
      widget.onStepChanged?.call(currentStep);
    }
  }

  // Method to manually trigger validation check (can be called from outside)
  void validateCurrentStep() {
    if (mounted) {
      _validationNotifier.value = _isCurrentStepValid();
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

        // ElevatedButton(
        //   onPressed: _isLoading ? null : _register,
        //   child: _isLoading
        //       ? const CircularProgressIndicator(color: Colors.white)
        //       : const Text('REGISTER'),
        // ),

        // Next/Complete Button with dynamic validation
        ValueListenableBuilder<bool>(
          valueListenable: _validationNotifier,
          builder: (context, isValid, child) {
            return ElevatedButton(
              onPressed: isValid && !widget.isLoading ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isValid
                    ? widget.primaryColor
                    : Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                spacing: widget.isLoading ? 8 : 0,
                children: [
                  widget.isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: isValid && !widget.isLoading
                                ? Colors.white
                                : Colors.grey.shade600,
                            strokeWidth: 2,
                          ),
                        )
                      : const SizedBox(),
                  Text(
                    currentStep == widget.steps.length - 1
                        ? 'Complete'
                        : 'Next',
                    style: TextStyle(
                      color: isValid && !widget.isLoading
                          ? Colors.white
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
