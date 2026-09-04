import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../foundation/models/exercise.dart';
import '../../foundation/models/workout.dart';
import '../../foundation/utils/formatters.dart';
import '../providers/exercise_list_provider.dart';
import '../providers/history_provider.dart';
import '../providers/training_provider.dart';
import '../widgets/empty_placeholder.dart';
import '../widgets/exercise_section.dart';

class HistoryDetailPage extends ConsumerWidget {
  final String sessionId;

  const HistoryDetailPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(historySessionProvider(sessionId));
    final sessionExercisesAsync =
        ref.watch(historySessionExercisesProvider(sessionId));
    final sessionSetsAsync =
        ref.watch(historySessionSetsProvider(sessionId));
    final allExercisesAsync = ref.watch(allExercisesProvider);

    return sessionAsync.when(
      data: (session) {
        if (session == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('训练详情')),
            body: const Center(child: Text('记录不存在')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(formatDate(session.startTime)),
          ),
          body: sessionExercisesAsync.when(
            data: (sessionExs) {
              if (sessionExs.isEmpty) {
                return const Center(
                  child: EmptyPlaceholder(text: '本次训练没有记录动作'),
                );
              }
              final sets = sessionSetsAsync.value ?? [];
              final allEx = allExercisesAsync.value ?? [];
              final exMap = {for (final e in allEx) e.id: e};

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: sessionExs.length + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return _buildSummaryCard(context, session, sets);
                  }
                  final se = sessionExs[i - 1];
                  final exSets = sets
                      .where((s) => s.sessionExerciseId == se.id)
                      .toList()
                    ..sort((a, b) => a.setNo.compareTo(b.setNo));
                  final exercise = exMap[se.exerciseId];
                  return ExerciseSection(
                    sessionExercise: se,
                    exercise: exercise,
                    sets: exSets,
                    enabled: false,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('错误: $e')),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.tonal(
                onPressed: () => _duplicateAsNew(context, ref),
                child: const Text('复制为新训练'),
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('训练详情')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Scaffold(
        appBar: AppBar(title: const Text('训练详情')),
        body: Center(child: Text('错误: $e')),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    WorkoutSession session,
    List<WorkoutSet> sets,
  ) {
    final exCount = sets.map((s) => s.sessionExerciseId).toSet().length;
    final totalSets = sets.length;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('总容量', formatVolume(session.totalVolume)),
                _buildStat('时长', '${session.durationMin ?? 0}分钟'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('动作数', '$exCount'),
                _buildStat('总组数', '$totalSets'),
              ],
            ),
            if (session.bodyWeight != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '训练时体重: ${formatWeight(session.bodyWeight!)}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _duplicateAsNew(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('复制为新训练'),
        content: const Text('将使用相同的动作开始一次新的训练，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('开始'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref
          .read(trainingNotifierProvider.notifier)
          .duplicateFromHistory(sessionId);
      final newSession = ref.read(trainingNotifierProvider).valueOrNull;
      if (newSession != null && context.mounted) {
        context.goNamed(
          'training',
          pathParameters: {'sessionId': newSession.id},
        );
      } else if (context.mounted) {
        context.goNamed('home');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }
}
