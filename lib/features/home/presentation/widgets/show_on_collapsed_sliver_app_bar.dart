import 'package:flutter/material.dart';

class ShowOnCollapsedSliverAppBar extends StatelessWidget {
  final Widget child;

  const ShowOnCollapsedSliverAppBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    if (settings == null) return child;

    final deltaExtent = settings.maxExtent - settings.minExtent;
    final t =
        (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
            .clamp(0.0, 1.0);

    return Opacity(
      opacity: t,
      child: Transform.scale(scale: 0.85 + 0.15 * t, child: child),
    );
  }
}
