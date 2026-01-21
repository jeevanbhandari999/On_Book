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
        children: [
          Flexible(flex: 2, child: Text(ratingRange)),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(value: normalized, minHeight: 14),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${percent.toStringAsFixed(0)}%'),
                const SizedBox(width: 4),
                Text('($peopleNumber)'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
