import 'dart:async';

import 'package:app/core/constants/app_images.dart';
import 'package:app/core/constants/ui_constants.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/custom_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedAppIcon extends StatefulWidget {
  const AnimatedAppIcon({super.key});

  @override
  State<AnimatedAppIcon> createState() => AnimatedAppIconState();
}

class AnimatedAppIconState extends State<AnimatedAppIcon> {
  bool _toggled = false;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    // flip every 1800ms to match the scaleXY duration
    _timer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (mounted) setState(() => _toggled = !_toggled);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(UiConstants.spacingSm),
      child: ClipOval(
        child:
            AnimatedContainer(
                  duration: const Duration(milliseconds: 1800),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _toggled
                          ? Colors.white.withOpacity(0.4)
                          : Colors.white,
                      width: _toggled ? 1.0 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _toggled
                            ? Colors.white.withOpacity(0.25)
                            : Colors.black.withAlpha(80),
                        blurRadius: _toggled ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const CustomSvgIcon(
                    path: AppImages.appIconTransparentSvg,
                    // colorFilter: ColorFilter.mode(
                    //   AppColors.primary,
                    //   BlendMode.srcIn,
                    // ),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 1.0,
                  end: 1.06,
                  duration: 1800.ms,
                  curve: Curves.easeInOut,
                )
                .shimmer(
                  delay: 400.ms,
                  duration: 1800.ms,
                  color: Colors.white.withOpacity(0.15),
                  angle: 0.5,
                ),
      ),
    );
  }
}
