import 'package:flutter/material.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    ).animate().fadeIn(delay: 300.ms).moveY(begin: 20, end: 0);
  }
}

class CustomButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonStyle? style;
  final Widget? icon;
  final bool isOutlined;
  final Color? textColor;

  const CustomButton({
    super.key,
    this.text,
    this.onPressed,
    this.isLoading = false,
    this.style,
    this.icon,
    this.isOutlined = false,
    this.textColor,
  }) : assert(
         text != null || icon != null,
         'Either text or icon must be provided',
       );

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

    return button.animate().scale(duration: 200.ms, curve: Curves.easeOut);
  }

  Widget _buildButtonChild() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
      );
    }

    if (icon != null && text != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: UiConstants.spacingSm),
          Flexible(
            child: Text(
              text!,
              style: TextStyle(color: textColor ?? Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    if (icon != null) return icon!;
    if (text != null) {
      return Text(
        text!,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: textColor ?? Colors.black),
      );
    }

    return const SizedBox.shrink();
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
          Stack(
            alignment: Alignment.center,
            children: [
              // Drag handle (centered)
              if (enableDrag)
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

              // Close icon (top-right)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              if (title != null)
                Positioned(
                  left: 56, // enough space for the close button
                  right: 56,
                  child: Text(
                    title!,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          if (title != null) ...[
            Text(title!, style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
          ],
          Flexible(child: child),
          // SizedBox(height: context.bottomPadding + UiConstants.spacingMd),
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

class SectionContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final BorderRadius? inkWellBorderRadius;
  final LinearGradient? gradientColor;
  final BoxDecoration? decoration;

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
    this.gradientColor,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      margin: margin,

      padding: padding ?? const EdgeInsets.all(UiConstants.spacingMd),
      decoration:
          decoration ??
          BoxDecoration(
            borderRadius:
                borderRadius ?? BorderRadius.circular(UiConstants.radiusXl),
            gradient:
                gradientColor ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withAlpha(90),
                    Colors.white.withAlpha(40),
                  ],
                ),
            color: backgroundColor,
            boxShadow:
                shadows ??
                [
                  BoxShadow(
                    color: Colors.black.withAlpha(22),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
            border: Border.all(color: Colors.black.withAlpha(80), width: 1.2),
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

    return container.animate().fadeIn(delay: 300.ms).moveY(begin: 20, end: 0);
  }
}

class CustomMultiSelect<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final List<T> selected;
  final String Function(T) itemLabel;
  final Widget Function(T item, bool isSelected)? itemBuilder;
  final ValueChanged<List<T>>? onChanged;
  final bool readOnly;
  final double fontSize;

  const CustomMultiSelect({
    super.key,
    required this.label,
    required this.items,
    required this.selected,
    required this.itemLabel,
    this.itemBuilder,
    this.onChanged,
    this.readOnly = false,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
        ),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: UiConstants.spacingXs,
            crossAxisSpacing: UiConstants.spacingMd,
            childAspectRatio: 4,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = selected.contains(item);
            final isEven = index.isEven;

            return FilterChip(
                  showCheckmark: false,
                  label: itemBuilder != null
                      ? itemBuilder!(item, isSelected)
                      : Text(itemLabel(item)),
                  selected: isSelected,
                  onSelected: readOnly
                      ? (bool selected) {
                          // Do nothing when readOnly, but still allow visual feedback
                        }
                      : (bool selected) {
                          final newSelected = List<T>.from(this.selected);
                          if (selected) {
                            newSelected.add(item);
                          } else {
                            newSelected.remove(item);
                          }
                          onChanged?.call(newSelected);
                        },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UiConstants.radiusLg),
                  ),
                )
                .animate(delay: (index * 70).ms)
                .scale(duration: 200.ms)
                .slideY(begin: isEven ? 0.3 : -0.3);
          },
        ),
      ],
    );
  }
}
