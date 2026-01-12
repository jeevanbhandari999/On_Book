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

    Color progressColor = Colors.blue[300]!.withAlpha(200);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(ratingRange, textAlign: TextAlign.left)),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: normalized,
                backgroundColor: Colors.grey[300]!,
                color: progressColor,
                minHeight: 14,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${percent.toStringAsFixed(0)}%',
                  textAlign: TextAlign.left,
                ),
                const SizedBox(width: 2),
                Text(
                  '(${peopleNumber.toString()})',
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
