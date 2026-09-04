import 'package:uuid/uuid.dart';
import '../../database/app_database.dart';
import '../i_body_metric_repository.dart';

class LocalBodyMetricRepo implements IBodyMetricRepository {
  LocalBodyMetricRepo(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  @override
  Future<List<BodyMetric>> getMetrics(String uid) =>
      _db.bodyMetricsDao.getByUserId(uid);

  @override
  Future<void> save(BodyMetric m) async {
    final companion = BodyMetricsTableCompanion(
      id: Value(m.id.isEmpty ? _uuid.v4() : m.id),
      userId: Value(m.userId),
      date: Value(m.date),
      weightKg: Value(m.weightKg),
      bodyFatPercent: Value(m.bodyFatPercent),
      waistCm: Value(m.waistCm),
      createdAt: Value(m.createdAt),
    );
    await _db.bodyMetricsDao.upsert(companion);
  }
}
