import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/presentation/providers/profile_provider.dart';

/// Device-only language ('fr' or 'en') for screens without profile (auth, splash).
final deviceLanguageProvider = Provider<String>((ref) {
  final locale = ui.PlatformDispatcher.instance.locale;
  return locale.languageCode.startsWith('fr') ? 'fr' : 'en';
});

/// Effective app locale: profile language when signed in and profile loaded,
/// otherwise device locale (or default French) for splash, auth, onboarding.
final appLocaleProvider = Provider<Locale>((ref) {
  final profileAsync = ref.watch(myProfileProvider);
  final lang = profileAsync.valueOrNull?.language;
  if (lang == 'fr' || lang == 'en') return Locale(lang!);
  final deviceLocale = ui.PlatformDispatcher.instance.locale;
  return deviceLocale.languageCode.startsWith('fr')
      ? const Locale('fr')
      : const Locale('en');
});
