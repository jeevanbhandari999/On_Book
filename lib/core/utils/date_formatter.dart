import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatWithDay(DateTime date) {
    return DateFormat('EEE, dd MMM yyyy').format(date);
  }

  static String range(DateTime start, DateTime end) {
    return '${format(start)} → ${format(end)}';
  }
}
