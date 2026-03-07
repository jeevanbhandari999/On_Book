import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/custom_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PaymentMethodTile extends StatelessWidget {
  final String methodId;
  final String svgIconPath;
  final String subtitle;
  final Color? subtitleColor;

  /// Controls border highlight
  final bool isSelected;

  /// Controls check visibility independently
  final bool showCheckmark;

  /// If null → read-only
  final VoidCallback? onTap;

  const PaymentMethodTile({
    super.key,
    required this.methodId,
    required this.svgIconPath,
    this.subtitle = 'Selected payment method',
    this.isSelected = false,
    this.showCheckmark = false,
    this.onTap,
    this.subtitleColor,
  });

  bool get isClickable => onTap != null;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(UiConstants.radiusMd),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(UiConstants.spacingMd),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.success.withAlpha(90)
                : AppColors.white.withAlpha(90),
            borderRadius: BorderRadius.circular(UiConstants.radiusMd),
            border: Border.all(
              color: isSelected ? AppColors.success : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Icon container
              SizedBox(
                width: 44,
                height: 44,
                // Use Container if we need the UI like this color
                // decoration: BoxDecoration(
                //   color: AppColors.white,
                //   borderRadius: BorderRadius.circular(UiConstants.radiusSm),
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.black.withAlpha(15),
                //       blurRadius: 6,
                //       offset: const Offset(0, 2),
                //     ),
                //   ],
                // ),
                child: isSelected
                    ? Center(
                        child:
                            CustomSvgIcon(
                                  path: svgIconPath,
                                  size: UiConstants.iconXl,
                                )
                                .animate(delay: UiConstants.animationFast)
                                .scaleXY(
                                  begin: 0.8,
                                  end: 1.1,
                                  duration: UiConstants.animationSlow,
                                  curve: Curves.easeOut,
                                ),
                      )
                    : Center(
                        child: CustomSvgIcon(
                          path: svgIconPath,
                          size: UiConstants.iconXl,
                        ),
                      ),
              ),

              const SizedBox(width: 12),

              // Label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(methodId),
                    if (showCheckmark)
                      Text(
                            subtitle,
                            style: TextStyle(
                              color: subtitleColor,
                              fontSize: 12,
                            ),
                          )
                          .animate(delay: UiConstants.animationFast)
                          .slide(duration: UiConstants.animationSlow)
                          .fade(duration: UiConstants.animationSlow),
                  ],
                ),
              ),

              // Check badge
              if (showCheckmark)
                Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: UiConstants.iconXs,
                        color: AppColors.black,
                      ),
                    )
                    .animate(delay: UiConstants.animationFast)
                    .scaleXY(
                      begin: 0.8,
                      end: 1.1,
                      duration: UiConstants.animationSlow,
                      curve: Curves.easeOut,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
