import 'package:drift/drift.dart';
import 'app_database.dart';

part 'workouts_dao.g.dart';

@DriftAccessor(tables: [
  WorkoutSessionsTable,
  WorkoutSessionExercisesTable,
  WorkoutSetsTable,
])
abstract class WorkoutsDao extends DatabaseAccessor<AppDatabase>
    with _$WorkoutsDaoMixin {
  WorkoutsDao(AppDatabase db) : super(db);

  Future<List<WorkoutSession>> getCompletedSessions(String userId) =>
      (select(workoutSessionsTable)
            ..where((t) => t.userId.equals(userId) & t.isCompleted.equals(true))
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .get();

  Future<List<WorkoutSession>> getAllSessions(String userId) =>
      (select(workoutSessionsTable)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .get();

  Future<WorkoutSession?> getPending(String uid) async {
    final result = await (select(workoutSessionsTable)
          ..where((t) => t.userId.equals(uid) & t.isCompleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .get();
    return result.isNotEmpty ? result.first : null;
  }

  Future<WorkoutSession?> getSessionById(String sid) async {
    final result = await (select(workoutSessionsTable)
          ..where((t) => t.id.equals(sid))
          ..limit(1))
        .get();
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> saveSession(WorkoutSessionsTableCompanion c) =>
      into(workoutSessionsTable).insertOnConflictUpdate(c);

  Future<int> finishSession(
      String sid, WorkoutSessionsTableCompanion c) async {
    return (update(workoutSessionsTable)..where((t) => t.id.equals(sid)))
        .write(c);
  }

  Future<int> addSessionExercise(WorkoutSessionExercisesTableCompanion c) =>
      into(workoutSessionExercisesTable).insertOnConflictUpdate(c);

  Future<List<WorkoutSessionExercise>> getSessionExercises(String sid) =>
      (select(workoutSessionExercisesTable)
            ..where((t) => t.sessionId.equals(sid))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Future<int> upsertSet(WorkoutSetsTableCompanion c) =>
      into(workoutSetsTable).insertOnConflictUpdate(c);

  Future<int> deleteSet(String sid) =>
      (delete(workoutSetsTable)..where((t) => t.id.equals(sid))).go();

  Future<List<WorkoutSet>> getSetsBySession(String sid) =>
      (select(workoutSetsTable)
            ..where((t) => t.sessionId.equals(sid))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<List<WorkoutSet>> getLastSetsOfExercise(
      String uid, String eid, int limit) {
    final query = select(workoutSetsTable).join([
      innerJoin(workoutSessionsTable,
          workoutSessionsTable.id.equalsExp(workoutSetsTable.sessionId)),
    ])
      ..where(workoutSessionsTable.userId.equals(uid) &
          workoutSetsTable.exerciseId.equals(eid) &
          workoutSessionsTable.isCompleted.equals(true))
      ..orderBy([OrderingTerm.desc(workoutSessionsTable.startTime)])
      ..limit(limit);
    return query.map((row) => row.readTable(workoutSetsTable)).get();
  }

  Future<int> deleteSession(String sid) async {
    await (delete(workoutSetsTable)
          ..where((t) => t.sessionId.equals(sid)))
        .go();
    await (delete(workoutSessionExercisesTable)
          ..where((t) => t.sessionId.equals(sid)))
        .go();
    return (delete(workoutSessionsTable)
          ..where((t) => t.id.equals(sid)))
        .go();
  }
}
