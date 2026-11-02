import 'package:intl/intl.dart';

extension DateExtensions on DateTime {
  String get formattedDate {
    final now = DateTime.now();
    final difference = DateTime(year, month, day).difference(DateTime(now.year, now.month, now.day)).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, y').format(this);
    }
  }

  String get formattedTime {
    return DateFormat('h:mm a').format(this);
  }
}
