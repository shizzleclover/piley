import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/supabase_service.dart';
import 'core/services/offline_service.dart';
import 'core/services/favorites_service.dart';
import 'core/theme/app_theme.dart';
import 'main_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Environment Variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await SupabaseService().initialize();

  // Initialize Offline Storage
  await OfflineService().init();
  await FavoritesService().init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piley',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      home: const AppShell(),
    );
  }
}
