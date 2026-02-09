import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nous_deux/core/config/app_config.dart';
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

final appRouterProvider = Provider<GoRouter>((ref) {
  final isSupabaseConfigured = AppConfig.isSupabaseConfigured;
  final authAsync = ref.watch(currentUserProvider);
  final profileAsync = ref.watch(myProfileProvider);
  final authLoading = authAsync.isLoading;
  final isSignedIn = authAsync.valueOrNull != null;
  final profile = profileAsync.valueOrNull;
  final hasCompletedOnboarding = profile?.hasCompletedOnboarding ?? false;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      if (!isSupabaseConfigured) return null;
      final loc = state.uri.path;
      if (authLoading) return null;

      if (!isSignedIn) {
        if (loc.startsWith('/auth')) return null;
        return '/auth';
      }

      // First-time user: send to onboarding once profile is loaded and not completed
      if (!profileAsync.isLoading &&
          profile != null &&
          !hasCompletedOnboarding &&
          !loc.startsWith('/onboarding')) {
        return '/onboarding';
      }

      // Onboarding done: go to main (never auto-redirect to pairing)
      if (hasCompletedOnboarding &&
          (loc == '/' ||
              loc.startsWith('/auth') ||
              loc.startsWith('/onboarding'))) {
        return '/main';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/auth/verify',
        builder: (context, state) => VerifyOtpScreen(
          phone:
              (state.extra as Map<String, dynamic>?)?['phone'] as String? ?? '',
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/pairing',
        builder: (context, state) => const PairingScreen(),
      ),
      GoRoute(
        path: '/pairing/join',
        builder: (context, state) => const PairingJoinScreen(),
      ),
      GoRoute(
        path: '/pairing/scan',
        builder: (context, state) => const PairingScanScreen(),
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
                    const NoTransitionPage(child: _MainPlaceholder()),
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
