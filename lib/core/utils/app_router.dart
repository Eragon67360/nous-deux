import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nous_deux/core/config/app_config.dart';
import 'package:nous_deux/core/utils/app_log.dart';
import 'package:nous_deux/presentation/providers/auth_provider.dart';
import 'package:nous_deux/presentation/providers/profile_provider.dart';
import 'package:nous_deux/presentation/screens/auth/auth_screen.dart';
import 'package:nous_deux/presentation/screens/auth/verify_otp_screen.dart';
import 'package:nous_deux/presentation/screens/main/main_shell_screen.dart';
import 'package:nous_deux/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:nous_deux/presentation/screens/pairing/pairing_join_screen.dart';
import 'package:nous_deux/presentation/screens/pairing/pairing_screen.dart';
import 'package:nous_deux/presentation/screens/pairing/pairing_scan_screen.dart';
import 'package:nous_deux/presentation/screens/splash/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

const _transitionDuration = Duration(milliseconds: 250);

/// Fade transition for route changes.
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: _transitionDuration,
    reverseTransitionDuration: _transitionDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final isSupabaseConfigured = AppConfig.isSupabaseConfigured;
  final authAsync = ref.watch(currentUserProvider);
  final profileAsync = ref.watch(myProfileProvider);
  final authLoading = authAsync.isLoading;
  final isSignedIn = authAsync.valueOrNull != null;
  final profile = profileAsync.valueOrNull;
  final hasCompletedOnboarding = profile?.hasCompletedOnboarding ?? false;
  final authHasError = authAsync.hasError;
  final profileHasError = profileAsync.hasError;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final loc = state.uri.path;
      appLog(
        'ROUTER',
        message: 'redirect called → path=$loc',
        color: '\x1B[36m',
      );
      appLog(
        'ROUTER',
        message:
            '  supabase=$isSupabaseConfigured authLoading=$authLoading isSignedIn=$isSignedIn authError=$authHasError${authHasError ? " (${authAsync.error})" : ""}',
        color: '\x1B[36m',
      );
      appLog(
        'ROUTER',
        message:
            '  profileLoading=${profileAsync.isLoading} profile=${profile != null} hasOnboarding=$hasCompletedOnboarding profileError=$profileHasError${profileHasError ? " (${profileAsync.error})" : ""}',
        color: '\x1B[36m',
      );

      if (!isSupabaseConfigured) {
        appLog(
          'ROUTER',
          message: '  → null (Supabase not configured)',
          color: '\x1B[33m',
        );
        return null;
      }
      if (authLoading) {
        appLog(
          'ROUTER',
          message: '  → null (auth still loading, staying on $loc)',
          color: '\x1B[33m',
        );
        return null;
      }

      // Signed in but profile missing or failed (e.g. user deleted from DB) → sign out and go to auth
      if (isSignedIn && !profileAsync.isLoading && profile == null) {
        appLog(
          'ROUTER',
          message:
              '  → /auth (signed in but no profile${profileHasError ? " or profile error" : ""}, signing out)',
          color: '\x1B[32m',
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(authRepositoryProvider).signOut();
        });
        return '/auth';
      }

      if (!isSignedIn) {
        if (loc.startsWith('/auth')) {
          appLog(
            'ROUTER',
            message: '  → null (not signed in, already on auth)',
            color: '\x1B[32m',
          );
          return null;
        }
        appLog(
          'ROUTER',
          message: '  → /auth (not signed in)',
          color: '\x1B[32m',
        );
        return '/auth';
      }

      // First-time user: send to onboarding once profile is loaded and not completed
      if (!profileAsync.isLoading &&
          profile != null &&
          !hasCompletedOnboarding &&
          !loc.startsWith('/onboarding')) {
        appLog(
          'ROUTER',
          message: '  → /onboarding (profile loaded, onboarding not done)',
          color: '\x1B[32m',
        );
        return '/onboarding';
      }

      // Onboarding done: go to main (never auto-redirect to pairing)
      if (hasCompletedOnboarding &&
          (loc == '/' ||
              loc.startsWith('/auth') ||
              loc.startsWith('/onboarding'))) {
        appLog(
          'ROUTER',
          message: '  → /main (onboarding done)',
          color: '\x1B[32m',
        );
        return '/main';
      }
      appLog('ROUTER', message: '  → null (no redirect)', color: '\x1B[33m');
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (_, state) => _fadePage(state, const SplashScreen()),
      ),
      GoRoute(
        path: '/auth',
        pageBuilder: (_, state) => _fadePage(state, const AuthScreen()),
      ),
      GoRoute(
        path: '/auth/verify',
        pageBuilder: (_, state) => _fadePage(
          state,
          VerifyOtpScreen(
            phone:
                (state.extra as Map<String, dynamic>?)?['phone'] as String? ??
                '',
          ),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (_, state) => _fadePage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: '/pairing',
        pageBuilder: (_, state) => _fadePage(state, const PairingScreen()),
      ),
      GoRoute(
        path: '/pairing/join',
        pageBuilder: (_, state) => _fadePage(state, const PairingJoinScreen()),
      ),
      GoRoute(
        path: '/pairing/scan',
        pageBuilder: (_, state) => _fadePage(state, const PairingScanScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, child) => MainShellScreen(child: child),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: '/main',
                pageBuilder: (_, state) =>
                    _fadePage(state, const _MainPlaceholder()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _MainPlaceholder extends StatelessWidget {
  const _MainPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Calendrier, Règles, Position, Paramètres — à venir'),
      ),
    );
  }
}
