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
  final hasProfile = profile != null;
  final hasPartner = profile?.hasPartner ?? false;

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

      if (!hasProfile && !profileAsync.isLoading) {
        if (loc.startsWith('/onboarding')) return null;
        return '/onboarding';
      }

      if (hasProfile && !hasPartner) {
        if (loc.startsWith('/pairing')) return null;
        return '/pairing';
      }

      if (loc == '/' ||
          loc.startsWith('/auth') ||
          loc.startsWith('/onboarding') ||
          loc.startsWith('/pairing')) {
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
