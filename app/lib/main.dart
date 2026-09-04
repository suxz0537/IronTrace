import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:irontrace/presentation/routes/app_router.dart';
import 'package:irontrace/presentation/theme/app_theme.dart';
import 'package:irontrace/data/kv_storage/kv_storage.dart';
import 'package:irontrace/data/repositories/i_exercise_repository.dart';
import 'package:irontrace/presentation/providers/repository_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KvStorage.init();
  runApp(const ProviderScope(child: IronTraceApp()));
}

class IronTraceApp extends ConsumerStatefulWidget {
  const IronTraceApp({super.key});

  @override
  ConsumerState<IronTraceApp> createState() => _IronTraceAppState();
}

class _IronTraceAppState extends ConsumerState<IronTraceApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = await ref.read(exerciseRepoProvider.future);
      await repo.initBuiltinIfEmpty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: '铁迹 IronTrace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}
