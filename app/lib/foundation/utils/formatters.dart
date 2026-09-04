import 'package:intl/intl.dart';

String formatDate(DateTime d) {
  return DateFormat('yyyy-MM-dd HH:mm').format(d);
}

String formatDurationMin(int? m) {
  return m == null ? '--' : '${m}分钟';
}

String formatVolume(double v) {
  final decimals = v.truncateToDouble() == v ? 0 : 1;
  return '${v.toStringAsFixed(decimals)}kg';
}

String formatWeight(double w) {
  final decimals = w.truncateToDouble() == w ? 0 : 1;
  return '${w.toStringAsFixed(decimals)}kg';
}
