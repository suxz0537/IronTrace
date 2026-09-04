import '../database/app_database.dart';

abstract class IBodyMetricRepository {
  Future<List<BodyMetric>> getMetrics(String uid);
  Future<void> save(BodyMetric m);
}
