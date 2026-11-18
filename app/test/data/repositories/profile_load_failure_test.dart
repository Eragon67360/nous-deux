import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/data/repositories/profile_repository_impl.dart';

void main() {
  test('the profile can\'t be created because the account is gone: '
      'not found', () {
    const refused = PostgrestException(
      message:
          'insert or update on table "profiles" violates foreign key '
          'constraint "profiles_id_fkey"',
      code: '23503',
    );
    expect(profileLoadFailure(refused), isA<NotFoundFailure>());
  });

  test('a server error is a server failure, not "not found"', () {
    const timeout = PostgrestException(message: '', code: '504');
    expect(profileLoadFailure(timeout), isA<ServerFailure>());
  });

  test('no network is not "not found"', () {
    final failure = profileLoadFailure(const SocketException('offline'));
    expect(failure, isNot(isA<NotFoundFailure>()));
  });
}
