import 'package:flutter_test/flutter_test.dart';

import 'package:nousdeux/core/services/feedback_mail.dart';

void main() {
  test('writes to the team with the build and the kind of phone', () {
    final uri = feedbackMailUri(lang: 'fr', build: '30', isIos: true);
    expect(uri.scheme, 'mailto');
    expect(uri.path, feedbackEmail);
    expect(
      uri.toString(),
      'mailto:$feedbackEmail?subject=Nous%20Deux%20%C2%B7%20build%2030%20%C2%B7%20iPhone',
    );
  });

  test('an Android phone says so', () {
    final uri = feedbackMailUri(lang: 'en', build: '30', isIos: false);
    expect(
      Uri.decodeComponent(uri.query),
      'subject=Nous Deux · build 30 · Android',
    );
  });
}
