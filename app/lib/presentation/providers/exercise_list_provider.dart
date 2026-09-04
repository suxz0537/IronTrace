import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../foundation/models/exercise.dart';
import 'repository_providers.dart';

part 'exercise_list_provider.g.dart';

@riverpod
Future<List<Exercise>> allExercises(AllExercisesRef ref) async {
  final repo = await ref.watch(exerciseRepoProvider.future);
  return repo.getAllExercises();
}

@riverpod
Future<List<Exercise>> searchExercises(
  SearchExercisesRef ref, {
  String keyword = '',
  BodyPart? bodyPart,
}) async {
  final all = await ref.watch(allExercisesProvider.future);
  return all.where((e) {
    final matchKeyword = keyword.isEmpty ||
        e.nameZh.toLowerCase().contains(keyword.toLowerCase());
    final matchPart = bodyPart == null || e.bodyPart == bodyPart;
    return matchKeyword && matchPart;
  }).toList();
}

@riverpod
Future<Exercise?> exerciseById(ExerciseByIdRef ref, String id) async {
  final all = await ref.watch(allExercisesProvider.future);
  for (final e in all) {
    if (e.id == id) return e;
  }
  return null;
}
