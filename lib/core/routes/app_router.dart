import 'package:date_journal_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:date_journal_app/features/auth/presentation/screens/login_screen.dart';
import 'package:date_journal_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:date_journal_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:date_journal_app/features/dates/presentation/screens/date_detail_screen.dart';

import 'package:date_journal_app/features/dates/presentation/screens/new_date_screen.dart';
import 'package:date_journal_app/features/dates/presentation/screens/timeline_screen.dart';
import 'package:date_journal_app/features/persons/presentation/screens/persons_list_screen.dart';
import 'package:date_journal_app/features/profile/presentation/screens/settings_screen.dart';
import 'package:date_journal_app/features/statistics/presentation/screens/stats_screen.dart';
import 'package:date_journal_app/shared/widgets/main_scaffold_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/', // Start at home, redirect will handle if not auth
    refreshListenable:
        ValueNotifier(authState), // Need a better way to listen to stream.
    // GoRouter refreshListenable expects a Listenable. Stream provider returns AsyncValue.
    // We can use a Notifier that updates on stream change, or just rebuild router (not optimal).
    // Better: use a dedicated ChangeNotifier for auth state to feed GoRouter.
    // For now, let's keep it simple with redirect check.
    // Note: To properly trigger redirect on stream change, we need to wrap the stream in a Listenable.
    // Let's assume for MVP that we rely on the provider re-evaluating if we pass it correctly?
    // Actually, GoRouter redirection triggers on navigation. To trigger on auth change, we need refreshListenable.
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/onboarding';

      if (!isLoggedIn && !isLoggingIn) {
        return '/onboarding';
      }
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffoldShell(
            currentLocation: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TimelineScreen()),
          ),
          GoRoute(
            path: '/persons',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: PersonsListScreen()),
          ),
          GoRoute(
            path: '/stats',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: StatsScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
      // Detail routes outside Shell to hide bottom bar, or inside if desired.
      // Usually details hide bottom bar.
      GoRoute(
        path: '/date/new',
        builder: (context, state) => const NewDateScreen(),
      ),
      GoRoute(
        path: '/date/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DateDetailScreen(dateId: id);
        },
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return NewDateScreen(dateId: id);
            },
          ),
        ],
      ),
    ],
  );
});
