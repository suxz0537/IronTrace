import '../database/app_database.dart';

abstract class IWorkoutRepository {
  Future<List<WorkoutSession>> getSessions(String uid);
  Future<WorkoutSession?> getSessionById(String sid);
  Future<WorkoutSession?> getPendingSession(String uid);
  Future<WorkoutSession> createSession(String uid, {double? bw});
  Future<void> finishSession(String sid);
  Future<void> addExerciseToSession(String sid, String eid);
  Future<void> upsertSet(WorkoutSet s);
  Future<void> deleteSet(String sid);
  Future<List<WorkoutSet>> getSetsBySession(String sid);
  Future<List<WorkoutSet>> getLastSetsOfExercise(String uid, String eid,
      {int limit = 5});
  Future<List<WorkoutSessionExercise>> getSessionExercises(String sid);
  Future<void> deleteSession(String sid);
}
