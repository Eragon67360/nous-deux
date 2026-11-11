import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/utils/apple_nonce.dart';

void main() {
  test('the hashed nonce is the SHA-256 of the raw one', () {
    final nonce = appleNonce();
    expect(nonce.raw, hasLength(32));
    expect(nonce.hashed, sha256.convert(utf8.encode(nonce.raw)).toString());
  });

  test('each sign-in gets a new nonce', () {
    expect(appleNonce().raw, isNot(appleNonce().raw));
  });
}
