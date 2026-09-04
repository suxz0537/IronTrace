import 'package:flutter/material.dart';

import '../../foundation/models/workout.dart';
import 'reps_stepper.dart';
import 'weight_stepper.dart';

class SetCard extends StatelessWidget {
  final WorkoutSet set;
  final bool enabled;
  final void Function(WorkoutSet s)? onChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const SetCard({
    super.key,
    required this.set,
    this.enabled = true,
    this.onChanged,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                '第${set.setNo}组',
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: WeightStepper(
                initial: set.weightKg,
                enabled: enabled,
                onChanged: (v) => onChanged?.call(set.copyWith(weightKg: v)),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: RepsStepper(
                initial: set.reps,
                enabled: enabled,
                onChanged: (v) => onChanged?.call(set.copyWith(reps: v)),
              ),
            ),
            const SizedBox(width: 4),
            Switch(
              value: set.isWarmup,
              onChanged: enabled
                  ? (v) => onChanged?.call(set.copyWith(isWarmup: v))
                  : null,
            ),
            Text(
              '热身',
              style: TextStyle(
                fontSize: 12,
                color: set.isWarmup ? Colors.orange : Colors.grey,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: enabled ? onDuplicate : null,
              tooltip: '复制上一组',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: enabled ? onDelete : null,
              tooltip: '删除',
            ),
          ],
        ),
      ),
    );
  }
}
