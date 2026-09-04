import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../data/kv_storage/kv_storage.dart';
import '../../data/repositories/i_workout_repository.dart';
import '../../foundation/models/workout.dart';
import 'database_provider.dart';
import 'repository_providers.dart';

part 'training_provider.g.dart';

@riverpod
Future<WorkoutSession?> pendingSession(PendingSessionRef ref) async {
  final repo = await ref.watch(workoutRepoProvider.future);
  final kv = await ref.watch(kvStorageProvider.future);
  return repo.getPendingSession(kv.uid ?? 'local_user');
}

@riverpod
class TrainingNotifier extends _$TrainingNotifier {
  late IWorkoutRepository _repo;
  late KvStorage _kv;
  static const _uuid = Uuid();

  @override
  FutureOr<WorkoutSession?> build() async {
    _repo = await ref.watch(workoutRepoProvider.future);
    _kv = await ref.watch(kvStorageProvider.future);
    final sid = _kv.pendingSessionId;
    return sid == null ? null : _repo.getSessionById(sid);
  }

  Future<WorkoutSession> _startTrainingInternal({double? bw}) async {
    final uid = _kv.uid ?? 'local_user';
    final pending = await _repo.getPendingSession(uid);
    if (pending != null) {
      await _repo.finishSession(pending.id);
    }
    final s = await _repo.createSession(uid, bw: bw);
    _kv.pendingSessionId = s.id;
    return s;
  }

  Future<void> startTraining({double? bw}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _startTrainingInternal(bw: bw);
    });
    ref.invalidate(pendingSessionProvider);
  }

  Future<void> resumeOrStart() async {
    final current = state.value;
    if (current != null) {
      return;
    }
    await startTraining();
  }

  Future<void> addExercise(String eid) async {
    final session = state.value;
    if (session == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.addExerciseToSession(session.id, eid);
      return _repo.getSessionById(session.id);
    });
    ref.invalidateSelf();
  }

  Future<void> recordSet(WorkoutSet s) async {
    final session = state.value;
    if (session == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.upsertSet(s);
      return _repo.getSessionById(session.id);
    });
  }

  Future<void> deleteSet(String sid) async {
    final session = state.value;
    if (session == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.deleteSet(sid);
      return _repo.getSessionById(session.id);
    });
  }

  Future<void> duplicateLast(String exId, String sessionExId) async {
    final session = state.value;
    if (session == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final sets = await _repo.getSetsBySession(session.id);
      final exSets = sets.where((s) => s.sessionExerciseId == sessionExId).toList()
        ..sort((a, b) => b.setNo.compareTo(a.setNo));
      if (exSets.isEmpty) {
        throw StateError('No sets found in exercise: $sessionExId');
      }
      final last = exSets.first;
      final newSetNo = last.setNo + 1;
      final newId = _uuid.v4();
      final duplicated = WorkoutSet(
        id: newId,
        sessionId: session.id,
        sessionExerciseId: sessionExId,
        exerciseId: exId,
        setNo: newSetNo,
        weightKg: last.weightKg,
        reps: last.reps,
        rpe: last.rpe,
        restSec: last.restSec,
        isWarmup: last.isWarmup,
        completedAt: null,
      );
      await _repo.upsertSet(duplicated);
      return _repo.getSessionById(session.id);
    });
  }

  Future<void> finish() async {
    final session = state.value;
    if (session == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.finishSession(session.id);
      _kv.pendingSessionId = null;
      return null;
    });
    ref.invalidate(pendingSessionProvider);
  }

  Future<WorkoutSession> ensureStarted({double? bw}) async {
    final current = state.valueOrNull;
    if (current != null) return current;
    final result = await _startTrainingInternal(bw: bw);
    state = AsyncValue.data(result);
    ref.invalidate(pendingSessionProvider);
    return result;
  }

  Future<void> duplicateFromHistory(String sessionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final srcSession = await _repo.getSessionById(sessionId);
      if (srcSession == null) {
        throw StateError('Source session not found');
      }
      final newSession = await _startTrainingInternal(bw: srcSession.bodyWeight);
      final srcSets = await _repo.getSetsBySession(sessionId);
      final groupedBySeId = <String, List<WorkoutSet>>{};
      for (final s in srcSets) {
        groupedBySeId.putIfAbsent(s.sessionExerciseId, () => []).add(s);
      }
      final seIdOrder = groupedBySeId.keys.toList();
      for (final seId in seIdOrder) {
        final firstSet = groupedBySeId[seId]!.first;
        await _repo.addExerciseToSession(newSession.id, firstSet.exerciseId);
      }
      final updatedExercises = await _repo.getSessionExercises(newSession.id);
      final sortedExercises = updatedExercises.toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      for (var i = 0; i < seIdOrder.length && i < sortedExercises.length; i++) {
        final srcSeId = seIdOrder[i];
        final newSe = sortedExercises[i];
        final srcSetsList = groupedBySeId[srcSeId] ?? [];
        srcSetsList.sort((a, b) => a.setNo.compareTo(b.setNo));
        for (final srcSet in srcSetsList) {
          final newSet = WorkoutSet(
            id: _uuid.v4(),
            sessionId: newSession.id,
            sessionExerciseId: newSe.id,
            exerciseId: newSe.exerciseId,
            setNo: srcSet.setNo,
            weightKg: srcSet.weightKg,
            reps: srcSet.reps,
            rpe: srcSet.rpe,
            restSec: srcSet.restSec,
            isWarmup: srcSet.isWarmup,
            completedAt: null,
          );
          await _repo.upsertSet(newSet);
        }
      }
      return newSession;
    });
    ref.invalidate(pendingSessionProvider);
  }
}

@riverpod
Future<List<WorkoutSessionExercise>> sessionExercises(
    SessionExercisesRef ref, String sessionId) async {
  final repo = await ref.watch(workoutRepoProvider.future);
  return repo.getSessionExercises(sessionId);
}

@riverpod
Future<List<WorkoutSet>> sessionSets(SessionSetsRef ref, String sessionId) async {
  final repo = await ref.watch(workoutRepoProvider.future);
  return repo.getSetsBySession(sessionId);
}
