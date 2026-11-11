import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nousdeux/core/config/app_config.dart';
import 'package:nousdeux/core/utils/app_log.dart';
import 'package:nousdeux/core/utils/app_routes.dart';
import 'package:nousdeux/domain/entities/profile_entity.dart';
import 'package:nousdeux/domain/entities/user_entity.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/providers/splash_provider.dart';
import 'package:nousdeux/presentation/screens/auth/auth_screen.dart';
import 'package:nousdeux/presentation/screens/auth/verify_otp_screen.dart';
import 'package:nousdeux/presentation/screens/calendar/calendar_screen.dart';
import 'package:nousdeux/presentation/screens/lists/list_detail_screen.dart';
import 'package:nousdeux/presentation/screens/lists/lists_screen.dart';
import 'package:nousdeux/presentation/screens/main/main_shell_screen.dart';
import 'package:nousdeux/presentation/screens/nous/nous_screen.dart';
import 'package:nousdeux/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:nousdeux/presentation/screens/pairing/pairing_join_screen.dart';
import 'package:nousdeux/presentation/screens/pairing/pairing_scan_screen.dart';
import 'package:nousdeux/presentation/screens/pairing/pairing_screen.dart';
import 'package:nousdeux/presentation/screens/period/period_screen.dart';
import 'package:nousdeux/presentation/screens/position/position_screen.dart';
import 'package:nousdeux/presentation/screens/settings/app_info_screen.dart';
import 'package:nousdeux/presentation/screens/settings/settings_screen.dart';
import 'package:nousdeux/presentation/screens/splash/splash_screen.dart';
import 'package:nousdeux/presentation/theme/app_motion.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Route transition: a quiet fade with a few pixels of upward drift.
/// Reduced motion keeps the fade and drops the movement.
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppMotion.medium,
    reverseTransitionDuration: AppMotion.fast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.enter,
        reverseCurve: AppMotion.exit,
      );
      final faded = FadeTransition(opacity: curved, child: child);
      if (AppMotion.reduced(context)) return faded;
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.015),
          end: Offset.zero,
        ).animate(curved),
        child: faded,
      );
    },
  );
}

/// Everything the redirect decides on, as one snapshot.
///
/// Watching the three together keeps them consistent: when a session
/// arrives, the profile is already "loading" here. Reading them one by one
/// from a listener on the session saw the previous user's profile (none)
/// for an instant, and the "signed in without a profile" rule signed the
/// new session straight out.
typedef _RouteInputs = ({
  AsyncValue<UserEntity?> auth,
  AsyncValue<ProfileEntity?> profile,
  bool splashDone,
});

final _routeInputsProvider = Provider<_RouteInputs>(
  (ref) => (
    auth: ref.watch(currentUserProvider),
    profile: ref.watch(myProfileProvider),
    splashDone: ref.watch(splashAnimationCompleteProvider),
  ),
);

/// The app's one router, kept for the app's whole life. Auth, profile and
/// splash changes re-run [GoRouter.redirect] through `refreshListenable`.
/// Building a new router on each change would restart navigation at the
/// splash screen, which is what used to happen after onboarding.
final appRouterProvider = Provider<GoRouter>((ref) {
  final isSupabaseConfigured = AppConfig.isSupabaseConfigured;
  final refresh = ValueNotifier<int>(0);
  ref.listen(_routeInputsProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final inputs = ref.read(_routeInputsProvider);
      final authAsync = inputs.auth;
      final profileAsync = inputs.profile;
      final authLoading = authAsync.isLoading;
      final isSignedIn = authAsync.valueOrNull != null;
      final profile = profileAsync.valueOrNull;
      final hasCompletedOnboarding = profile?.hasCompletedOnboarding ?? false;
      final authHasError = authAsync.hasError;
      final profileHasError = profileAsync.hasError;
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

      if (loc == '/' && !inputs.splashDone) {
        appLog(
          'ROUTER',
          message: '  → null (splash animation not yet complete)',
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
        return AppRoutes.home;
      }
      appLog('ROUTER', message: '  → null (no redirect)', color: '\x1B[33m');
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (_, state) => _fadePage(state, const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.auth,
        pageBuilder: (_, state) => _fadePage(state, const AuthScreen()),
      ),
      GoRoute(
        path: AppRoutes.authVerify,
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
        path: AppRoutes.onboarding,
        pageBuilder: (_, state) => _fadePage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.pairing,
        pageBuilder: (_, state) => _fadePage(state, const PairingScreen()),
      ),
      GoRoute(
        path: AppRoutes.pairingJoin,
        pageBuilder: (_, state) => _fadePage(state, const PairingJoinScreen()),
      ),
      GoRoute(
        path: AppRoutes.pairingScan,
        pageBuilder: (_, state) => _fadePage(state, const PairingScanScreen()),
      ),
      GoRoute(
        path: AppRoutes.lists,
        pageBuilder: (_, state) => _fadePage(state, const ListsScreen()),
        routes: [
          GoRoute(
            path: ':id',
            pageBuilder: (_, state) => _fadePage(
              state,
              ListDetailScreen(listId: state.pathParameters['id']!),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (_, state) => _fadePage(state, const SettingsScreen()),
        routes: [
          GoRoute(
            path: 'info',
            pageBuilder: (_, state) => _fadePage(state, const AppInfoScreen()),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShellScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (_, state) => _fadePage(state, const NousScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.calendar,
                pageBuilder: (_, state) =>
                    _fadePage(state, const CalendarHomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.period,
                pageBuilder: (_, state) => _fadePage(
                  state,
                  PeriodScreen(
                    initialTab: state.uri.queryParameters['tab'] == 'guide'
                        ? 1
                        : null,
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.position,
                pageBuilder: (_, state) =>
                    _fadePage(state, const PositionScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
