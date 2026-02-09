import 'package:flutter/foundation.dart';

/// ANSI color codes for terminal output (supported in most IDEs and terminals).
/// Use e.g. '\x1B[31m' red, '\x1B[32m' green, '\x1B[33m' yellow, '\x1B[35m' magenta, '\x1B[36m' cyan.
abstract final class _Ansi {
  static const String reset = '\x1B[0m';
  static const String cyan = '\x1B[36m';
}

/// Colored debug logs. Only prints when [kDebugMode] is true.
void appLog(String tag, {required String message, String? color}) {
  final c = color ?? _Ansi.cyan;
  if (!kDebugMode) return;
  // ignore: avoid_print
  print('$c[$tag]${_Ansi.reset} $message');
}
