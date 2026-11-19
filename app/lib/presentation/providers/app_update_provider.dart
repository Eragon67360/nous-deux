import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nousdeux/core/services/feedback_mail.dart';
import 'package:nousdeux/core/services/store_links.dart';
import 'package:nousdeux/data/repositories/app_builds_repository_impl.dart';
import 'package:nousdeux/domain/app_update.dart';
import 'package:nousdeux/domain/repositories/app_builds_repository.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/locale_provider.dart';
import 'package:nousdeux/presentation/providers/nous_provider.dart';

final appBuildsRepositoryProvider = Provider<AppBuildsRepository>(
  (ref) => AppBuildsRepositoryImpl(),
);

/// Where « Plus tard » keeps its day ([updateDay]).
const updateLaterDayKey = 'update_later_day';

/// What the update screen decides on, read from the phone, the server and
/// Google Play.
typedef UpdateFacts = ({
  int? installed,
  PublishedBuild? published,
  int? playBuild,
  bool isIos,
  String? laterDay,
});

/// [UpdateFacts], or null while signed out (the row is for signed-in
/// people). Invalidate it to check again (the app resumed); the screen keeps
/// the previous answer meanwhile.
final updateFactsProvider = FutureProvider<UpdateFacts?>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;
  final isIos = defaultTargetPlatform == TargetPlatform.iOS;
  final installed = int.tryParse(await ref.watch(appBuildProvider.future));
  final published = await ref
      .watch(appBuildsRepositoryProvider)
      .published(isIos ? 'ios' : 'android');
  final playBuild = isIos ? null : await ref.read(playUpdateCheckProvider)();
  final prefs = await SharedPreferences.getInstance();
  return (
    installed: installed,
    published: published,
    playBuild: playBuild,
    isIos: isIos,
    laterDay: prefs.getString(updateLaterDayKey),
  );
});

/// The day « Plus tard » was tapped while the app runs; the stored one is in
/// [UpdateFacts].
final updateLaterTappedProvider = StateProvider<String?>((ref) => null);

/// The screen to show over the app, if any (docs/UPDATE_SCREEN.md).
final updateOfferProvider = Provider<UpdateOffer?>((ref) {
  final facts = ref.watch(updateFactsProvider).valueOrNull;
  if (facts == null) return null;
  return decideUpdate(
    installed: facts.installed,
    published: facts.published,
    playBuild: facts.playBuild,
    isIos: facts.isIos,
    lang: ref.watch(appLocaleProvider).languageCode,
    laterDay: ref.watch(updateLaterTappedProvider) ?? facts.laterDay,
    now: ref.watch(clockProvider)(),
  );
});

/// « Plus tard »: hides the screen at once, until the next day.
final postponeUpdateProvider = Provider<Future<void> Function()>(
  (ref) => () async {
    final day = updateDay(ref.read(clockProvider)());
    ref.read(updateLaterTappedProvider.notifier).state = day;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(updateLaterDayKey, day);
  },
);
