import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:date_journal_app/core/config/supabase_config.dart';

class SupabaseInitializer {
  static Future<void> init() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }
}
