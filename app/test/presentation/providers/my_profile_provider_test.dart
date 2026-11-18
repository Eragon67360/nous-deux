import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

import '../../helpers/test_app.dart';

Future<ProviderContainer> _container(TestDeps deps) async {
  final c = ProviderContainer(overrides: deps.overrides);
  addTearDown(c.dispose);
  await c.read(currentUserProvider.future);
  return c;
}

void main() {
  test('a profile that can\'t load (no network) is an error, '
      'not "no profile"', () async {
    final deps = TestDeps()..profiles.loadFailure = const NetworkFailure();
    final c = await _container(deps);
    await expectLater(
      c.read(myProfileProvider.future),
      throwsA(isA<ProfileUnavailableException>()),
    );
  });

  test('an account that no longer exists has no profile', () async {
    final deps = TestDeps()..profiles.loadFailure = const NotFoundFailure();
    final c = await _container(deps);
    expect(await c.read(myProfileProvider.future), isNull);
  });
}
