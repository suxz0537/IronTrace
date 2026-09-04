import 'package:flutter/material.dart';

class WeightStepper extends StatelessWidget {
  final double initial;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const WeightStepper({
    super.key,
    required this.initial,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final decimals = initial.truncateToDouble() == initial ? 0 : 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: enabled
              ? () => onChanged((initial - 0.5).clamp(0, 1000).toDouble())
              : null,
        ),
        Text(
          initial.toStringAsFixed(decimals),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: enabled
              ? () => onChanged((initial + 0.5).clamp(0, 1000).toDouble())
              : null,
        ),
        TextButton(
          onPressed: enabled
              ? () => onChanged((initial + 1.25).clamp(0, 1000).toDouble())
              : null,
          child: const Text('+1.25'),
        ),
        TextButton(
          onPressed: enabled
              ? () => onChanged((initial + 2.5).clamp(0, 1000).toDouble())
              : null,
          child: const Text('+2.5'),
        ),
      ],
    );
  }
}
