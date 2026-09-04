import '../models/workout.dart';

double calc1RM(double weight, int reps) {
  if (reps == 1) {
    return weight;
  }
  return weight * (1 + reps / 30);
}

double calcSetVolume(WorkoutSet s) {
  return s.isWarmup ? 0 : s.weightKg * s.reps;
}

double calcSessionVolume(List<WorkoutSet> sets) {
  double total = 0.0;
  for (final s in sets) {
    total += calcSetVolume(s);
  }
  return total;
}

int calcDurationMin(DateTime start, DateTime? end) {
  return end == null ? 0 : end.difference(start).inMinutes;
}
