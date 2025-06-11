import 'package:flutter/material.dart';
import 'package:workout_tracker_repo/presentation/widgets/inputs/text_field.dart';

class DropdownOption {
  final String value;
  final String label;
  final IconData? icon;
  final String? description;

  const DropdownOption({
    required this.value,
    required this.label,
    this.icon,
    this.description,
  });
}

class CustomDropdownField extends StatefulWidget {
  const CustomDropdownField({
    super.key,
    required this.label,
    required this.options,
    this.prefixIcon,
    this.validator,
    this.variant = InputVariant.outline,
    this.isMultiSelect = false,
    this.helperText,
    this.selectedValues,
    this.onChanged,
    this.placeholder,
    this.enableLiveValidation = false,
    this.autoValidateMode,
  });

  final String label;
  final List<DropdownOption> options;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final InputVariant variant;
  final bool isMultiSelect;
  final String? helperText;
  final List<String>? selectedValues;
  final Function(List<String>)? onChanged;
  final String? placeholder;
  final bool enableLiveValidation;
  final AutovalidateMode? autoValidateMode;

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  late List<String> _selectedValues;
  bool _isOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _selectedValues = widget.selectedValues ?? [];
    _controller = TextEditingController(text: _getDisplayText());
  }

  @override
  void didUpdateWidget(CustomDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValues != oldWidget.selectedValues) {
      _selectedValues = widget.selectedValues ?? [];
      _controller.text = _getDisplayText();
    }
  }

  String _getDisplayText() {
    if (_selectedValues.isEmpty) {
      return widget.placeholder ?? '';
    }

    if (widget.isMultiSelect) {
      if (_selectedValues.length == 1) {
        final option = widget.options.firstWhere(
          (opt) => opt.value == _selectedValues.first,
          orElse: () => DropdownOption(value: '', label: ''),
        );
        return option.label;
      } else {
        return '${_selectedValues.length} selected';
      }
    } else {
      final option = widget.options.firstWhere(
        (opt) => opt.value == _selectedValues.first,
        orElse: () => DropdownOption(value: '', label: ''),
      );
      return option.label;
    }
  }

  void _toggleDropdown() {
    if (!mounted) return;

    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (!mounted) return;

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);

    if (mounted) {
      setState(() {
        _isOpen = true;
      });
    }
  }

  void _closeDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  void _closeDropdownSilently() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _isOpen = false;
  }

  void _refreshOverlay() {
    if (_overlayEntry != null && _isOpen) {
      _overlayEntry!.remove();
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeDropdown,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 4,
              width: size.width,
              child: GestureDetector(
                onTap: () {}, // Prevent closing when tapping inside dropdown
                child: Material(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFCBD5E1),
                        width: 1,
                      ),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: widget.options.length,
                      itemBuilder: (context, index) {
                        final option = widget.options[index];
                        final isSelected = _selectedValues.contains(
                          option.value,
                        );

                        return InkWell(
                          onTap: () => _selectOption(option.value),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                if (widget.isMultiSelect) ...[
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF006A71)
                                            : const Color(0xFFCBD5E1),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                      color: isSelected
                                          ? const Color(0xFF006A71)
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 12,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                if (option.icon != null) ...[
                                  Icon(
                                    option.icon,
                                    size: 20,
                                    color: const Color(0xFF6F7A88),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option.label,
                                        style: TextStyle(
                                          color:
                                              isSelected &&
                                                  !widget.isMultiSelect
                                              ? const Color(0xFF006A71)
                                              : const Color(0xFF1F2937),
                                          fontSize: 15,
                                          fontWeight:
                                              isSelected &&
                                                  !widget.isMultiSelect
                                              ? FontWeight.w500
                                              : FontWeight.w400,
                                        ),
                                      ),
                                      if (option.description != null)
                                        Text(
                                          option.description!,
                                          style: const TextStyle(
                                            color: Color(0xFF6F7A88),
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (!widget.isMultiSelect && isSelected)
                                  const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Color(0xFF006A71),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectOption(String value) {
    if (!mounted) return;

    List<String> newSelectedValues;

    if (widget.isMultiSelect) {
      newSelectedValues = List.from(_selectedValues);
      if (newSelectedValues.contains(value)) {
        newSelectedValues.remove(value);
      } else {
        newSelectedValues.add(value);
      }

      // Update state and refresh overlay for multi-select
      _selectedValues = newSelectedValues;
      _controller.text = _getDisplayText();

      if (mounted) {
        setState(() {});
      }

      // Refresh the overlay to show updated checkbox states
      _refreshOverlay();
    } else {
      newSelectedValues = [value];
      _selectedValues = newSelectedValues;
      _controller.text = _getDisplayText();

      if (mounted) {
        setState(() {});
      }

      _closeDropdown();
    }

    widget.onChanged?.call(newSelectedValues);
  }

  @override
  void dispose() {
    _closeDropdownSilently();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _toggleDropdown,
            child: AbsorbPointer(
              child: InputField(
                label: widget.label,
                prefixIcon: widget.prefixIcon,
                suffixIcon: _isOpen
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                variant: widget.variant,
                controller: _controller,
                validator: widget.validator != null
                    ? (value) => widget.validator!(
                        _controller.text.isEmpty ? null : _controller.text,
                      )
                    : null,
                enableLiveValidation: widget.enableLiveValidation,
                autoValidateMode: widget.autoValidateMode,
              ),
            ),
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
      ),
    );
  }
}
