import 'package:uuid/uuid.dart';

import '../repositories/i_workout_repository.dart';
import '../models/workout_set.dart';

class DuplicateLastSetUseCase {
  final IWorkoutRepository _repo;
  final Uuid _uuid;

  DuplicateLastSetUseCase(this._repo, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  Future<WorkoutSet> execute({
    required String sessionId,
    required String sessionExerciseId,
    required String exerciseId,
  }) async {
    final sets = await _repo.getSetsBySessionExercise(sessionExerciseId);
    if (sets.isEmpty) {
      throw StateError('No sets found in exercise: $sessionExerciseId');
    }

    final sorted = sets.toList()
      ..sort((a, b) => b.setNo.compareTo(a.setNo));
    final last = sorted.first;

    final newSetNo = last.setNo + 1;
    final newId = _uuid.v4();

    final duplicated = WorkoutSet(
      id: newId,
      sessionId: sessionId,
      sessionExerciseId: sessionExerciseId,
      exerciseId: exerciseId,
      setNo: newSetNo,
      weight: last.weight,
      reps: last.reps,
      rpe: last.rpe,
      isWarmup: last.isWarmup,
      volume: last.isWarmup ? 0.0 : last.weight * last.reps,
      oneRm: last.oneRm,
      completedAt: null,
    );

    return _repo.upsertSet(duplicated);
  }
}
