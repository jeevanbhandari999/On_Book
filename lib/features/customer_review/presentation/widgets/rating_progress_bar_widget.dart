import 'package:app/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';

class RatingProgressBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final double normalized = (percent.clamp(0, 100)) / 100;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              const Text(
                '5 Stars',
                style: TextStyle(color: Colors.transparent),
              ),
              Text(ratingRange, style: TextStyle(color: textColor)),
            ],
          ),

          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: normalized,
                minHeight: 14,
                backgroundColor: backgroundColor ?? Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(UiConstants.radiusRound),
                  bottomRight: Radius.circular(UiConstants.radiusRound),
                ),
                valueColor: filledColor == null
                    ? null
                    : AlwaysStoppedAnimation(filledColor),
              ),
            ),
          ),

          const SizedBox(width: 8),

          Row(
            children: [
              Text(
                '${percent.toStringAsFixed(0).padLeft(2, ' ')}%',
                style: TextStyle(color: textColor),
              ),
              const SizedBox(width: 4),
              Text(
                peopleNumber < 100
                    ? peopleNumber.toString().padLeft(2, '0')
                    : '+99',
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
