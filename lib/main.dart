import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nousdeux/core/config/app_config.dart';
import 'package:nousdeux/core/services/fcm_service.dart';
import 'package:nousdeux/core/services/period_reminder_service.dart';
import 'package:nousdeux/core/utils/app_router.dart';
import 'package:nousdeux/presentation/providers/auth_provider.dart';
import 'package:nousdeux/presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('fr_FR', null);
  await initializeDateFormatting('en_US', null);

  if (AppConfig.isSupabaseConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  if (AppConfig.isMapboxConfigured) {
    MapboxOptions.setAccessToken(AppConfig.mapboxAccessToken);
  }

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase not configured (e.g. missing google-services.json); app works without push.
  }

  try {
    await initPeriodReminderNotifications();
  } catch (_) {
    // Local notifications may not be available.
  }

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = AppTheme.dark;
    if (!AppConfig.isSupabaseConfigured) {
      return MaterialApp(
        title: 'Nous Deux',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: theme,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Configurez Supabase : définissez SUPABASE_URL et SUPABASE_ANON_KEY via --dart-define.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Nous Deux',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      routerConfig: router,
      builder: (context, child) => _FcmRegistration(child: child),
    );
  }
}

/// Registers FCM token with profile when user is signed in (once per session).
class _FcmRegistration extends ConsumerStatefulWidget {
  const _FcmRegistration({this.child});
  final Widget? child;

  @override
  ConsumerState<_FcmRegistration> createState() => _FcmRegistrationState();
}

class _FcmRegistrationState extends ConsumerState<_FcmRegistration> {
  bool _registered = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    if (user == null) {
      _registered = false;
    } else if (!_registered) {
      _registered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        registerFcmToken(ref);
      });
    }
    return widget.child ?? const SizedBox.shrink();
  }
}
