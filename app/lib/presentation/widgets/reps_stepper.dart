import 'package:flutter/material.dart';

class RepsStepper extends StatelessWidget {
  final int initial;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const RepsStepper({
    super.key,
    required this.initial,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: enabled
              ? () => onChanged((initial - 1).clamp(1, 100).toInt())
              : null,
        ),
        Text(
          '$initial',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: enabled
              ? () => onChanged((initial + 1).clamp(1, 100).toInt())
              : null,
        ),
      ],
    );
  }
}
