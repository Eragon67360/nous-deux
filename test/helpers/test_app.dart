import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:nousdeux/presentation/providers/lists_provider.dart';
import 'package:nousdeux/domain/entities/shared_list_entity.dart';
import 'package:nousdeux/presentation/providers/nous_provider.dart';
import 'package:nousdeux/domain/entities/ping_entity.dart';
import 'package:nousdeux/domain/entities/calendar_event_entity.dart';
import 'package:nousdeux/domain/entities/couple_entity.dart';
import 'package:nousdeux/domain/entities/cycle_checkin_entity.dart';
import 'package:nousdeux/domain/entities/location_sharing_entity.dart';
import 'package:nousdeux/domain/entities/period_log_entity.dart';
import 'package:nousdeux/domain/entities/profile_entity.dart';
import 'package:nousdeux/domain/entities/user_entity.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/calendar_provider.dart';
import 'package:nousdeux/presentation/providers/cycle_provider.dart';
import 'package:nousdeux/presentation/providers/locale_provider.dart';
import 'package:nousdeux/presentation/providers/location_provider.dart';
import 'package:nousdeux/presentation/providers/pairing_provider.dart';
import 'package:nousdeux/presentation/providers/period_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';
import 'package:nousdeux/presentation/providers/realtime_provider.dart';
import 'package:nousdeux/presentation/theme/app_theme.dart';

import 'fake_realtime.dart';
import 'fakes.dart';
import 'fixtures.dart';

ThemeData? _theme;

/// [AppTheme.dark], built once per test file.
ThemeData get testTheme => _theme ??= AppTheme.dark;

/// Every repository a screen can reach, backed by in-memory fakes, plus the
/// device language. Defaults describe a signed-in, onboarded user with no
/// partner and no data.
class TestDeps {
  TestDeps({
    UserEntity? user = me,
    ProfileEntity? myProfile,
    ProfileEntity? partner,
    CoupleEntity? couple,
    List<CalendarEventEntity>? events,
    List<PeriodLogEntity>? logs,
    List<CycleCheckinEntity>? checkins,
    Map<DateTime, String>? notes,
    LocationSharingEntity? myLocation,
    LocationSharingEntity? partnerLocation,
    List<PingEntity>? pings,
    List<SharedListEntity>? lists,
    List<ListItemEntity>? listItems,
    DateTime? now,
    this.deviceLanguage = 'fr',
  }) : now = now ?? DateTime(2026, 11, 10, 18),
       pings = FakePingRepository(pings),
       lists = FakeListsRepository(lists: lists, items: listItems),
       auth = FakeAuthRepository(user: user),
       profiles = FakeProfileRepository(
         mine: myProfile ?? profile(partner: partner?.id),
         others: partner == null ? {} : {partner.id: partner},
       ),
       pairing = FakePairingRepository(couple: couple),
       calendar = FakeCalendarRepository(events),
       period = FakePeriodRepository(logs),
       cycle = FakeCycleRepository(checkins: checkins, notes: notes),
       location = FakeLocationRepository(
         mine: myLocation,
         partner: partnerLocation,
       );

  final FakeAuthRepository auth;
  final FakeProfileRepository profiles;
  final FakePairingRepository pairing;
  final FakeCalendarRepository calendar;
  final FakePeriodRepository period;
  final FakeCycleRepository cycle;
  final FakeLocationRepository location;
  final FakeRealtime realtime = FakeRealtime();
  final FakePingRepository pings;
  final FakeListsRepository lists;

  /// What the app reads as "now" (clockProvider).
  final DateTime now;
  final String deviceLanguage;

  List<Override> get overrides => [
    authRepositoryProvider.overrideWithValue(auth),
    profileRepositoryProvider.overrideWithValue(profiles),
    pairingRepositoryProvider.overrideWithValue(pairing),
    calendarRepositoryProvider.overrideWithValue(calendar),
    periodRepositoryProvider.overrideWithValue(period),
    cycleRepositoryProvider.overrideWithValue(cycle),
    locationRepositoryProvider.overrideWithValue(location),
    deviceLanguageProvider.overrideWithValue(deviceLanguage),
    locationUpdateNotifierProvider.overrideWith(FakeLocationUpdateNotifier.new),
    realtimeChannelFactoryProvider.overrideWithValue(realtime.open),
    pingRepositoryProvider.overrideWithValue(pings),
    listsRepositoryProvider.overrideWithValue(lists),
    clockProvider.overrideWithValue(() => now),
    minuteTickProvider.overrideWith((ref) => Stream.value(0)),
  ];
}

const _localizationsDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
const _supportedLocales = [Locale('fr'), Locale('en')];

TransitionBuilder _motion(bool reducedMotion) => (context, child) {
  if (!reducedMotion) return child!;
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child!,
  );
};

/// Pumps [screen] as the home of a MaterialApp themed like the app.
///
/// Reduced motion is on by default so entrance animations resolve on the
/// first frame; pass `reducedMotion: false` to exercise the animated paths.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  TestDeps? deps,
  List<Override> overrides = const [],
  bool reducedMotion = true,
  String locale = 'fr',
  bool settle = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...?deps?.overrides, ...overrides],
      child: MaterialApp(
        theme: testTheme,
        locale: Locale(locale),
        supportedLocales: _supportedLocales,
        localizationsDelegates: _localizationsDelegates,
        builder: _motion(reducedMotion),
        home: screen,
      ),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}

/// Pumps a GoRouter app for screens that navigate with `context.push/go`.
/// Pair it with [stubRoute] for the destinations.
Future<GoRouter> pumpRouter(
  WidgetTester tester, {
  required String initialLocation,
  required List<RouteBase> routes,
  TestDeps? deps,
  List<Override> overrides = const [],
  bool reducedMotion = true,
  String locale = 'fr',
}) async {
  final router = GoRouter(initialLocation: initialLocation, routes: routes);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...?deps?.overrides, ...overrides],
      child: MaterialApp.router(
        theme: testTheme,
        locale: Locale(locale),
        supportedLocales: _supportedLocales,
        localizationsDelegates: _localizationsDelegates,
        builder: _motion(reducedMotion),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

/// A placeholder page at [path] that shows `stub:<path>` and the `extra`
/// it was opened with.
GoRoute stubRoute(String path, {List<RouteBase> routes = const []}) {
  return GoRoute(
    path: path,
    routes: routes,
    builder: (_, state) => Scaffold(
      body: Text('stub:$path${state.extra != null ? ' ${state.extra}' : ''}'),
    ),
  );
}

/// A route that shows [screen] at [path].
GoRoute screenRoute(
  String path,
  Widget screen, {
  List<RouteBase> routes = const [],
}) {
  return GoRoute(path: path, routes: routes, builder: (_, _) => screen);
}

/// Makes the test surface tall enough that long lists build every row.
void useTallSurface(WidgetTester tester, {double height = 3000}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(800, height);
  addTearDown(tester.view.reset);
}

/// The [ProviderContainer] above [finder] (defaults to the first Scaffold).
ProviderContainer containerOf(WidgetTester tester, [Finder? finder]) {
  return ProviderScope.containerOf(
    tester.element(finder ?? find.byType(Scaffold).first),
  );
}
