import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../foundation/models/workout.dart';
import 'database_provider.dart';
import 'repository_providers.dart';
import 'training_provider.dart';

part 'history_provider.g.dart';

@riverpod
Future<List<WorkoutSession>> completedSessions(
    CompletedSessionsRef ref) async {
  final repo = await ref.watch(workoutRepoProvider.future);
  final kv = await ref.watch(kvStorageProvider.future);
  final all = await repo.getSessions(kv.uid ?? 'local_user');
  return all.where((s) => s.isCompleted).toList();
}

@riverpod
Future<WorkoutSession?> historySession(HistorySessionRef ref, String id) async {
  final repo = await ref.watch(workoutRepoProvider.future);
  return repo.getSessionById(id);
}

@riverpod
Future<List<WorkoutSessionExercise>> historySessionExercises(
    HistorySessionExercisesRef ref, String sessionId) async {
  return ref.watch(sessionExercisesProvider(sessionId).future);
}

@riverpod
Future<List<WorkoutSet>> historySessionSets(
    HistorySessionSetsRef ref, String sessionId) async {
  return ref.watch(sessionSetsProvider(sessionId).future);
}

@riverpod
Future<void> deleteSession(DeleteSessionRef ref, String sessionId) async {
  final repo = await ref.watch(workoutRepoProvider.future);
  await repo.deleteSession(sessionId);
  ref.invalidate(completedSessionsProvider);
}
