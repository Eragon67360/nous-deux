import 'package:flutter/services.dart';

/// Cuts the text at [max] characters as the database counts them (code
/// points), so a note full of emoji is never refused.
class CodePointLimit extends TextInputFormatter {
  const CodePointLimit(this.max);

  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.runes.length <= max) return newValue;
    final text = String.fromCharCodes(newValue.text.runes.take(max));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
