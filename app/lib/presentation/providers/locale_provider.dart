import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nousdeux/core/l10n/app_languages.dart';
import 'package:nousdeux/presentation/providers/profile_provider.dart';

/// The phone's language as the app speaks it ([AppLanguages.forDevice]), for
/// screens without a profile (auth, splash).
final deviceLanguageProvider = Provider<String>((ref) {
  return AppLanguages.forDevice(ui.PlatformDispatcher.instance.locale);
});

/// Effective app locale: the profile's language once signed in and loaded,
/// otherwise the phone's (splash, auth, onboarding).
final appLocaleProvider = Provider<Locale>((ref) {
  final profileAsync = ref.watch(myProfileProvider);
  final lang = profileAsync.valueOrNull?.language;
  if (AppLanguages.isSupported(lang)) return Locale(lang!);
  return Locale(AppLanguages.forDevice(ui.PlatformDispatcher.instance.locale));
});
