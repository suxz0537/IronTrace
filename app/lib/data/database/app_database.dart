import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class ExercisesTable extends Table {
  TextColumn get id => text()();
  TextColumn get nameZh => text()();
  TextColumn get bodyPart => text()();
  TextColumn get equipment => text()();
  TextColumn get type => text()();
  RealColumn get met => real().nullable()();
  TextColumn get instructions => text().nullable()();
  TextColumn get mediaUrl => text().nullable()();
  BooleanColumn get isCustom => boolean()();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class WorkoutSessionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get durationMin => integer().nullable()();
  RealColumn get bodyWeight => real().nullable()();
  RealColumn get totalVolume => real()();
  TextColumn get note => text().nullable()();
  BooleanColumn get isCompleted => boolean()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class WorkoutSessionExercisesTable extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get exerciseId => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class WorkoutSetsTable extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get exerciseId => text()();
  TextColumn get sessionExerciseId => text()();
  IntColumn get setNo => integer()();
  RealColumn get weightKg => real()();
  IntColumn get reps => integer()();
  IntColumn get rpe => integer().nullable()();
  IntColumn get restSec => integer().withDefault(const Constant(120))();
  BooleanColumn get isWarmup => boolean()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class BodyMetricsTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get bodyFatPercent => real().nullable()();
  RealColumn get waistCm => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  ExercisesTable,
  WorkoutSessionsTable,
  WorkoutSessionExercisesTable,
  WorkoutSetsTable,
  BodyMetricsTable,
], daos: [
  BodyMetricsDao,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() => LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'irontrace.sqlite'));
      return NativeDatabase(file);
    });

abstract class BodyMetricsDao extends DatabaseAccessor<AppDatabase>
    with _$BodyMetricsDaoMixin {
  BodyMetricsDao(AppDatabase db) : super(db);

  Future<List<BodyMetric>> getByUserId(String uid) =>
      (select(bodyMetricsTable)..where((t) => t.userId.equals(uid))).get();

  Future<int> upsert(BodyMetricsTableCompanion c) =>
      into(bodyMetricsTable).insertOnConflictUpdate(c);
}
