import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pages/exercise_detail_page.dart';
import '../pages/exercise_form_page.dart';
import '../pages/exercise_list_page.dart';
import '../pages/history_detail_page.dart';
import '../pages/history_list_page.dart';
import '../pages/home_page.dart';
import '../pages/training_page.dart';
import '../widgets/main_scaffold.dart';

final goRouterProvider = Provider<GoRouter>((ref) => GoRouter(
      initialLocation: '/',
      routes: [
        StatefulShellRoute.indexedStack(
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  name: 'home',
                  builder: (_, __) => const HomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/exercises',
                  name: 'exerciseList',
                  builder: (_, __) => const ExerciseListPage(),
                  routes: [
                    GoRoute(
                      path: 'detail/:id',
                      name: 'exerciseDetail',
                      builder: (_, s) => ExerciseDetailPage(
                        exerciseId: s.pathParameters['id']!,
                        pickMode: s.extra as bool? ?? false,
                      ),
                    ),
                    GoRoute(
                      path: 'add',
                      name: 'exerciseAdd',
                      builder: (_, __) => const ExerciseFormPage(),
                    ),
                  ],
                ),
              ],
            ),
          ],
          builder: (_, s, c) => MainScaffold(shell: c),
        ),
        GoRoute(
          path: '/training/:sessionId',
          name: 'training',
          builder: (_, s) => TrainingPage(
            sessionId: s.pathParameters['sessionId']!,
          ),
        ),
        GoRoute(
          path: '/history',
          name: 'historyList',
          builder: (_, __) => const HistoryListPage(),
          routes: [
            GoRoute(
              path: ':id',
              name: 'historyDetail',
              builder: (_, s) => HistoryDetailPage(
                sessionId: s.pathParameters['id']!,
              ),
            ),
          ],
        ),
      ],
    ));
