import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/i_exercise_repository.dart';
import '../../data/repositories/i_workout_repository.dart';
import '../../data/repositories/impl/local_exercise_repo.dart';
import '../../data/repositories/impl/local_workout_repo.dart';
import 'database_provider.dart';

final exerciseRepoProvider = FutureProvider<IExerciseRepository>((ref) async {
  final dao = await ref.watch(exercisesDaoProvider.future);
  final repo = LocalExerciseRepo(dao);
  await repo.initBuiltinIfEmpty();
  return repo;
});

final workoutRepoProvider = FutureProvider<IWorkoutRepository>((ref) async {
  final dao = await ref.watch(workoutsDaoProvider.future);
  return LocalWorkoutRepo(dao);
});
