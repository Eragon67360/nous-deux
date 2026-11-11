/// Turns what people type into an E.164 number for SMS sign-in.
///
/// Numbers without a country code are treated as French:
/// "06 12 34 56 78" → "+33612345678". "0033…" becomes "+33…".
String normalizePhone(String input, {String defaultCountryCode = '+33'}) {
  final compact = input.replaceAll(RegExp(r'[\s.\-()]'), '');
  if (compact.isEmpty) return compact;
  if (compact.startsWith('+')) return compact;
  if (compact.startsWith('00')) return '+${compact.substring(2)}';
  if (compact.startsWith('0')) {
    return '$defaultCountryCode${compact.substring(1)}';
  }
  return '$defaultCountryCode$compact';
}
