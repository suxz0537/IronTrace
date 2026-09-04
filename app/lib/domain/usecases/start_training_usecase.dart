import '../repositories/i_workout_repository.dart';
import '../storage/kv_storage.dart';
import '../models/workout_session.dart';

class StartTrainingUseCase {
  final IWorkoutRepository _repo;
  final KvStorage _kv;

  StartTrainingUseCase(this._repo, this._kv);

  Future<WorkoutSession> execute({
    String uid = 'local_user',
    double? bodyWeight,
  }) async {
    final pending = await _repo.getPendingSession(uid);
    if (pending != null) {
      await _repo.finishSession(pending.id);
    }
    final s = await _repo.createSession(uid, bw: bodyWeight);
    _kv.pendingSessionId = s.id;
    return s;
  }
}
