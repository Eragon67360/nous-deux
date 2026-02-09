import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nous_deux/core/config/app_config.dart';
import 'package:nous_deux/core/utils/app_router.dart';
import 'package:nous_deux/presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.isSupabaseConfigured) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
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
    );
  }
}
