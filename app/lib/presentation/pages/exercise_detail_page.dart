import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../foundation/constants/enum_labels.dart';
import '../../foundation/models/exercise.dart';
import '../../foundation/utils/formatters.dart';
import '../providers/exercise_list_provider.dart';
import '../providers/training_provider.dart';

class ExerciseDetailPage extends ConsumerWidget {
  final String exerciseId;
  final bool pickMode;

  const ExerciseDetailPage({
    super.key,
    required this.exerciseId,
    this.pickMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(exerciseByIdProvider(exerciseId));
    final prDataAsync = _loadPrData(ref);

    return exerciseAsync.when(
      data: (exercise) {
        if (exercise == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('动作详情')),
            body: const Center(child: Text('动作不存在')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('动作详情'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.nameZh,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        '部位',
                        getBodyPartLabel(exercise.bodyPart),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        '器械',
                        getEquipmentLabel(exercise.equipment),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        '类型',
                        getExerciseTypeLabel(exercise.type),
                      ),
                      if (exercise.instructions != null) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          '动作说明',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exercise.instructions!,
                          style: const TextStyle(height: 1.5),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildPrCard(ref, exercise),
              const SizedBox(height: 100),
            ],
          ),
          bottomNavigationBar: pickMode
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FilledButton(
                      onPressed: () =>
                          _addAndBack(context, ref, exercise.id),
                      child: const Text('添加到本次训练'),
                    ),
                  ),
                )
              : null,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('动作详情')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Scaffold(
        appBar: AppBar(title: const Text('动作详情')),
        body: Center(child: Text('错误: $e')),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  AsyncValue<Map<String, double>> _loadPrData(WidgetRef ref) {
    return const AsyncValue.data({});
  }

  Widget _buildPrCard(WidgetRef ref, Exercise exercise) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '个人记录 PR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPrItem('最大重量', formatWeight(0)),
                _buildPrItem('最大1RM', formatWeight(0)),
                _buildPrItem('最大容量', formatVolume(0)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
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

  Future<void> _addAndBack(
    BuildContext context,
    WidgetRef ref,
    String exerciseId,
  ) async {
    final notifier = ref.read(trainingNotifierProvider.notifier);
    await notifier.ensureStarted();
    await notifier.addExercise(exerciseId);
    if (context.mounted) {
      Navigator.of(context)
        ..pop()
        ..pop();
    }
  }
}
