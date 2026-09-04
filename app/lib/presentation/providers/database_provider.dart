import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/database/exercises_dao.dart';
import '../../data/database/workouts_dao.dart';
import '../../data/kv_storage/kv_storage.dart';

final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  return AppDatabase();
});

final exercisesDaoProvider = FutureProvider<ExercisesDao>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return ExercisesDao(db);
});

final workoutsDaoProvider = FutureProvider<WorkoutsDao>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return WorkoutsDao(db);
});

final kvStorageProvider = FutureProvider<KvStorage>((ref) async {
  return KvStorage.init();
});
