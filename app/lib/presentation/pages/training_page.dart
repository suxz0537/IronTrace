import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../foundation/models/exercise.dart';
import '../../foundation/models/workout.dart';
import '../providers/exercise_list_provider.dart';
import '../providers/training_provider.dart';
import '../widgets/empty_placeholder.dart';
import '../widgets/exercise_picker.dart';
import '../widgets/exercise_section.dart';

class TrainingPage extends ConsumerStatefulWidget {
  final String sessionId;

  const TrainingPage({super.key, required this.sessionId});

  @override
  ConsumerState<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends ConsumerState<TrainingPage> {
  static const _uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    final trainingAsync = ref.watch(trainingNotifierProvider);
    final sessionExercisesAsync =
        ref.watch(sessionExercisesProvider(widget.sessionId));
    final sessionSetsAsync =
        ref.watch(sessionSetsProvider(widget.sessionId));
    final allExercisesAsync = ref.watch(allExercisesProvider);

    return trainingAsync.when(
      data: (session) {
        if (session == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('训练')),
            body: const Center(
              child: Text('没有进行中的训练'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('训练 (${sessionExercisesAsync.value?.length ?? 0}个动作)'),
            actions: [
              TextButton(
                onPressed: () => _confirmFinish(context),
                child: const Text(
                  '结束训练',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          body: sessionExercisesAsync.when(
            data: (sessionExs) {
              if (sessionExs.isEmpty) {
                return const Center(
                  child: EmptyPlaceholder(
                    text: '还没有添加动作，点击右下角按钮添加',
                  ),
                );
              }
              final sets = sessionSetsAsync.value ?? [];
              final allEx = allExercisesAsync.value ?? [];
              final exMap = {for (final e in allEx) e.id: e};

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: sessionExs.length,
                itemBuilder: (context, i) {
                  final se = sessionExs[i];
                  final exSets =
                      sets.where((s) => s.sessionExerciseId == se.id).toList()
                        ..sort((a, b) => a.setNo.compareTo(b.setNo));
                  final exercise = exMap[se.exerciseId];
                  return ExerciseSection(
                    sessionExercise: se,
                    exercise: exercise,
                    sets: exSets,
                    enabled: true,
                    onSetChanged: (s) => _onSetChanged(s),
                    onSetDeleted: (sid) => _onSetDeleted(sid),
                    onAddSet: () => _addSet(session, se, exercise),
                    onDuplicateLast: () => _duplicateLast(
                      exercise?.id ?? se.exerciseId,
                      se.id,
                    ),
                    onRemove: () => _removeExercise(context, se),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('错误: $e')),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _pickExercise(context),
            icon: const Icon(Icons.add),
            label: const Text('添加动作'),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('训练')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Scaffold(
        appBar: AppBar(title: const Text('训练')),
        body: Center(child: Text('错误: $e')),
      ),
    );
  }

  Future<void> _pickExercise(BuildContext context) async {
    final eid = await ExercisePicker.show(context);
    if (eid != null && mounted) {
      await ref.read(trainingNotifierProvider.notifier).addExercise(eid);
      ref.invalidate(sessionExercisesProvider(widget.sessionId));
      ref.invalidate(sessionSetsProvider(widget.sessionId));
    }
  }

  Future<void> _onSetChanged(WorkoutSet s) async {
    final updated = s.copyWith(completedAt: s.completedAt ?? DateTime.now());
    await ref.read(trainingNotifierProvider.notifier).recordSet(updated);
    ref.invalidate(sessionSetsProvider(widget.sessionId));
  }

  Future<void> _onSetDeleted(String sid) async {
    await ref.read(trainingNotifierProvider.notifier).deleteSet(sid);
    ref.invalidate(sessionSetsProvider(widget.sessionId));
  }

  Future<void> _addSet(
    WorkoutSession session,
    WorkoutSessionExercise se,
    Exercise? exercise,
  ) async {
    final sets = (await ref.read(sessionSetsProvider(session.id).future))
        .where((s) => s.sessionExerciseId == se.id)
        .toList()
      ..sort((a, b) => a.setNo.compareTo(b.setNo));

    final lastSet = sets.isNotEmpty ? sets.last : null;
    final newSetNo = (lastSet?.setNo ?? 0) + 1;
    final newSet = WorkoutSet(
      id: _uuid.v4(),
      sessionId: session.id,
      sessionExerciseId: se.id,
      exerciseId: se.exerciseId,
      setNo: newSetNo,
      weightKg: lastSet?.weightKg ?? 0,
      reps: lastSet?.reps ?? 8,
      rpe: lastSet?.rpe,
      restSec: lastSet?.restSec ?? 120,
      isWarmup: false,
      completedAt: null,
    );
    await ref.read(trainingNotifierProvider.notifier).recordSet(newSet);
    ref.invalidate(sessionSetsProvider(widget.sessionId));
  }

  Future<void> _duplicateLast(String exId, String sessionExId) async {
    await ref
        .read(trainingNotifierProvider.notifier)
        .duplicateLast(exId, sessionExId);
    ref.invalidate(sessionSetsProvider(widget.sessionId));
  }

  Future<void> _removeExercise(
    BuildContext context,
    WorkoutSessionExercise se,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认移除'),
        content: const Text('移除后该动作的所有组会被删除，确定吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              '移除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final sets = (await ref.read(sessionSetsProvider(widget.sessionId).future))
          .where((s) => s.sessionExerciseId == se.id);
      for (final s in sets) {
        await ref.read(trainingNotifierProvider.notifier).deleteSet(s.id);
      }
      ref.invalidate(sessionExercisesProvider(widget.sessionId));
      ref.invalidate(sessionSetsProvider(widget.sessionId));
    }
  }

  Future<void> _confirmFinish(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('结束训练'),
        content: const Text('确定结束本次训练吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('继续训练'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('结束'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(trainingNotifierProvider.notifier).finish();
      if (mounted) {
        context.goNamed('home');
      }
    }
  }
}
