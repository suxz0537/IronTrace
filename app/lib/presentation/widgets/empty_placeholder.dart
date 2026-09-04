import 'package:flutter/material.dart';

class EmptyPlaceholder extends StatelessWidget {
  final String text;
  final IconData icon;

  const EmptyPlaceholder({
    super.key,
    required this.text,
    this.icon = Icons.fitness_center_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 64,
          color: Colors.grey,
        ),
        const SizedBox(height: 12),
        Text(
          text,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
