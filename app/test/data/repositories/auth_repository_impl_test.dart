import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/errors/failures.dart';
import 'package:nousdeux/data/datasources/auth_remote_datasource.dart';
import 'package:nousdeux/data/repositories/auth_repository_impl.dart';

/// Throws what the auth server answers to a password sign-in.
class _ThrowingAuth extends AuthRemoteDatasource {
  _ThrowingAuth(this.error)
    : super(
        client: SupabaseClient('https://example.test', 'k'),
        googleSignIn: GoogleSignIn(),
      );

  final Exception error;

  @override
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) => Future.error(error);
}

Future<Failure?> _failureFor(Exception error) async {
  final repo = AuthRepositoryImpl(datasource: _ThrowingAuth(error));
  final result = await repo.signInWithEmail(email: 'a@b.c', password: 'x');
  return result.failure;
}

void main() {
  test('a wrong email or password becomes WrongCredentialsFailure', () async {
    final failure = await _failureFor(
      AuthApiException(
        'Invalid login credentials',
        statusCode: '400',
        code: 'invalid_credentials',
      ),
    );
    expect(failure, const WrongCredentialsFailure());
  });

  test('another auth error keeps its message', () async {
    final failure = await _failureFor(
      AuthApiException(
        'Request rate limit reached',
        statusCode: '429',
        code: 'over_request_rate_limit',
      ),
    );
    expect(failure, const AuthFailure('Request rate limit reached'));
  });

  test('a network error is not taken for a wrong password', () async {
    final failure = await _failureFor(
      AuthRetryableFetchException(message: 'Connection refused'),
    );
    expect(failure, isNot(const WrongCredentialsFailure()));
    expect(failure, isA<AuthFailure>());
  });
}
