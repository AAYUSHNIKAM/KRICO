import 'package:intl/intl.dart';

abstract class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _decimalFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _dateFormat = DateFormat('dd MMM yyyy');
  static final _timeFormat = DateFormat('hh:mm a');
  static final _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final _relativeFormat = DateFormat('dd MMM');
  static final _monthYearFormat = DateFormat('MMM yyyy');

  static String currency(double amount) => _currencyFormat.format(amount);
  static String currencyDecimal(double amount) => _decimalFormat.format(amount);
  static String date(DateTime date) => _dateFormat.format(date);
  static String time(DateTime date) => _timeFormat.format(date);
  static String dateTime(DateTime date) => _dateTimeFormat.format(date);
  static String monthYear(DateTime date) => _monthYearFormat.format(date);

  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _relativeFormat.format(date);
  }

  static String phone(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }

  static String rating(double rating) => rating.toStringAsFixed(1);

  static String percent(double value) => '${(value * 100).toStringAsFixed(0)}%';

  static String number(int value) {
    if (value >= 10000000) return '${(value / 10000000).toStringAsFixed(1)}Cr';
    if (value >= 100000) return '${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }

  static String duration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    }
    return '${duration.inSeconds}s';
  }
}
