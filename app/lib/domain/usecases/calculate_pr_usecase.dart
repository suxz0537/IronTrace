import '../repositories/i_workout_repository.dart';
import '../models/workout_set.dart';

class CalculatePRUseCase {
  final IWorkoutRepository _repo;

  CalculatePRUseCase(this._repo);

  Future<Map<String, dynamic>> execute({
    required String uid,
    required String exerciseId,
  }) async {
    final sets = await _repo.getAllSetsByExercise(uid: uid, exerciseId: exerciseId);
    final workingSets = sets.where((s) => !s.isWarmup && s.completedAt != null).toList();

    if (workingSets.isEmpty) {
      return {
        'maxWeight': null,
        'max1Rm': null,
        'maxVolume': null,
      };
    }

    WorkoutSet? maxWeight;
    WorkoutSet? max1Rm;
    WorkoutSet? maxVolume;

    for (final s in workingSets) {
      if (maxWeight == null || s.weight > maxWeight.weight) {
        maxWeight = s;
      }
      if (s.oneRm != null && (max1Rm == null || s.oneRm! > max1Rm.oneRm!)) {
        max1Rm = s;
      }
      final vol = s.volume ?? s.weight * s.reps;
      final curMaxVol = maxVolume?.volume ?? maxVolume?.weight * maxVolume!.reps ?? 0;
      if (vol > curMaxVol) {
        maxVolume = s;
      }
    }

    return {
      'maxWeight': {
        'setId': maxWeight?.id,
        'value': maxWeight?.weight,
        'reps': maxWeight?.reps,
        'date': maxWeight?.completedAt,
      },
      'max1Rm': {
        'setId': max1Rm?.id,
        'value': max1Rm?.oneRm,
        'weight': max1Rm?.weight,
        'reps': max1Rm?.reps,
        'date': max1Rm?.completedAt,
      },
      'maxVolume': {
        'setId': maxVolume?.id,
        'value': maxVolume?.volume ?? maxVolume?.weight * maxVolume!.reps,
        'weight': maxVolume?.weight,
        'reps': maxVolume?.reps,
        'date': maxVolume?.completedAt,
      },
    };
  }
}
