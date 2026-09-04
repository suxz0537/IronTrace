import '../repositories/i_workout_repository.dart';
import '../storage/kv_storage.dart';
import '../models/workout_session.dart';

class FinishTrainingUseCase {
  final IWorkoutRepository _repo;
  final KvStorage _kv;

  FinishTrainingUseCase(this._repo, this._kv);

  Future<WorkoutSession> execute(String sid) async {
    final session = await _repo.getSessionById(sid);
    if (session == null) {
      throw StateError('Session not found: $sid');
    }

    final sets = await _repo.getSetsBySession(sid);

    final totalVolume = sets.fold<double>(
      0,
      (sum, s) => sum + (s.volume ?? 0),
    );

    final endTime = DateTime.now();
    final durationMin = session.startTime != null
        ? endTime.difference(session.startTime!).inMinutes
        : 0;

    final finished = await _repo.finishSession(
      sid,
      totalVolume: totalVolume,
      durationMin: durationMin,
      endTime: endTime,
    );

    _kv.pendingSessionId = null;

    return finished;
  }
}
