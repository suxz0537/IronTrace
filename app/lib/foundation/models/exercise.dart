enum BodyPart {
  chest,
  back,
  legs,
  shoulders,
  arms,
  core,
  cardio,
  fullBody,
}

enum Equipment {
  barbell,
  dumbbell,
  kettlebell,
  machine,
  cable,
  bodyweight,
  other,
}

enum ExerciseType {
  compound,
  isolation,
}

class Exercise {
  final String id;
  final String nameZh;
  final BodyPart bodyPart;
  final Equipment equipment;
  final ExerciseType type;
  final double? met;
  final String? instructions;
  final String? mediaUrl;
  final bool isCustom;
  final String? userId;

  const Exercise({
    required this.id,
    required this.nameZh,
    required this.bodyPart,
    required this.equipment,
    required this.type,
    this.met,
    this.instructions,
    this.mediaUrl,
    this.isCustom = false,
    this.userId,
  });

  Exercise copyWith({
    String? id,
    String? nameZh,
    BodyPart? bodyPart,
    Equipment? equipment,
    ExerciseType? type,
    double? met,
    String? instructions,
    String? mediaUrl,
    bool? isCustom,
    String? userId,
  }) {
    return Exercise(
      id: id ?? this.id,
      nameZh: nameZh ?? this.nameZh,
      bodyPart: bodyPart ?? this.bodyPart,
      equipment: equipment ?? this.equipment,
      type: type ?? this.type,
      met: met ?? this.met,
      instructions: instructions ?? this.instructions,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      isCustom: isCustom ?? this.isCustom,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise &&
        other.id == id &&
        other.nameZh == nameZh &&
        other.bodyPart == bodyPart &&
        other.equipment == equipment &&
        other.type == type &&
        other.met == met &&
        other.instructions == instructions &&
        other.mediaUrl == mediaUrl &&
        other.isCustom == isCustom &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      nameZh,
      bodyPart,
      equipment,
      type,
      met,
      instructions,
      mediaUrl,
      isCustom,
      userId,
    );
  }
}
