import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/i_workout_repository.dart';
import '../../foundation/models/workout.dart';
import '../../foundation/utils/formatters.dart';
import '../providers/history_provider.dart';
import '../providers/repository_providers.dart';
import '../widgets/empty_placeholder.dart';

class HistoryListPage extends ConsumerStatefulWidget {
  const HistoryListPage({super.key});

  @override
  ConsumerState<HistoryListPage> createState() => _HistoryListPageState();
}

class _HistoryListPageState extends ConsumerState<HistoryListPage> {
  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(completedSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史训练'),
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(
              child: EmptyPlaceholder(text: '还没有完成的训练'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final s = sessions[i];
              return Dismissible(
                key: ValueKey(s.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDelete(s),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                child: _buildCard(s),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('错误: $e')),
      ),
    );
  }

  Widget _buildCard(WorkoutSession s) {
    final setsAsync = ref.watch(historySessionSetsProvider(s.id));
    final exerciseCount = setsAsync.maybeWhen(
      data: (sets) => sets.map((se) => se.sessionExerciseId).toSet().length,
      orElse: () => 0,
    );

    return Card(
      child: ListTile(
        title: Text(formatDate(s.startTime)),
        subtitle: Text(
          '${formatVolume(s.totalVolume)}·'
          '${s.durationMin ?? 0}分钟·'
          '$exerciseCount个动作',
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => context.pushNamed(
          'historyDetail',
          pathParameters: {'id': s.id},
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(WorkoutSession s) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除训练记录'),
        content: Text('确定要删除 ${formatDate(s.startTime)} 的训练记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx, true);
              await _delete(s.id);
            },
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(String sid) async {
    try {
      final IWorkoutRepository repo =
          await ref.read(workoutRepoProvider.future);
      await repo.deleteSession(sid);
      ref.invalidate(completedSessionsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已删除')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }
}
