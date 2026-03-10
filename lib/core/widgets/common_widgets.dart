import 'package:app/core/widgets/auto_marquee_text.dart';
import 'package:flutter/material.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/utils/extensions/extensions.dart';
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

// class CustomTextField extends StatelessWidget {
//   final String? label;
//   final String? hint;
//   final TextEditingController? controller;
//   final String? Function(String?)? validator;
//   final void Function(String)? onChanged;
//   final void Function(String)? onSubmitted;
//   final VoidCallback? onTap;
//   final TextInputType? keyboardType;
//   final bool obscureText;
//   final Widget? prefixIcon;
//   final Widget? suffixIcon;
//   final int? maxLines;
//   final bool enabled;
//   final bool readOnly;
//   final String? errorText;
//   final Color? iconColor;
//   final Color? fillColor;
//   final FocusNode? focusNode;
//   final String? initialValue;
//   final TextStyle? style;
//   const CustomTextField({
//     super.key,
//     this.label,
//     this.hint,
//     this.controller,
//     this.validator,
//     this.onChanged,
//     this.onSubmitted,
//     this.onTap,
//     this.keyboardType,
//     this.obscureText = false,
//     this.prefixIcon,
//     this.suffixIcon,
//     this.maxLines = 1,
//     this.enabled = true,
//     this.readOnly = false,
//     this.errorText,
//     this.iconColor,
//     this.fillColor,
//     this.focusNode,
//     this.initialValue,
//     this.style,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // final bool showFixedLabel = maxLines != null && maxLines! > 1;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (label != null) ...[
//           Text(label!),
//           const SizedBox(height: UiConstants.spacingSm),
//         ],
//         TextFormField(
//           initialValue: initialValue,
//           controller: controller,
//           validator: validator,
//           onChanged: onChanged,
//           onFieldSubmitted: onSubmitted,
//           keyboardType: keyboardType,
//           obscureText: obscureText,
//           maxLines: maxLines,
//           enabled: enabled,
//           readOnly: readOnly,
//           onTap: onTap,
//           style: style ?? TextStyle(),
//           decoration: InputDecoration(
//             labelStyle: TextStyle(),
//             hintStyle: TextStyle(),
//             labelText: label ?? hint,
//             // floatingLabelBehavior: FloatingLabelBehavior.always,
//             prefixIcon: prefixIcon != null
//                 ? IconTheme(
//                     data: IconThemeData(color: iconColor),
//                     child: prefixIcon!,
//                   )
//                 : null,
//             suffixIcon: suffixIcon != null
//                 ? IconTheme(
//                     data: IconThemeData(color: iconColor),
//                     child: suffixIcon!,
//                   )
//                 : null,
//             hintText: hint,
//             filled: fillColor != null,
//             fillColor: fillColor,
//             errorText: errorText,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(UiConstants.radiusXl),
//             ),
//           ),
//           focusNode: focusNode,
//         ),
//       ],
//     );
//   }
// }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonStyle? style;
  final Widget? icon;
  final bool isOutlined;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.style,
    this.icon,
    this.isOutlined = false,
    this.textColor,
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

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: UiConstants.spacingSm),
          Flexible(
            child: Text(
              text,
              style: TextStyle(color: textColor ?? Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final container = Container(
      margin: margin,
      //  ??
      // const EdgeInsets.symmetric(
      //   horizontal: UiConstants.spacingMd,
      //   vertical: UiConstants.spacingSm,
      // ),
      // padding: padding ?? const EdgeInsets.all(UiConstants.spacingMd),
      // decoration: BoxDecoration(
      //   color: backgroundColor ?? colorScheme.surface,
      //   borderRadius:
      //       borderRadius ?? BorderRadius.circular(UiConstants.radiusLg),
      //   boxShadow:
      //       shadows ??
      //       [
      //         BoxShadow(
      //           color: const Color(0xFF363535).withAlpha(40),
      //           spreadRadius: 0,
      //           blurRadius: 16,
      //           offset: const Offset(0, 0),
      //         ),
      //       ],
      // ),
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

// class CustomDropdown<T> extends StatelessWidget {
//   final String label;
//   final String? hint;
//   final T? value;
//   final List<DropdownMenuItem<T>> items;
//   final ValueChanged<T?>? onChanged;
//   final String? errorText;
//   final Widget? prefixIcon;

//   const CustomDropdown({
//     super.key,
//     required this.label,
//     this.hint,
//     this.value,
//     required this.items,
//     this.onChanged,
//     this.errorText,
//     this.prefixIcon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: Theme.of(
//             context,
//           ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
//         ),
//         const SizedBox(height: 6),
//         DropdownButtonFormField<T>(
//           initialValue: value,
//           hint: hint != null
//               ? Text(hint!, style: const TextStyle(color: Colors.grey))
//               : null,
//           items: items,
//           onChanged: onChanged,
//           decoration: InputDecoration(
//             errorText: errorText,
//             prefixIcon: prefixIcon,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 4,
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade400),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey.shade400),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(
//                 color: Theme.of(context).primaryColor,
//                 width: 2,
//               ),
//             ),
//             filled: true,
//             fillColor: Colors.grey.shade50,
//           ),
//           dropdownColor: Colors.white,
//           icon: const Icon(Icons.keyboard_arrow_down_rounded),
//         ),
//       ],
//     );
//   }
// }

class CustomMultiSelect<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final List<T> selected;
  final String Function(T) itemLabel;
  final ValueChanged<List<T>>? onChanged;
  final Widget? prefixIcon;
  final bool readOnly;
  final double fontSize;

  const CustomMultiSelect({
    super.key,
    required this.label,
    required this.items,
    required this.selected,
    required this.itemLabel,
    this.onChanged,
    this.prefixIcon,
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

        // Wrap(
        //   spacing: 8,
        //   children: items.asMap().entries.map((entry) {
        //     final index = entry.key;
        //     final item = entry.value;

        //     final isSelected = selected.contains(item);
        //     final isEven = index.isEven;

        //     return FilterChip(
        //           label: Text(
        //             itemLabel(item),
        //             style: const TextStyle(color: Colors.black),
        //           ),
        //           labelPadding: const EdgeInsets.symmetric(
        //             horizontal: 12,
        //             vertical: 4,
        //           ),
        //           selected: isSelected,
        //           onSelected: readOnly
        //               ? null
        //               : (bool selected) {
        //                   final newSelected = List<T>.from(this.selected);
        //                   if (selected) {
        //                     newSelected.add(item);
        //                   } else {
        //                     newSelected.remove(item);
        //                   }
        //                   onChanged?.call(newSelected);
        //                 },

        //           avatar: readOnly
        //               ? Icon(
        //                   isSelected ? Icons.check : Icons.close,
        //                   size: 18,
        //                   color: isSelected ? Colors.green : Colors.red,
        //                 )
        //               : null,

        //           disabledColor: isSelected
        //               ? Theme.of(context).primaryColor.withAlpha(18)
        //               : const Color(0xFFEF4444).withAlpha(120),

        //           labelStyle: const TextStyle(color: Colors.black),

        //           selectedColor: readOnly
        //               ? (const Color(0xFF10B981).withAlpha(158))
        //               : Theme.of(context).primaryColor.withAlpha(150),

        //           backgroundColor: readOnly
        //               ? (isSelected
        //                     ? Theme.of(context).primaryColor.withAlpha(150)
        //                     : Colors.red.withAlpha(30))
        //               : Colors.grey.shade100,

        //           checkmarkColor: Colors.black,

        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(UiConstants.radiusLg),
        //             side: BorderSide(
        //               color: readOnly
        //                   ? (isSelected ? Colors.green : Colors.red)
        //                   : (isSelected
        //                         ? Theme.of(context).primaryColor
        //                         : Colors.grey.shade300),
        //             ),
        //           ),
        //         )
        //         .animate(delay: UiConstants.animationDelayFast)
        //         .scale(duration: 200.ms, curve: Curves.easeOut)
        //         .slideY(
        //           begin: isEven ? 0.3 : -0.3,
        //           duration: 300.ms,
        //           curve: Curves.easeOut,
        //         );
        //   }).toList(),
        // ),
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
                  label: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UiConstants.spacingSm,
                      vertical: UiConstants.spacingXs,
                    ),
                    width: double.infinity,

                    child: Text(
                      itemLabel(item),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black),
                    ),
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

                  avatar: readOnly
                      ? Icon(
                          isSelected ? Icons.check : Icons.close,
                          size: 18,
                          color: isSelected ? Colors.green : Colors.red,
                        )
                      : null,

                  disabledColor: isSelected
                      ? Theme.of(context).primaryColor
                      : const Color(0xFFEF4444).withAlpha(120),

                  backgroundColor: Colors.grey.shade100,

                  selectedColor: Theme.of(context).primaryColor.withAlpha(150),
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
