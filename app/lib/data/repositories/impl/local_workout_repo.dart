import 'package:uuid/uuid.dart';
import '../../database/app_database.dart';
import '../../database/workouts_dao.dart';
import '../i_workout_repository.dart';

class LocalWorkoutRepo implements IWorkoutRepository {
  LocalWorkoutRepo(this._dao);

  final WorkoutsDao _dao;
  static const _uuid = Uuid();

  @override
  Future<List<WorkoutSession>> getSessions(String uid) =>
      _dao.getAllSessions(uid);

  @override
  Future<WorkoutSession?> getSessionById(String sid) =>
      _dao.getSessionById(sid);

  @override
  Future<WorkoutSession?> getPendingSession(String uid) =>
      _dao.getPending(uid);

  @override
  Future<WorkoutSession> createSession(String uid, {double? bw}) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final companion = WorkoutSessionsTableCompanion(
      id: Value(id),
      userId: Value(uid),
      startTime: Value(now),
      endTime: const Value.absent(),
      durationMin: const Value.absent(),
      bodyWeight: Value(bw),
      totalVolume: const Value(0),
      note: const Value.absent(),
      isCompleted: const Value(false),
      createdAt: Value(now),
    );
    await _dao.saveSession(companion);
    final saved = await _dao.getSessionById(id);
    if (saved == null) {
      throw StateError('Failed to create workout session');
    }
    return saved;
  }

  @override
  Future<void> finishSession(String sid) async {
    final session = await _dao.getSessionById(sid);
    if (session == null) return;

    final now = DateTime.now();
    final duration = now.difference(session.startTime).inMinutes;

    final sets = await _dao.getSetsBySession(sid);
    final totalVolume = sets.fold<double>(
      0,
      (sum, s) => sum + (s.weightKg * s.reps.toDouble()),
    );

    final companion = WorkoutSessionsTableCompanion(
      endTime: Value(now),
      durationMin: Value(duration),
      totalVolume: Value(totalVolume),
      isCompleted: const Value(true),
    );
    await _dao.finishSession(sid, companion);
  }

  @override
  Future<void> addExerciseToSession(String sid, String eid) async {
    final existing = await _dao.getSessionExercises(sid);
    final nextOrder = existing.isEmpty ? 0 : existing.length;

    final companion = WorkoutSessionExercisesTableCompanion(
      id: Value(_uuid.v4()),
      sessionId: Value(sid),
      exerciseId: Value(eid),
      sortOrder: Value(nextOrder),
    );
    await _dao.addSessionExercise(companion);
  }

  @override
  Future<void> upsertSet(WorkoutSet s) async {
    final companion = WorkoutSetsTableCompanion(
      id: Value(s.id.isEmpty ? _uuid.v4() : s.id),
      sessionId: Value(s.sessionId),
      exerciseId: Value(s.exerciseId),
      sessionExerciseId: Value(s.sessionExerciseId),
      setNo: Value(s.setNo),
      weightKg: Value(s.weightKg),
      reps: Value(s.reps),
      rpe: Value(s.rpe),
      restSec: Value(s.restSec),
      isWarmup: Value(s.isWarmup),
      completedAt: Value(s.completedAt),
      createdAt: Value(s.createdAt),
    );
    await _dao.upsertSet(companion);
  }

  @override
  Future<void> deleteSet(String sid) => _dao.deleteSet(sid);

  @override
  Future<List<WorkoutSet>> getSetsBySession(String sid) =>
      _dao.getSetsBySession(sid);

  @override
  Future<List<WorkoutSet>> getLastSetsOfExercise(String uid, String eid,
          {int limit = 5}) =>
      _dao.getLastSetsOfExercise(uid, eid, limit);

  @override
  Future<List<WorkoutSessionExercise>> getSessionExercises(String sid) =>
      _dao.getSessionExercises(sid);

  @override
  Future<void> deleteSession(String sid) => _dao.deleteSession(sid);
}
