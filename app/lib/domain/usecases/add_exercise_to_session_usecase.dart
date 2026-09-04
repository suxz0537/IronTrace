import '../repositories/i_workout_repository.dart';
import '../models/session_exercise.dart';

class AddExerciseToSessionUseCase {
  final IWorkoutRepository _repo;

  AddExerciseToSessionUseCase(this._repo);

  Future<SessionExercise> execute({
    required String sessionId,
    required String exerciseId,
  }) async {
    final session = await _repo.getSessionById(sessionId);
    if (session == null) {
      throw StateError('Session not found: $sessionId');
    }
    if (session.endTime != null) {
      throw StateError('Session already finished: $sessionId');
    }

    final existing = await _repo.getExercisesBySession(sessionId);
    final alreadyAdded = existing.any((e) => e.exerciseId == exerciseId);
    if (alreadyAdded) {
      throw StateError('Exercise already added to session: $exerciseId');
    }

    return _repo.addExerciseToSession(
      sessionId: sessionId,
      exerciseId: exerciseId,
    );
  }
}
