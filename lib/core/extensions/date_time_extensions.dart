import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  bool get isToday => isSameDay(DateTime.now());
  bool get isPast => isBefore(DateTime.now());
  bool get isYesterday =>
      isSameDay(DateTime.now().subtract(const Duration(days: 1)));
  bool get isLastWeek =>
      isAfter(DateTime.now().subtract(const Duration(days: 7)));
  bool isSameDay(DateTime dateTime) {
    return year == dateTime.year &&
        month == dateTime.month &&
        day == dateTime.day;
  }

  String toLocaleString() {
    return DateFormat.yMMMMEEEEd().format(this);
  }

  String toStringWithFormat(String format) {
    return DateFormat(format).format(this);
  }

  String toStringWithDefaultFormat() {
    return toStringWithFormat('dd/MM/yyyy');
  }

  String toStringTimeOnly() {
    return DateFormat.jm().format(this);
  }
}
