import '../models/workout_session.dart';

class DateVolume {
  final DateTime date;
  final double volume;

  DateVolume({required this.date, required this.volume});
}

enum VolumeGranularity { day, week }

class VolumeAggregator {
  const VolumeAggregator();

  List<DateVolume> aggregate(
    List<WorkoutSession> sessions, {
    VolumeGranularity granularity = VolumeGranularity.day,
  }) {
    final map = <DateTime, double>{};
    for (final s in sessions) {
      if (s.endTime == null) continue;
      final key = granularity == VolumeGranularity.day
          ? _dayKey(s.startTime ?? s.endTime!)
          : _weekKey(s.startTime ?? s.endTime!);
      final vol = s.totalVolume ?? 0;
      map[key] = (map[key] ?? 0) + vol;
    }

    final entries = map.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => DateVolume(date: e.key, volume: e.value)).toList();
  }

  DateTime _dayKey(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  DateTime _weekKey(DateTime dt) {
    final dayOfWeek = dt.weekday;
    final monday = dt.subtract(Duration(days: dayOfWeek - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }
}
