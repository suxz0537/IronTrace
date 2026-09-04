import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../foundation/constants/enum_labels.dart';
import '../../foundation/models/exercise.dart';
import '../providers/exercise_list_provider.dart';
import 'empty_placeholder.dart';

class ExercisePicker extends ConsumerStatefulWidget {
  const ExercisePicker({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ExercisePicker(),
    );
  }

  @override
  ConsumerState<ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends ConsumerState<ExercisePicker> {
  String _keyword = '';
  BodyPart? _bodyPart;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        final results = ref.watch(searchExercisesProvider(
          keyword: _keyword,
          bodyPart: _bodyPart,
        ));
        return Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildBodyPartFilter(),
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
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: list.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 16, endIndent: 16),
                        itemBuilder: (_, i) {
                          final item = list[i];
                          return ListTile(
                            title: Text(item.nameZh),
                            subtitle: Text(
                              getBodyPartLabel(item.bodyPart),
                            ),
                            trailing: const Icon(Icons.add_circle_outline),
                            onTap: () => Navigator.pop(context, item.id),
                          );
                        },
                      ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('错误: $e')),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '选择动作',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SearchBar(
        leading: const Icon(Icons.search),
        hintText: '搜索动作',
        onChanged: (v) => setState(() => _keyword = v),
      ),
    );
  }

  Widget _buildBodyPartFilter() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
            (bp) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(getBodyPartLabel(bp)),
                selected: _bodyPart == bp,
                onSelected: (_) => setState(() => _bodyPart = bp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
