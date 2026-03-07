import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomSvgIcon extends StatelessWidget {
  final String path;
  final Color? color;
  final double? size;
  final ColorFilter? colorFilter;
  final BoxFit? fit;

  const CustomSvgIcon({
    super.key,
    required this.path,
    this.color,
    this.size,
    this.colorFilter,
    this.fit,
  });

  bool get _shouldApplyColor => color != null || colorFilter != null;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      fit: fit ?? BoxFit.contain,
      path,
      width: size,
      height: size,
      colorFilter: _shouldApplyColor
          ? (colorFilter ?? ColorFilter.mode(color!, BlendMode.srcIn))
          : null,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(path, width: size, height: size, fit: BoxFit.cover);
      },
    );
  }
}
