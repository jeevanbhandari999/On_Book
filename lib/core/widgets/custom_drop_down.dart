import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final String? title;
  final String? hint;
  final Widget? selectedItem;
  final List<DropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? initialValue;
  final String? dropdownHeaderName;
  final bool shouldDivideItems;
  final EdgeInsets? itemPadding;
  final bool isRequired;
  final String? errorText;

  const CustomDropdown({
    super.key,
    this.title,
    this.hint,
    this.selectedItem,
    required this.items,
    this.onChanged,
    this.initialValue,
    this.dropdownHeaderName,
    this.shouldDivideItems = false,
    this.itemPadding,
    this.isRequired = false,
    this.errorText,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  T? _selectedValue;
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant CustomDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setState(() {
        _selectedValue = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title (optional)
        if (widget.title != null && widget.title!.isNotEmpty) ...[
          Text(
            widget.title!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Dropdown button (outlined style)
        GestureDetector(
          onTap: () => _showPopupMenu(context),
          child: Container(
            key: _buttonKey,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.errorText != null
                    ? Colors.red
                    : Colors.grey.shade400,
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _selectedValue == null
                      ? Text(
                          widget.hint ?? 'Select an option',
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.errorText != null
                                ? Colors.red
                                : Colors.grey.shade600,
                          ),
                        )
                      : (widget.selectedItem ??
                            Text(
                              _getDisplayText(_selectedValue),
                              style: const TextStyle(fontSize: 16),
                            )),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: widget.errorText != null
                      ? Colors.red
                      : Colors.grey.shade700,
                  size: 28,
                ),
              ],
            ),
          ),
        ),

        // Error text
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              widget.errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  String _getDisplayText(T? value) {
    for (final item in widget.items) {
      if (item.value == value) {
        // Try to extract text if child is Text
        if (item.child is Text) {
          return (item.child as Text).data ?? value.toString();
        }
        // Fallback: just show value
        return value.toString();
      }
    }
    return value.toString();
  }

  void _showPopupMenu(BuildContext context) {
    final RenderBox? button =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (button == null) return;

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
    final buttonSize = button.size;

    final position = RelativeRect.fromLTRB(
      buttonPosition.dx,
      buttonPosition.dy + buttonSize.height,
      overlay.size.width - (buttonPosition.dx + buttonSize.width),
      0,
    );

    showMenu<T>(
      context: context,
      position: position,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      constraints: BoxConstraints(
        minWidth: buttonSize.width,
        maxWidth: buttonSize.width,
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      items: [
        // Optional header
        if (widget.dropdownHeaderName != null)
          PopupMenuItem<T>(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Text(
                    widget.dropdownHeaderName!,
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  ),
                ),
                const Divider(height: 1),
              ],
            ),
          ),

        // Actual items
        ...widget.items.map((item) {
          return PopupMenuItem<T>(
            value: item.value,
            child: Column(
              children: [
                Padding(
                  padding:
                      widget.itemPadding ??
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: [
                      if (item.icon != null) ...[
                        item.icon!,
                        const SizedBox(width: 12),
                      ],
                      Expanded(child: item.child),
                    ],
                  ),
                ),
                if (widget.shouldDivideItems)
                  const Divider(height: 1, color: Color(0xFFE0E0E0)),
              ],
            ),
          );
        }),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedValue = value;
        });
        widget.onChanged?.call(value);
      }
    });
  }
}

// Helper class (unchanged)
class DropdownItem<T> {
  final T value;
  final Widget child;
  final Widget? icon;

  const DropdownItem({required this.value, required this.child, this.icon});
}
