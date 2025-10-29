import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/di/locator.dart';
import '../domain/entities/user.dart';
import '../features/analyze/state/analyze_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/state/auth_controller.dart';
import '../features/auth/state/auth_state.dart';
import '../features/capture/presentation/capture_screen.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/recommendations/presentation/reco_feed_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

enum AppRoute {
  splash('/splash'),
  login('/login'),
  register('/register'),
  capture('/capture'),
  feed('/feed'),
  history('/history'),
  settings('/settings');

  const AppRoute(this.path);
  final String path;
}

final _routerNotifierProvider = Provider<GoRouterRefreshStream>((ref) {
  final stream = ref.watch(authRepositoryProvider).userStream;
  final notifier = GoRouterRefreshStream(stream);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(_routerNotifierProvider);
  final authState = ref.watch(authControllerProvider);
  final user = authState.valueOrNull?.user;

  return GoRouter(
    initialLocation: AppRoute.splash.path,
    refreshListenable: refreshNotifier,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoading = authState.isLoading ||
          authState.valueOrNull?.status == AuthStatus.unknown;
      final isLoggedIn = user != null;
      final isAtAuthRoute = state.matchedLocation == AppRoute.login.path ||
          state.matchedLocation == AppRoute.register.path;

      if (isLoading) {
        return AppRoute.splash.path;
      }

      if (!isLoggedIn) {
        if (state.matchedLocation != AppRoute.login.path &&
            state.matchedLocation != AppRoute.register.path) {
          return AppRoute.login.path;
        }
        return null;
      }

      if (isLoggedIn && isAtAuthRoute) {
        return AppRoute.capture.path;
      }

      if (isLoggedIn && state.matchedLocation == AppRoute.splash.path) {
        return AppRoute.capture.path;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoute.register.path,
        name: AppRoute.register.name,
        builder: (_, __) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.capture.path,
                name: AppRoute.capture.name,
                builder: (_, __) => const CaptureScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.feed.path,
                name: AppRoute.feed.name,
                builder: (_, __) => const RecommendationsFeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.history.path,
                name: AppRoute.history.name,
                builder: (_, __) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.settings.path,
                name: AppRoute.settings.name,
                builder: (_, __) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<User?> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
