/// [text] as a short note or state is stored: control characters and runs
/// of whitespace, line breaks included, made one space, ends trimmed, and
/// at most [maxLength] characters, counted as the database counts them
/// (code points).
String cleanShortText(String text, {required int maxLength}) {
  final one = text
      .replaceAll(RegExp(r'[\u0000-\u001F\u007F-\u009F\s]+'), ' ')
      .trim();
  if (one.runes.length <= maxLength) return one;
  return String.fromCharCodes(one.runes.take(maxLength)).trimRight();
}
