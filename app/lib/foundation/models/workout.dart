class WorkoutSession {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMin;
  final double? bodyWeight;
  final double totalVolume;
  final String? note;
  final bool isCompleted;

  const WorkoutSession({
    required this.id,
    required this.userId,
    required this.startTime,
    this.endTime,
    this.durationMin,
    this.bodyWeight,
    this.totalVolume = 0.0,
    this.note,
    this.isCompleted = false,
  });

  WorkoutSession copyWith({
    String? id,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMin,
    double? bodyWeight,
    double? totalVolume,
    String? note,
    bool? isCompleted,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMin: durationMin ?? this.durationMin,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      totalVolume: totalVolume ?? this.totalVolume,
      note: note ?? this.note,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutSession &&
        other.id == id &&
        other.userId == userId &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.durationMin == durationMin &&
        other.bodyWeight == bodyWeight &&
        other.totalVolume == totalVolume &&
        other.note == note &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      startTime,
      endTime,
      durationMin,
      bodyWeight,
      totalVolume,
      note,
      isCompleted,
    );
  }
}

class WorkoutSessionExercise {
  final String id;
  final String sessionId;
  final String exerciseId;
  final int sortOrder;

  const WorkoutSessionExercise({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.sortOrder,
  });

  WorkoutSessionExercise copyWith({
    String? id,
    String? sessionId,
    String? exerciseId,
    int? sortOrder,
  }) {
    return WorkoutSessionExercise(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutSessionExercise &&
        other.id == id &&
        other.sessionId == sessionId &&
        other.exerciseId == exerciseId &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      sessionId,
      exerciseId,
      sortOrder,
    );
  }
}

class WorkoutSet {
  final String id;
  final String sessionId;
  final String exerciseId;
  final String sessionExerciseId;
  final int setNo;
  final double weightKg;
  final int reps;
  final int? rpe;
  final int restSec;
  final bool isWarmup;
  final DateTime? completedAt;

  const WorkoutSet({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.sessionExerciseId,
    required this.setNo,
    required this.weightKg,
    required this.reps,
    this.rpe,
    required this.restSec,
    this.isWarmup = false,
    this.completedAt,
  });

  WorkoutSet copyWith({
    String? id,
    String? sessionId,
    String? exerciseId,
    String? sessionExerciseId,
    int? setNo,
    double? weightKg,
    int? reps,
    int? rpe,
    int? restSec,
    bool? isWarmup,
    DateTime? completedAt,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
      setNo: setNo ?? this.setNo,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      restSec: restSec ?? this.restSec,
      isWarmup: isWarmup ?? this.isWarmup,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutSet &&
        other.id == id &&
        other.sessionId == sessionId &&
        other.exerciseId == exerciseId &&
        other.sessionExerciseId == sessionExerciseId &&
        other.setNo == setNo &&
        other.weightKg == weightKg &&
        other.reps == reps &&
        other.rpe == rpe &&
        other.restSec == restSec &&
        other.isWarmup == isWarmup &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      sessionId,
      exerciseId,
      sessionExerciseId,
      setNo,
      weightKg,
      reps,
      rpe,
      restSec,
      isWarmup,
      completedAt,
    );
  }
}
