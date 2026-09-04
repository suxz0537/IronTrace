import '../models/workout_set.dart';

class ExercisePrRecord {
  final String exerciseId;
  final PRItem maxWeight;
  final PRItem max1Rm;
  final PRItem maxVolume;

  ExercisePrRecord({
    required this.exerciseId,
    required this.maxWeight,
    required this.max1Rm,
    required this.maxVolume,
  });
}

class PRItem {
  final String? setId;
  final double value;
  final double? weight;
  final int? reps;
  final DateTime? date;

  PRItem({
    this.setId,
    required this.value,
    this.weight,
    this.reps,
    this.date,
  });
}

class PrService {
  const PrService();

  Map<String, ExercisePrRecord> calculateAll(List<WorkoutSet> sets) {
    final completed = sets.where((s) => !s.isWarmup && s.completedAt != null);
    final byExercise = <String, List<WorkoutSet>>{};
    for (final s in completed) {
      byExercise.putIfAbsent(s.exerciseId, () => []).add(s);
    }

    final result = <String, ExercisePrRecord>{};
    byExercise.forEach((exerciseId, exerciseSets) {
      result[exerciseId] = _calculateForExercise(exerciseId, exerciseSets);
    });

    return result;
  }

  ExercisePrRecord _calculateForExercise(String exerciseId, List<WorkoutSet> sets) {
    WorkoutSet? maxWeight;
    WorkoutSet? max1Rm;
    WorkoutSet? maxVolume;

    for (final s in sets) {
      if (maxWeight == null || s.weight > maxWeight.weight) {
        maxWeight = s;
      }
      if (s.oneRm != null && (max1Rm == null || s.oneRm! > max1Rm.oneRm!)) {
        max1Rm = s;
      }
      final vol = s.volume ?? s.weight * s.reps;
      final curMaxVol = maxVolume?.volume ??
          (maxVolume != null ? maxVolume.weight * maxVolume.reps : 0.0);
      if (vol > curMaxVol) {
        maxVolume = s;
      }
    }

    return ExercisePrRecord(
      exerciseId: exerciseId,
      maxWeight: PRItem(
        setId: maxWeight?.id,
        value: maxWeight?.weight ?? 0,
        weight: maxWeight?.weight,
        reps: maxWeight?.reps,
        date: maxWeight?.completedAt,
      ),
      max1Rm: PRItem(
        setId: max1Rm?.id,
        value: max1Rm?.oneRm ?? 0,
        weight: max1Rm?.weight,
        reps: max1Rm?.reps,
        date: max1Rm?.completedAt,
      ),
      maxVolume: PRItem(
        setId: maxVolume?.id,
        value: maxVolume?.volume ??
            (maxVolume != null ? maxVolume.weight * maxVolume.reps : 0),
        weight: maxVolume?.weight,
        reps: maxVolume?.reps,
        date: maxVolume?.completedAt,
      ),
    );
  }
}
