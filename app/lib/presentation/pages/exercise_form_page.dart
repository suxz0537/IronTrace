import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../foundation/constants/enum_labels.dart';
import '../../foundation/models/exercise.dart';
import '../providers/database_provider.dart';
import '../providers/exercise_list_provider.dart';
import '../providers/repository_providers.dart';

class ExerciseFormPage extends ConsumerStatefulWidget {
  const ExerciseFormPage({super.key});

  @override
  ConsumerState<ExerciseFormPage> createState() => _ExerciseFormPageState();
}

class _ExerciseFormPageState extends ConsumerState<ExerciseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();

  BodyPart _bodyPart = BodyPart.chest;
  Equipment _equipment = Equipment.barbell;
  ExerciseType _type = ExerciseType.compound;
  bool _isLoading = false;

  static const _uuid = Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加自定义动作'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '动作名称 *',
                border: OutlineInputBorder(),
                hintText: '例如：杠铃卧推',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return '请输入动作名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BodyPart>(
              value: _bodyPart,
              decoration: const InputDecoration(
                labelText: '训练部位 *',
                border: OutlineInputBorder(),
              ),
              items: BodyPart.values
                  .map((bp) => DropdownMenuItem(
                        value: bp,
                        child: Text(getBodyPartLabel(bp)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _bodyPart = v);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Equipment>(
              value: _equipment,
              decoration: const InputDecoration(
                labelText: '器械 *',
                border: OutlineInputBorder(),
              ),
              items: Equipment.values
                  .map((eq) => DropdownMenuItem(
                        value: eq,
                        child: Text(getEquipmentLabel(eq)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _equipment = v);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExerciseType>(
              value: _type,
              decoration: const InputDecoration(
                labelText: '动作类型 *',
                border: OutlineInputBorder(),
              ),
              items: ExerciseType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(getExerciseTypeLabel(t)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _type = v);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: '动作说明（可选）',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        '保存',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final kv = await ref.read(kvStorageProvider.future);
      final repo = await ref.read(exerciseRepoProvider.future);
      final exercise = Exercise(
        id: _uuid.v4(),
        nameZh: _nameController.text.trim(),
        bodyPart: _bodyPart,
        equipment: _equipment,
        type: _type,
        instructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
        isCustom: true,
        userId: kv.uid ?? 'local_user',
      );
      await repo.saveCustom(exercise);
      ref.invalidate(allExercisesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
