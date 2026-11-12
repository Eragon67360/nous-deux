import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True once the splash screen entrance animation has completed.
/// Used by the router to avoid redirecting away from `/` before the animation finishes.
final splashAnimationCompleteProvider = StateProvider<bool>((ref) => false);
