import 'package:flutter/material.dart';

import '../../foundation/constants/enum_labels.dart';
import '../../foundation/models/exercise.dart';

class BodyPartChip extends StatelessWidget {
  final BodyPart part;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;

  const BodyPartChip({
    super.key,
    required this.part,
    this.isSelected = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(getBodyPartLabel(part)),
        selected: isSelected,
        onSelected: onSelected,
      ),
    );
  }
}
