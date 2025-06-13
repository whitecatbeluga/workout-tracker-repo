import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/widgets/inputs/text_field.dart';

enum CustomDatePickerMode { date, dateTime, time, dateRange }

enum DateFormat {
  ddMMyyyy, // 15/03/2024
  mmDDyyyy, // 03/15/2024
  yyyyMMdd, // 2024-03-15
  monthDayYear, // March 15, 2024
  dayMonthYear, // 15 March 2024
  custom,
}

class DatePickerConfig {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final CustomDatePickerMode mode;
  final DateFormat dateFormat;
  final String? customDateFormat;
  final bool showClearButton;
  final bool use24HourFormat;
  final List<DateTime>? selectableDays;
  final List<DateTime>? disabledDates;
  final Color? primaryColor;
  final Color? backgroundColor;
  final TextStyle? headerTextStyle;
  final TextStyle? dayTextStyle;

  const DatePickerConfig({
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.mode = CustomDatePickerMode.date,
    this.dateFormat = DateFormat.ddMMyyyy,
    this.customDateFormat,
    this.showClearButton = true,
    this.use24HourFormat = true,
    this.selectableDays,
    this.disabledDates,
    this.primaryColor,
    this.backgroundColor,
    this.headerTextStyle,
    this.dayTextStyle,
  });
}

class CustomDatePicker extends StatefulWidget {
  const CustomDatePicker({
    super.key,
    required this.label,
    this.prefixIcon,
    this.validator,
    this.variant = InputVariant.outline,
    this.helperText,
    this.placeholder,
    this.config = const DatePickerConfig(),
    this.onDateSelected,
    this.onDateRangeSelected,
    this.selectedDate,
    this.selectedDateRange,
    this.enableLiveValidation = false,
    this.autoValidateMode,
  });

