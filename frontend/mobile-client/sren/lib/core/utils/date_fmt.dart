import 'package:intl/intl.dart';

class DateFmt {
  DateFmt._();

  static final _shortDate = DateFormat.yMMMd();
  static final _time = DateFormat.Hm();
  static final _longDateTime = DateFormat('EEE, MMM d • HH:mm');

  static String short(DateTime date) => _shortDate.format(date);

  static String time(DateTime date) => _time.format(date);

  static String long(DateTime date) => _longDateTime.format(date);

  static String relative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inSeconds.abs() < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return minutes <= 1 ? '1 min ago' : '$minutes mins ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return hours <= 1 ? '1 hr ago' : '$hours hrs ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return days <= 1 ? 'Yesterday' : '$days days ago';
    } else {
      return short(date);
    }
  }
}
