import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../foundation/constants/enum_labels.dart';
import '../../foundation/models/exercise.dart';
import '../providers/exercise_list_provider.dart';
import '../widgets/body_part_chip.dart';
import '../widgets/empty_placeholder.dart';

class ExerciseListPage extends ConsumerStatefulWidget {
  final bool pickMode;

  const ExerciseListPage({super.key, this.pickMode = false});

  @override
  ConsumerState<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends ConsumerState<ExerciseListPage> {
  String _keyword = '';
  BodyPart? _bodyPart;

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchExercisesProvider(
      keyword: _keyword,
      bodyPart: _bodyPart,
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pickMode ? '选择动作' : '动作库'),
        actions: [
          if (!widget.pickMode)
            IconButton(
              onPressed: () => context.pushNamed('exerciseAdd'),
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              leading: const Icon(Icons.search),
              hintText: '搜索动作',
              onChanged: (v) => setState(() => _keyword = v),
            ),
          ),
          SizedBox(
            height: 48,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: const Text('全部'),
                      selected: _bodyPart == null,
                      onSelected: (_) => setState(() => _bodyPart = null),
                    ),
                  ),
                  ...BodyPart.values.map(
                    (bp) => BodyPartChip(
                      part: bp,
                      isSelected: _bodyPart == bp,
                      onSelected: (_) => setState(() => _bodyPart = bp),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: results.when(
              data: (list) => list.isEmpty
                  ? Center(
                      child: EmptyPlaceholder(
                        text: _keyword.isEmpty
                            ? '还没有动作，去添加一个吧'
                            : '没有找到匹配的动作',
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (_, i) {
                        final item = list[i];
                        return ListTile(
                          title: Text(item.nameZh),
                          subtitle: Text(getBodyPartLabel(item.bodyPart)),
                          trailing: Icon(
                            widget.pickMode
                                ? Icons.check_circle_outline
                                : Icons.arrow_forward_ios,
                            size: widget.pickMode ? 28 : 18,
                            color: widget.pickMode
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                          ),
                          onTap: () {
                            if (widget.pickMode) {
                              Navigator.pop(context, item.id);
                            } else {
                              context.pushNamed(
                                'exerciseDetail',
                                pathParameters: {'id': item.id},
                              );
                            }
                          },
                        );
                      },
                    ),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('错误: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
