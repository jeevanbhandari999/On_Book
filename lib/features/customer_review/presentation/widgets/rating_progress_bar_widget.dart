// import 'package:app/core/constants/ui_constants.dart';
// import 'package:flutter/material.dart';

// class RatingProgressBar extends StatelessWidget {
//   final String ratingRange;
//   final double percent;
//   final int peopleNumber;
//   final Color? backgroundColor;
//   final Color? textColor;
//   final Color? filledColor;

//   const RatingProgressBar({
//     super.key,
//     required this.ratingRange,
//     required this.percent,
//     required this.peopleNumber,
//     this.backgroundColor,
//     this.textColor,
//     this.filledColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final double normalized = (percent.clamp(0, 100)) / 100;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Stack(
//             alignment: Alignment.centerLeft,
//             children: [
//               const Text(
//                 '5 Stars',
//                 style: TextStyle(color: Colors.transparent),
//               ),
//               Text(ratingRange, style: TextStyle(color: textColor)),
//             ],
//           ),

//           const SizedBox(width: 8),
//           Expanded(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(20),
//               child: LinearProgressIndicator(
//                 value: normalized,
//                 minHeight: 14,
//                 backgroundColor: backgroundColor ?? Colors.grey[300],
//                 borderRadius: const BorderRadius.only(
//                   topRight: Radius.circular(UiConstants.radiusRound),
//                   bottomRight: Radius.circular(UiConstants.radiusRound),
//                 ),
//                 valueColor: filledColor == null
//                     ? null
//                     : AlwaysStoppedAnimation(filledColor),
//               ),
//             ),
//           ),

//           const SizedBox(width: 8),

//           Row(
//             children: [
//               Text(
//                 '${percent.toStringAsFixed(0).padLeft(2, ' ')}%',
//                 style: TextStyle(color: textColor),
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 peopleNumber < 100
//                     ? peopleNumber.toString().padLeft(2, '0')
//                     : '+99',
//                 style: TextStyle(color: textColor),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class RatingProgressBar extends StatefulWidget {
  final String ratingRange;
  final double percent;
  final int peopleNumber;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? filledColor;

  const RatingProgressBar({
    super.key,
    required this.ratingRange,
    required this.percent,
    required this.peopleNumber,
    this.backgroundColor,
    this.textColor,
    this.filledColor,
  });

  @override
  State<RatingProgressBar> createState() => _RatingProgressBarState();
}

class _RatingProgressBarState extends State<RatingProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    final normalized = (widget.percent.clamp(0, 100)) / 100;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fillAnimation = Tween<double>(
      begin: 0.0,
      end: normalized,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _countAnimation = Tween<double>(
      begin: 0.0,
      end: widget.percent,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Small delay so bars animate after page settles
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(RatingProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-animate if percent changes (e.g. refresh)
    if (oldWidget.percent != widget.percent) {
      final normalized = (widget.percent.clamp(0, 100)) / 100;
      _fillAnimation =
          Tween<double>(begin: _fillAnimation.value, end: normalized).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _countAnimation =
          Tween<double>(
            begin: _countAnimation.value,
            end: widget.percent,
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Color shifts from red → green as percent increases

  Color _resolveFilledColor(double animatedPercent) {
    if (widget.filledColor != null) return widget.filledColor!;

    // We can handle the different colors according ot the rating perecentage
    // if (animatedPercent >= 80) return const Color(0xFF2E7D32); // deep green
    // if (animatedPercent >= 60) return const Color(0xFF66BB6A); // light green
    // if (animatedPercent >= 40) return const Color(0xFFFFB300); // amber
    // if (animatedPercent >= 20) return const Color(0xFFFF7043); // orange
    // return const Color(0xFFE53935); // red
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // ── Fixed-width label (uses transparent spacer trick) ─────────────
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              const Text(
                '5 Stars',
                style: TextStyle(color: Colors.transparent),
              ),
              Text(
                widget.ratingRange,
                style: TextStyle(color: widget.textColor),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // ── Animated bar ──────────────────────────────────────────────────
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final animatedPercent = _countAnimation.value;
                final fillColor = _resolveFilledColor(animatedPercent);

                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Grey background track
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: widget.backgroundColor ?? Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      // Animated fill with shimmer gloss on top
                      FractionallySizedBox(
                        widthFactor: _fillAnimation.value,
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                fillColor,
                                fillColor,
                                Color.lerp(fillColor, Colors.white, 0.35)!,
                                fillColor,
                              ],
                              stops: const [0.0, 0.45, 0.65, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 8),

          // ── Animated count + percent ──────────────────────────────────────
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final displayPercent = _countAnimation.value;
              return Row(
                children: [
                  Text(
                    '${displayPercent.toStringAsFixed(0).padLeft(2, ' ')}%',
                    style: TextStyle(color: widget.textColor),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.peopleNumber < 100
                        ? widget.peopleNumber.toString().padLeft(2, '0')
                        : '+99',
                    style: TextStyle(color: widget.textColor),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
