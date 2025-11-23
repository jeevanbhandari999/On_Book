import 'package:flutter/material.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/utils/extensions/extensions.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool enabled;
  final String? errorText;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: UiConstants.spacingSm),
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),

            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonStyle? style;
  final Widget? icon;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.style,
    this.icon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;

    if (isOutlined) {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: _buildButtonChild(),
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: _buildButtonChild(),
      );
    }

    return button;
  }

  Widget _buildButtonChild() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: UiConstants.spacingSm),
          Text(
            text,
            style: const TextStyle(fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return Text(text, overflow: TextOverflow.ellipsis);
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool isDismissible;
  final bool enableDrag;

  const CustomBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.isDismissible = true,
    this.enableDrag = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(UiConstants.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (enableDrag) ...[
            const SizedBox(height: UiConstants.spacingSm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
          if (title != null) ...[
            const SizedBox(height: UiConstants.spacingMd),
            Text(title!, style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
          ],
          Flexible(child: child),
          SizedBox(height: context.bottomPadding + UiConstants.spacingMd),
        ],
      ),
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomBottomSheet(
        title: title,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        child: child,
      ),
    );
  }
}

/// A reusable container for app sections with consistent styling.
///
/// Applies surface background, rounded corners, subtle shadow,
/// and sensible default padding and margin.
///
/// Usage examples:
/// ```dart
/// // Basic usage
/// SectionContainer(
///   child: Text('Content'),
/// )
///
/// // With tap functionality
/// SectionContainer(
///   onTap: () => print('Tapped'),
///   child: Text('Tappable content'),
/// )
///
/// // Custom styling
/// SectionContainer(
///   padding: EdgeInsets.all(16),
///   margin: EdgeInsets.symmetric(horizontal: 8),
///   backgroundColor: Colors.blue,
///   child: Text('Custom styled content'),
/// )
/// ```
class SectionContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final BorderRadius? inkWellBorderRadius;

  const SectionContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.shadows,
    this.onTap,
    this.inkWellBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final container = Container(
      margin:
          margin ??
          const EdgeInsets.symmetric(
            horizontal: UiConstants.spacingMd,
            vertical: UiConstants.spacingSm,
          ),
      padding: padding ?? const EdgeInsets.all(UiConstants.spacingMd),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius:
            borderRadius ?? BorderRadius.circular(UiConstants.radiusLg),
        boxShadow:
            shadows ??
            [
              BoxShadow(
                color: const Color(0xFF363535).withAlpha(40),
                spreadRadius: 0,
                blurRadius: 16,
                offset: const Offset(0, 0),
              ),
            ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius:
            inkWellBorderRadius ?? BorderRadius.circular(UiConstants.radiusLg),
        child: container,
      );
    }

    return container;
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? errorText;
  final Widget? prefixIcon;

  const CustomDropdown({
    super.key,
    required this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.errorText,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          hint: hint != null
              ? Text(hint!, style: const TextStyle(color: Colors.grey))
              : null,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            errorText: errorText,
            prefixIcon: prefixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
      ],
    );
  }
}

class CustomMultiSelect<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final List<T> selected;
  final String Function(T) itemLabel;
  final ValueChanged<List<T>>? onChanged;
  final Widget? prefixIcon;
  final bool readOnly;

  const CustomMultiSelect({
    super.key,
    required this.label,
    required this.items,
    required this.selected,
    required this.itemLabel,
    this.onChanged,
    this.prefixIcon,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        Wrap(
          spacing: 8,
          children: items.map((item) {
            final isSelected = selected.contains(item);
            return FilterChip(
              label: Text(itemLabel(item)),
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              selected: isSelected,
              onSelected: readOnly
                  ? null
                  : (bool selected) {
                      final newSelected = List<T>.from(this.selected);
                      if (selected) {
                        newSelected.add(item);
                      } else {
                        newSelected.remove(item);
                      }
                      onChanged?.call(newSelected);
                    },
              selectedColor: Theme.of(context).primaryColor.withAlpha(50),
              checkmarkColor: Theme.of(context).primaryColor,
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
