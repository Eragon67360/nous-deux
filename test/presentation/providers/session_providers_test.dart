import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/locale_provider.dart';
import 'package:nousdeux/presentation/providers/location_provider.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

void main() {
  ProviderContainer containerFor(TestDeps deps) {
    final container = ProviderContainer(overrides: deps.overrides);
    addTearDown(container.dispose);
    return container;
  }

  group('myProfileProvider', () {
    test('loads the profile of the signed-in user', () async {
      final deps = TestDeps(myProfile: profile(username: 'Camille'));
      final c = containerFor(deps);
      c.listen(myProfileProvider, (_, _) {});
      await c.read(currentUserProvider.future);
      expect((await c.read(myProfileProvider.future))?.username, 'Camille');
    });

    test('is null when signed out, without asking the repository', () async {
      final deps = TestDeps(user: null);
      final c = containerFor(deps);
      await c.read(currentUserProvider.future);
      expect(await c.read(myProfileProvider.future), isNull);
      expect(deps.profiles.getOrCreateCalls, 0);
    });

    test('turns a repository failure into null', () async {
      final deps = TestDeps()
        ..profiles.loadFailure = const ServerFailure('gone');
      final c = containerFor(deps);
      c.listen(myProfileProvider, (_, _) {});
      await c.read(currentUserProvider.future);
      expect(await c.read(myProfileProvider.future), isNull);
    });
  });

  group('partnerProfileProvider', () {
    test('loads the partner named on my profile', () async {
      final c = containerFor(
        TestDeps(partner: partnerProfile(username: 'Alex')),
      );
      c.listen(partnerProfileProvider, (_, _) {});
      await c.read(currentUserProvider.future);
      expect((await c.read(partnerProfileProvider.future))?.username, 'Alex');
    });

    test('is null without a partner', () async {
      final c = containerFor(TestDeps());
      c.listen(partnerProfileProvider, (_, _) {});
      await c.read(currentUserProvider.future);
      expect(await c.read(partnerProfileProvider.future), isNull);
    });

    test('is null when the partner profile cannot be read', () async {
      // Partner id on my profile, but the repository has no such profile.
      final c = containerFor(TestDeps(myProfile: profile(partner: partnerId)));
      c.listen(partnerProfileProvider, (_, _) {});
      await c.read(currentUserProvider.future);
      expect(await c.read(partnerProfileProvider.future), isNull);
    });
  });

  group('myCoupleProvider', () {
    test('returns the couple from the repository', () async {
      final c = containerFor(TestDeps(couple: couple()));
      c.listen(myCoupleProvider, (_, _) {});
      await c.read(currentUserProvider.future);
      expect((await c.read(myCoupleProvider.future))?.id, coupleId);
    });

    test('is null when signed out', () async {
      final c = containerFor(TestDeps(user: null, couple: couple()));
      await c.read(currentUserProvider.future);
      expect(await c.read(myCoupleProvider.future), isNull);
    });
  });

  group('location sharing providers', () {
    test('mine comes from the repository when signed in', () async {
      final c = containerFor(
        TestDeps(myLocation: location(lat: 48.85, lng: 2.35)),
      );
      c.listen(myLocationSharingProvider, (_, _) {});
      await c.read(currentUserProvider.future);
      final mine = await c.read(myLocationSharingProvider.future);
      expect(mine?.isSharing, isTrue);
      expect(mine?.hasPosition, isTrue);
    });

    test("partner's is only fetched when I have a partner", () async {
      final withPartner = containerFor(
        TestDeps(
          partner: partnerProfile(),
          partnerLocation: location(userId: partnerId, lat: 1, lng: 2),
        ),
      );
      withPartner.listen(partnerLocationSharingProvider, (_, _) {});
      await withPartner.read(currentUserProvider.future);
      expect(
        (await withPartner.read(partnerLocationSharingProvider.future))?.userId,
        partnerId,
      );

      final alone = containerFor(
        TestDeps(partnerLocation: location(userId: partnerId, lat: 1, lng: 2)),
      );
      alone.listen(partnerLocationSharingProvider, (_, _) {});
      await alone.read(currentUserProvider.future);
      expect(await alone.read(partnerLocationSharingProvider.future), isNull);
    });
  });

  group('appLocaleProvider', () {
    test('follows the profile language once loaded', () async {
      final c = containerFor(TestDeps(myProfile: profile(language: 'en')));
      c.listen(appLocaleProvider, (_, _) {});
      await c.read(currentUserProvider.future);
      await c.read(myProfileProvider.future);
      expect(c.read(appLocaleProvider), const Locale('en'));
    });

    test(
      'falls back to the device locale (fr or en) without a profile',
      () async {
        final c = containerFor(TestDeps(user: null));
        await c.read(currentUserProvider.future);
        await c.read(myProfileProvider.future);
        final device = ui.PlatformDispatcher.instance.locale;
        expect(
          c.read(appLocaleProvider),
          device.languageCode.startsWith('fr')
              ? const Locale('fr')
              : const Locale('en'),
        );
      },
    );
  });

  test('deviceLanguageProvider maps the device locale to fr or en', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final device = ui.PlatformDispatcher.instance.locale;
    expect(
      container.read(deviceLanguageProvider),
      device.languageCode.startsWith('fr') ? 'fr' : 'en',
    );
  });
}
