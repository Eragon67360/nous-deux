import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// A one-time value for Sign in with Apple. Apple puts the [hashed] form in
/// the ID token; the auth server gets the [raw] form and checks that they
/// match, so an intercepted token can't be replayed.
({String raw, String hashed}) appleNonce([Random? random]) {
  const chars =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
  final r = random ?? Random.secure();
  final raw = List.generate(32, (_) => chars[r.nextInt(chars.length)]).join();
  return (raw: raw, hashed: sha256.convert(utf8.encode(raw)).toString());
}
