import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../database/app_database.dart';
import '../../database/exercises_dao.dart';
import '../i_exercise_repository.dart';

class LocalExerciseRepo implements IExerciseRepository {
  LocalExerciseRepo(this._dao);

  final ExercisesDao _dao;
  static const _uuid = Uuid();

  @override
  Future<List<Exercise>> getAllExercises() => _dao.getAll();

  @override
  Future<List<Exercise>> getBuiltin() => _dao.getBuiltin();

  @override
  Future<List<Exercise>> getCustom(String uid) => _dao.getCustom(uid);

  @override
  Future<void> saveCustom(Exercise e) async {
    final companion = ExercisesTableCompanion(
      id: Value(e.id.isEmpty ? _uuid.v4() : e.id),
      nameZh: Value(e.nameZh),
      bodyPart: Value(e.bodyPart),
      equipment: Value(e.equipment),
      type: Value(e.type),
      met: Value(e.met),
      instructions: Value(e.instructions),
      mediaUrl: Value(e.mediaUrl),
      isCustom: const Value(true),
      userId: Value(e.userId),
      createdAt: Value(e.createdAt),
      updatedAt: Value(DateTime.now()),
    );
    await _dao.upsert(companion);
  }

  @override
  Future<void> initBuiltinIfEmpty() async {
    final existing = await _dao.getBuiltin();
    if (existing.isNotEmpty) return;

    final jsonStr =
        await rootBundle.loadString('assets/data/builtin_exercises.json');
    final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;

    final now = DateTime.now();
    for (final item in list) {
      final map = item as Map<String, dynamic>;
      final companion = ExercisesTableCompanion(
        id: Value(map['id'] as String? ?? _uuid.v4()),
        nameZh: Value(map['nameZh'] as String),
        bodyPart: Value(map['bodyPart'] as String),
        equipment: Value(map['equipment'] as String? ?? ''),
        type: Value(map['type'] as String? ?? ''),
        met: Value((map['met'] as num?)?.toDouble()),
        instructions: Value(map['instructions'] as String?),
        mediaUrl: Value(map['mediaUrl'] as String?),
        isCustom: const Value(false),
        userId: const Value.absent(),
        createdAt: Value(now),
        updatedAt: const Value.absent(),
      );
      await _dao.upsert(companion);
    }
  }
}
