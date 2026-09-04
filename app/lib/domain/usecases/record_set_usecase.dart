import '../foundation/app_constants.dart';
import '../repositories/i_workout_repository.dart';
import '../models/workout_set.dart';

class RecordSetUseCase {
  final IWorkoutRepository _repo;

  RecordSetUseCase(this._repo);

  Future<WorkoutSet> execute({
    required String id,
    required String sessionId,
    required String sessionExerciseId,
    required String exerciseId,
    required int setNo,
    required double weight,
    required int reps,
    double? rpe,
    bool isWarmup = false,
    DateTime? completedAt,
  }) async {
    if (weight < AppConstants.minWeight || weight > AppConstants.maxWeight) {
      throw ArgumentError(
        'Weight out of range: ${AppConstants.minWeight} - ${AppConstants.maxWeight}',
      );
    }
    if (reps < AppConstants.minReps || reps > AppConstants.maxReps) {
      throw ArgumentError(
        'Reps out of range: ${AppConstants.minReps} - ${AppConstants.maxReps}',
      );
    }
    if (rpe != null && (rpe < AppConstants.minRpe || rpe > AppConstants.maxRpe)) {
      throw ArgumentError(
        'RPE out of range: ${AppConstants.minRpe} - ${AppConstants.maxRpe}',
      );
    }

    final volume = isWarmup ? 0.0 : weight * reps;
    final oneRm = isWarmup
        ? null
        : _calcOneRm(weight, reps, rpe);

    final set = WorkoutSet(
      id: id,
      sessionId: sessionId,
      sessionExerciseId: sessionExerciseId,
      exerciseId: exerciseId,
      setNo: setNo,
      weight: weight,
      reps: reps,
      rpe: rpe,
      isWarmup: isWarmup,
      volume: volume,
      oneRm: oneRm,
      completedAt: completedAt ?? DateTime.now(),
    );

    return _repo.upsertSet(set);
  }

  static double? _calcOneRm(double weight, int reps, double? rpe) {
    if (reps <= 0) return null;
    final effectiveReps = rpe != null ? reps + (10 - rpe) : reps.toDouble();
    if (effectiveReps <= 0) return weight;
    return weight * (1 + effectiveReps / 30);
  }
}
