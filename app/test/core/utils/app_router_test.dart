import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:nousdeux/core/config/app_config.dart';
import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/domain/entities/profile_entity.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/providers/splash_provider.dart';
import 'package:nousdeux/core/utils/app_router.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

// The redirect is exercised directly (router.configuration.topRedirect) so no
// screen is built: each test sets up a session, then asks "where does the
// router send me from <path>?".

final _containers = <ProviderContainer>[];

/// Builds a container for a session described by [deps]; waits for auth and
/// profile to settle unless they are meant to stay loading.
Future<ProviderContainer> _session(
  TestDeps deps, {
  bool splashDone = true,
  bool authLoading = false,
  bool profileLoading = false,
}) async {
  final container = ProviderContainer(
    overrides: [
      ...deps.overrides,
      if (authLoading)
        currentUserProvider.overrideWith(
          (ref) => StreamController<Never>().stream,
        ),
      if (profileLoading)
        myProfileProvider.overrideWith(
          (ref) => Completer<ProfileEntity?>().future,
        ),
    ],
  );
  _containers.add(container);
  container.read(splashAnimationCompleteProvider.notifier).state = splashDone;
  container.listen(myProfileProvider, (_, _) {});
  if (!authLoading) {
    await container.read(currentUserProvider.future);
    if (!profileLoading) await container.read(myProfileProvider.future);
  }
  return container;
}

Future<String?> _redirectFrom(
  WidgetTester tester,
  ProviderContainer container,
  String location,
) async {
  final router = container.read(appRouterProvider);
  final state = GoRouterState(
    router.configuration,
    uri: Uri.parse(location),
    matchedLocation: location,
    fullPath: location,
    pathParameters: const {},
    pageKey: const ValueKey<String>('test'),
  );
  final context = tester.element(find.byType(SizedBox));
  // The redirect logs every decision with appLog; keep the test output quiet.
  return runZoned(
    () async => router.configuration.topRedirect(context, state),
    zoneSpecification: ZoneSpecification(print: (_, _, _, _) {}),
  );
}

/// A widget test with a host widget to borrow a BuildContext from. Containers
/// are disposed inside the test, then a pump flushes the zero-delay timers
/// Riverpod uses to schedule provider refreshes.
void redirectTest(
  String description,
  Future<void> Function(WidgetTester tester) body, {
  bool skip = false,
}) {
  testWidgets(description, skip: skip, (tester) async {
    await tester.pumpWidget(const SizedBox());
    try {
      await body(tester);
    } finally {
      for (final c in _containers) {
        c.dispose();
      }
      _containers.clear();
      await tester.pump(Duration.zero);
    }
  });
}

void main() {
  final supabaseSkip = AppConfig.isSupabaseConfigured
      ? false
      : 'Redirects only run with Supabase configured (local supabase_keys.dart '
            'or --dart-define=SUPABASE_URL/SUPABASE_ANON_KEY).';

  group('appRouterProvider redirect', skip: supabaseSkip, () {
    redirectTest('waits while auth is loading', (tester) async {
      final c = await _session(TestDeps(), authLoading: true);
      expect(await _redirectFrom(tester, c, '/'), isNull);
      expect(await _redirectFrom(tester, c, '/main'), isNull);
    });

    redirectTest('stays on the splash until its animation completes', (
      tester,
    ) async {
      final c = await _session(TestDeps(user: null), splashDone: false);
      expect(await _redirectFrom(tester, c, '/'), isNull);
      // Other paths are not held back by the splash flag.
      expect(await _redirectFrom(tester, c, '/main'), '/auth');
    });

    group('signed out', () {
      redirectTest('goes to /auth from the splash and from app screens', (
        tester,
      ) async {
        final c = await _session(TestDeps(user: null));
        expect(await _redirectFrom(tester, c, '/'), '/auth');
        expect(await _redirectFrom(tester, c, '/main'), '/auth');
        expect(await _redirectFrom(tester, c, '/settings'), '/auth');
        expect(await _redirectFrom(tester, c, '/onboarding'), '/auth');
        expect(await _redirectFrom(tester, c, '/pairing'), '/auth');
      });

      redirectTest('may stay on /auth and /auth/verify', (tester) async {
        final c = await _session(TestDeps(user: null));
        expect(await _redirectFrom(tester, c, '/auth'), isNull);
        expect(await _redirectFrom(tester, c, '/auth/verify'), isNull);
      });
    });

    redirectTest('signed in without a profile: back to /auth and signs out', (
      tester,
    ) async {
      final deps = TestDeps()..profiles.loadFailure = const NotFoundFailure();
      final c = await _session(deps);
      expect(await _redirectFrom(tester, c, '/main'), '/auth');
      expect(
        deps.auth.signOutCalls,
        0,
        reason: 'sign-out waits for the next frame',
      );
      tester.binding.scheduleFrame();
      await tester.pump();
      expect(deps.auth.signOutCalls, 1);
    });

    group('signed in, onboarding not done', () {
      redirectTest('goes to /onboarding from anywhere else', (tester) async {
        final c = await _session(
          TestDeps(myProfile: profile(onboarded: false)),
        );
        expect(await _redirectFrom(tester, c, '/'), '/onboarding');
        expect(await _redirectFrom(tester, c, '/auth'), '/onboarding');
        expect(await _redirectFrom(tester, c, '/main'), '/onboarding');
        expect(await _redirectFrom(tester, c, '/pairing'), '/onboarding');
      });

      redirectTest('stays on /onboarding', (tester) async {
        final c = await _session(
          TestDeps(myProfile: profile(onboarded: false)),
        );
        expect(await _redirectFrom(tester, c, '/onboarding'), isNull);
      });
    });

    group('signed in and onboarded', () {
      redirectTest('leaves the splash, auth and onboarding for /main', (
        tester,
      ) async {
        final c = await _session(TestDeps());
        expect(await _redirectFrom(tester, c, '/'), '/main');
        expect(await _redirectFrom(tester, c, '/auth'), '/main');
        expect(await _redirectFrom(tester, c, '/auth/verify'), '/main');
        expect(await _redirectFrom(tester, c, '/onboarding'), '/main');
      });

      redirectTest('never forces pairing and leaves app screens alone', (
        tester,
      ) async {
        final c = await _session(TestDeps());
        expect(await _redirectFrom(tester, c, '/main'), isNull);
        expect(await _redirectFrom(tester, c, '/main/period'), isNull);
        expect(await _redirectFrom(tester, c, '/settings/info'), isNull);
        expect(await _redirectFrom(tester, c, '/pairing'), isNull);
        expect(await _redirectFrom(tester, c, '/pairing/join'), isNull);
      });
    });

    redirectTest('signed in, profile still loading: no redirect yet', (
      tester,
    ) async {
      final deps = TestDeps();
      final c = await _session(deps, profileLoading: true);
      expect(await _redirectFrom(tester, c, '/'), isNull);
      expect(await _redirectFrom(tester, c, '/main'), isNull);
      tester.binding.scheduleFrame();
      await tester.pump();
      expect(deps.auth.signOutCalls, 0);
    });
  });

  redirectTest(
    'without Supabase configured the router never redirects',
    skip: AppConfig.isSupabaseConfigured,
    (tester) async {
      final c = await _session(TestDeps(user: null));
      expect(await _redirectFrom(tester, c, '/'), isNull);
      expect(await _redirectFrom(tester, c, '/main'), isNull);
    },
  );
}
