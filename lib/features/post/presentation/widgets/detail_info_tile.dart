import 'package:app/core/constants/ui_constants.dart';
import 'package:flutter/material.dart';

class DetailInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const DetailInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: UiConstants.spacingSm,
        horizontal: UiConstants.spacingMd,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(50),
        borderRadius: BorderRadius.circular(UiConstants.radiusSm),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