  final String label;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final InputVariant variant;
  final String? helperText;
  final String? placeholder;
  final DatePickerConfig config;
  final Function(DateTime?)? onDateSelected;
  final Function(DateTimeRange?)? onDateRangeSelected;
  final DateTime? selectedDate;
  final DateTimeRange? selectedDateRange;
  final bool enableLiveValidation;
  final AutovalidateMode? autoValidateMode;

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late TextEditingController _controller;
  DateTime? _selectedDate;
  DateTimeRange? _selectedDateRange;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? widget.config.initialDate;
    _selectedDateRange = widget.selectedDateRange;
    _controller = TextEditingController(text: _getDisplayText());
  }

  @override
  void didUpdateWidget(CustomDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate ||
        widget.selectedDateRange != oldWidget.selectedDateRange) {
      _selectedDate = widget.selectedDate;
      _selectedDateRange = widget.selectedDateRange;
      _controller.text = _getDisplayText();
    }
  }

  String _getDisplayText() {
    if (widget.config.mode == CustomDatePickerMode.dateRange) {
      if (_selectedDateRange != null) {
        final startDate = _formatDate(_selectedDateRange!.start);
        final endDate = _formatDate(_selectedDateRange!.end);
        return '$startDate - $endDate';
      }
    } else if (widget.config.mode == CustomDatePickerMode.time) {
      if (_selectedTime != null) {
        return _formatTime(_selectedTime!);
      }
    } else if (widget.config.mode == CustomDatePickerMode.dateTime) {
      if (_selectedDate != null && _selectedTime != null) {
        final dateStr = _formatDate(_selectedDate!);
        final timeStr = _formatTime(_selectedTime!);
        return '$dateStr $timeStr';
      } else if (_selectedDate != null) {
        return _formatDate(_selectedDate!);
      }
    } else {
      if (_selectedDate != null) {
        return _formatDate(_selectedDate!);
      }
    }
    return widget.placeholder ?? '';
  }

  String _formatDate(DateTime date) {
    // Default to monthDayYear format (January 3, 2000)
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    if (widget.config.use24HourFormat) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  bool _isDateDisabled(DateTime date) {
    if (widget.config.disabledDates != null) {
      return widget.config.disabledDates!.any(
        (disabledDate) =>
            date.year == disabledDate.year &&
            date.month == disabledDate.month &&
            date.day == disabledDate.day,
      );
    }

    if (widget.config.selectableDays != null) {
      return !widget.config.selectableDays!.any(
        (selectableDate) =>
            date.year == selectableDate.year &&
            date.month == selectableDate.month &&
            date.day == selectableDate.day,
      );
    }

    return false;
  }

  Future<void> _showDatePicker() async {
    final primaryColor = widget.config.primaryColor ?? const Color(0xFF006A71);

    switch (widget.config.mode) {
      case CustomDatePickerMode.date:
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: widget.config.firstDate ?? DateTime(1900),
          lastDate: widget.config.lastDate ?? DateTime(2100),
          selectableDayPredicate:
              widget.config.disabledDates != null ||
                  widget.config.selectableDays != null
              ? (date) => !_isDateDisabled(date)
              : null,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: primaryColor,
                  surface: widget.config.backgroundColor ?? Colors.white,
                ),
                textTheme: Theme.of(context).textTheme.copyWith(
                  headlineSmall: widget.config.headerTextStyle,
                  bodyMedium: widget.config.dayTextStyle,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          setState(() {
            _selectedDate = picked;
            _controller.text = _getDisplayText();
          });
          widget.onDateSelected?.call(picked);
        }
        break;

      case CustomDatePickerMode.dateTime:
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: widget.config.firstDate ?? DateTime(1900),
          lastDate: widget.config.lastDate ?? DateTime(2100),
          selectableDayPredicate:
              widget.config.disabledDates != null ||
                  widget.config.selectableDays != null
              ? (date) => !_isDateDisabled(date)
              : null,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: primaryColor,
                  surface: widget.config.backgroundColor ?? Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null && mounted) {
          final pickedTime = await showTimePicker(
            context: context,
            initialTime: _selectedTime ?? TimeOfDay.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(
                    context,
                  ).colorScheme.copyWith(primary: primaryColor),
                ),
                child: child!,
              );
            },
          );

          if (pickedTime != null) {
            setState(() {
              _selectedDate = pickedDate;
              _selectedTime = pickedTime;
              _controller.text = _getDisplayText();
            });

            final dateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            widget.onDateSelected?.call(dateTime);
          }
        }
        break;

      case CustomDatePickerMode.time:
        final picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime ?? TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: primaryColor),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          setState(() {
            _selectedTime = picked;
            _controller.text = _getDisplayText();
          });

          final now = DateTime.now();
          final dateTime = DateTime(
            now.year,
            now.month,
            now.day,
            picked.hour,
            picked.minute,
          );
          widget.onDateSelected?.call(dateTime);
        }
        break;

      case CustomDatePickerMode.dateRange:
        final picked = await showDateRangePicker(
          context: context,
          initialDateRange: _selectedDateRange,
          firstDate: widget.config.firstDate ?? DateTime(1900),
          lastDate: widget.config.lastDate ?? DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: primaryColor,
                  surface: widget.config.backgroundColor ?? Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          setState(() {
            _selectedDateRange = picked;
            _controller.text = _getDisplayText();
          });
          widget.onDateRangeSelected?.call(picked);
        }
        break;
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedDate = null;
      _selectedDateRange = null;
      _selectedTime = null;
      _controller.text = '';
    });

    if (widget.config.mode == CustomDatePickerMode.dateRange) {
      widget.onDateRangeSelected?.call(null);
    } else {
      widget.onDateSelected?.call(null);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = _controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: _showDatePicker,
              child: AbsorbPointer(
                child: InputField(
                  label: widget.label,
                  prefixIcon: widget.prefixIcon ?? _getDefaultIcon(),
                  suffixIcon: hasValue && widget.config.showClearButton
                      ? null
                      : Icons.calendar_today,
                  variant: widget.variant,
                  controller: _controller,
                  validator: widget.validator,
                  enableLiveValidation: widget.enableLiveValidation,
                  autoValidateMode: widget.autoValidateMode,
                ),
              ),
            ),
            if (hasValue && widget.config.showClearButton)
              Positioned(
                right: 12,
                top: 14,
                child: GestureDetector(
                  onTap: _clearSelection,
                  child: const Icon(
                    Icons.clear,
                    size: 20,
                    color: Color(0xFF6F7A88),
                  ),
                ),
              ),
          ],
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.helperText!,
              style: const TextStyle(color: Color(0xFF6F7A88), fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  IconData _getDefaultIcon() {
    switch (widget.config.mode) {
      case CustomDatePickerMode.time:
        return Icons.access_time;
      case CustomDatePickerMode.dateTime:
        return Icons.event_available;
      case CustomDatePickerMode.dateRange:
        return Icons.date_range;
      default:
        return Icons.calendar_today;
    }
  }
}
