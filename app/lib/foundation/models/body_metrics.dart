class BodyMetric {
  final String id;
  final String userId;
  final DateTime date;
  final double? weightKg;
  final double? bodyFatPercent;
  final double? waistCm;

  const BodyMetric({
    required this.id,
    required this.userId,
    required this.date,
    this.weightKg,
    this.bodyFatPercent,
    this.waistCm,
  });

  BodyMetric copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? weightKg,
    double? bodyFatPercent,
    double? waistCm,
  }) {
    return BodyMetric(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
      waistCm: waistCm ?? this.waistCm,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BodyMetric &&
        other.id == id &&
        other.userId == userId &&
        other.date == date &&
        other.weightKg == weightKg &&
        other.bodyFatPercent == bodyFatPercent &&
        other.waistCm == waistCm;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      date,
      weightKg,
      bodyFatPercent,
      waistCm,
    );
  }
}
