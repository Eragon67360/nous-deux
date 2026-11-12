import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/constants/settings_strings.dart';
import 'package:nousdeux/presentation/screens/settings/app_info_screen.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_app.dart';

const _urlLauncherChannel = MethodChannel('plugins.flutter.io/url_launcher');

/// Records the URLs url_launcher is asked to open (tests have no plugin).
List<String> _recordLaunches(WidgetTester tester) {
  final launched = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    _urlLauncherChannel,
    (call) async {
      final url = (call.arguments as Map)['url'] as String;
      if (call.method == 'canLaunch') return true;
      if (call.method == 'launch') launched.add(url);
      return true;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      _urlLauncherChannel,
      null,
    ),
  );
  return launched;
}

void main() {
  for (final lang in ['fr', 'en']) {
    testWidgets('[$lang] renders the description, source and contributors', (
      tester,
    ) async {
      useTallSurface(tester, height: 1600);
      await pumpScreen(
        tester,
        const AppInfoScreen(),
        deps: TestDeps(myProfile: profile(language: lang)),
      );

      expect(find.text(appInfoTitle(lang)), findsOneWidget);
      expect(find.text(appInfoDescription(lang)), findsOneWidget);
      expect(find.text(appInfoFree(lang)), findsOneWidget);
      expect(find.text(appInfoSource(lang)), findsOneWidget);
      expect(
        find.text('https://github.com/Eragon67360/nous-deux/'),
        findsOneWidget,
      );
      expect(find.text(appInfoContributors(lang)), findsOneWidget);
      expect(find.text('Thomas Moser'), findsOneWidget);
      expect(find.text(appInfoThomasMoser(lang)), findsOneWidget);
      expect(find.text('Evah Baumlin'), findsOneWidget);
      expect(find.text(appInfoEvahBaumlin(lang)), findsOneWidget);
      expect(find.text(lang == 'fr' ? 'Les amis' : 'Friends'), findsOneWidget);
      expect(find.text(appInfoFriends(lang)), findsOneWidget);
    });
  }

  testWidgets('the source link and the developer card open GitHub', (
    tester,
  ) async {
    useTallSurface(tester, height: 1600);
    final launched = _recordLaunches(tester);
    await pumpScreen(tester, const AppInfoScreen(), deps: TestDeps());

    await tester.tap(find.text('https://github.com/Eragon67360/nous-deux/'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thomas Moser'));
    await tester.pumpAndSettle();
    // Cards without a link do nothing.
    await tester.tap(find.text('Evah Baumlin'));
    await tester.pumpAndSettle();

    expect(launched, [
      'https://github.com/Eragon67360/nous-deux/',
      'https://github.com/Eragon67360',
    ]);
  });
}
