import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../foundation/utils/formatters.dart';
import '../providers/training_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('铁迹 IronTrace'),
      ),
      body: pending.when(
        data: (p) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (p != null)
              Card(
                child: ListTile(
                  title: const Text('上次训练未结束'),
                  subtitle: Text(formatDate(p.startTime)),
                  trailing: ElevatedButton(
                    onPressed: () => ref
                        .read(trainingNotifierProvider.notifier)
                        .resumeOrStart(),
                    child: const Text('继续训练'),
                  ),
                  onTap: () => context.pushNamed(
                    'training',
                    pathParameters: {'sessionId': p.id},
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Center(
              child: FilledButton.tonal(
                onPressed: () => ref
                    .read(trainingNotifierProvider.notifier)
                    .startTraining(),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '开始训练',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ListTile(
              title: const Text('历史训练'),
              trailing: TextButton(
                onPressed: () => context.pushNamed('historyList'),
                child: const Text('查看全部'),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('错误: $e')),
      ),
    );
  }
}
