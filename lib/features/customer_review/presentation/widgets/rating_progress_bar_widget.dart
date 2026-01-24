import 'package:app/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';

class RatingProgressBar extends StatelessWidget {
  final String ratingRange;
  final double percent;
  final int peopleNumber;

  const RatingProgressBar({
    super.key,
    required this.ratingRange,
    required this.percent,
    required this.peopleNumber,
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
                '5 stars',
                style: TextStyle(color: Colors.transparent),
              ),
              Text(ratingRange),
            ],
          ),

          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: normalized,
                minHeight: 14,
                backgroundColor: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(UiConstants.radiusRound),
                  bottomRight: Radius.circular(UiConstants.radiusRound),
                ),
                // valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ),

          const SizedBox(width: 8),

          Row(
            children: [
              Text('${percent.toStringAsFixed(0).padLeft(2, ' ')}%'),
              const SizedBox(width: 4),
              Text(
                peopleNumber < 100
                    ? peopleNumber.toString().padLeft(2, '0')
                    : '+99',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
