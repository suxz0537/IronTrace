import 'package:flutter/material.dart';

import '../../foundation/constants/enum_labels.dart';
import '../../foundation/models/exercise.dart';
import '../../foundation/models/workout.dart';
import 'set_card.dart';

class ExerciseSection extends StatelessWidget {
  final WorkoutSessionExercise sessionExercise;
  final Exercise? exercise;
  final List<WorkoutSet> sets;
  final bool enabled;
  final void Function(WorkoutSet s)? onSetChanged;
  final void Function(String sid)? onSetDeleted;
  final VoidCallback? onAddSet;
  final VoidCallback? onDuplicateLast;
  final VoidCallback? onRemove;

  const ExerciseSection({
    super.key,
    required this.sessionExercise,
    required this.exercise,
    required this.sets,
    this.enabled = true,
    this.onSetChanged,
    this.onSetDeleted,
    this.onAddSet,
    this.onDuplicateLast,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const Divider(height: 1, indent: 12, endIndent: 12),
          if (sets.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  '还没有添加组',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ...sets.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SetCard(
                  set: s,
                  enabled: enabled,
                  onChanged: onSetChanged,
                  onDelete: () => onSetDeleted?.call(s.id),
                  onDuplicate: onDuplicateLast,
                ),
              ),
            ),
          if (enabled) _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise?.nameZh ?? '未知动作',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (exercise != null)
                  Text(
                    getBodyPartLabel(exercise!.bodyPart),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          if (enabled)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onRemove,
              tooltip: '移除动作',
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextButton.icon(
        onPressed: onAddSet,
        icon: const Icon(Icons.add),
        label: const Text('添加一组'),
      ),
    );
  }
}
