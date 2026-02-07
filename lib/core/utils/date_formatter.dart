// import 'package:intl/intl.dart';

// class DateFormatter {
//   static String format(DateTime date) {
//     return DateFormat('dd MMM yyyy').format(date);
//   }

//   static String formatWithDay(DateTime date) {
//     return DateFormat('EEE, dd MMM yyyy').format(date);
//   }

//   static String range(DateTime start, DateTime end) {
//     return '${format(start)} → ${format(end)}';
//   }
// }


import 'package:intl/intl.dart';

class DateFormatter {
  /// Format date as: Jan 15, 2024
  static String format(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Format date with day: Monday, Jan 15, 2024
  static String formatWithDay(DateTime date) {
    return DateFormat('EEEE, MMM d, yyyy').format(date);
  }

  /// Format date with time: Jan 15, 2024 at 3:30 PM
  static String formatWithTime(DateTime date) {
    return DateFormat('MMM d, yyyy \'at\' h:mm a').format(date);
  }

  /// Format date range: Jan 15 - Jan 20, 2024
  static String range(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${DateFormat('MMM d').format(start)} - ${DateFormat('d, yyyy').format(end)}';
    } else if (start.year == end.year) {
      return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
    } else {
      return '${DateFormat('MMM d, yyyy').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
    }
  }

  /// Format time only: 3:30 PM
  static String timeOnly(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  /// Format relative time: 2 hours ago, Yesterday, etc.
  static String relative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      }
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Format short date: 15 Jan
  static String shortDate(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  /// Format full date and time: Monday, January 15, 2024 at 3:30 PM
  static String fullDateTime(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy \'at\' h:mm a').format(date);
  }
}