import 'package:drift/drift.dart';
import 'app_database.dart';

part 'exercises_dao.g.dart';

@DriftAccessor(tables: [ExercisesTable])
abstract class ExercisesDao extends DatabaseAccessor<AppDatabase>
    with _$ExercisesDaoMixin {
  ExercisesDao(AppDatabase db) : super(db);

  Future<List<Exercise>> getAll() => (select(exercisesTable)
        ..orderBy([(t) => OrderingTerm.asc(t.id)]))
      .get();

  Future<List<Exercise>> getBuiltin() =>
      (select(exercisesTable)..where((t) => t.isCustom.equals(false))).get();

  Future<List<Exercise>> getCustom(String uid) => (select(exercisesTable)
        ..where((t) => t.isCustom.equals(true) & t.userId.equals(uid)))
      .get();

  Future<int> upsert(ExercisesTableCompanion c) =>
      into(exercisesTable).insertOnConflictUpdate(c);

  Future<int> deleteById(String id) =>
      (delete(exercisesTable)..where((t) => t.id.equals(id))).go();
}
