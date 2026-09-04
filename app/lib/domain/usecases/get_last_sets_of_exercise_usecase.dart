import '../repositories/i_workout_repository.dart';
import '../models/workout_set.dart';

class GetLastSetsOfExerciseUseCase {
  final IWorkoutRepository _repo;

  GetLastSetsOfExerciseUseCase(this._repo);

  Future<List<WorkoutSet>> execute({
    required String uid,
    required String exerciseId,
    int limit = 3,
  }) {
    return _repo.getLastSetsOfExercise(
      uid: uid,
      exerciseId: exerciseId,
      limit: limit,
    );
  }
}
