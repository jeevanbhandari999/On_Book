import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class AutoMarqueeText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int maxLines;
  final TextAlign textAlign;
  final double height;
  final double velocity;
  final double blankSpace;

  const AutoMarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.height = 20,
    this.velocity = 30,
    this.blankSpace = 24,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: double.infinity);

        final isOverflowing = textPainter.width > constraints.maxWidth;

        if (!isOverflowing) {
          return Text(
            text,
            maxLines: maxLines,
            textAlign: textAlign,
            overflow: TextOverflow.ellipsis,
            style: style,
          );
        }

        return SizedBox(
          height: height,
          width: double.infinity,
          child: Marquee(
            text: text,
            style: style,
            blankSpace: blankSpace,
            velocity: velocity,
            pauseAfterRound: const Duration(seconds: 1),
            startPadding: 10,
          ),
        );
      },
    );
  }
}
