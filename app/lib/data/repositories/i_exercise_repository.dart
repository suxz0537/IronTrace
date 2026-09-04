import '../database/app_database.dart';

abstract class IExerciseRepository {
  Future<List<Exercise>> getAllExercises();
  Future<List<Exercise>> getBuiltin();
  Future<List<Exercise>> getCustom(String uid);
  Future<void> saveCustom(Exercise e);
  Future<void> initBuiltinIfEmpty();
}
