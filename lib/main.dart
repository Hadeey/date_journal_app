import 'package:date_journal_app/core/config/supabase_initializer.dart';
import 'package:date_journal_app/core/routes/app_router.dart';
import 'package:date_journal_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation Supabase
  await SupabaseInitializer.init(); 

  // Initialisation intl local data
  await initializeDateFormatting('fr_FR', null);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Date Journal',
      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme, // To be implemented
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
