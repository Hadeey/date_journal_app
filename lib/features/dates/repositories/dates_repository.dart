import 'package:date_journal_app/features/dates/models/date_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DatesRepository {
  final SupabaseClient _supabase;

  DatesRepository(this._supabase);

  Future<List<DateEntry>> getDates() async {
    final response = await _supabase
        .from('dates')
        .select('*, persons(*)')
        .order('date_time', ascending: false);

    return (response as List).map((e) => DateEntry.fromJson(e)).toList();
  }

  Future<DateEntry?> getDate(String id) async {
    final response = await _supabase
        .from('dates')
        .select('*, persons(*)')
        .eq('id', id)
        .single();

    return DateEntry.fromJson(response);
  }

  Future<void> createDate(DateEntry date) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Reuse logic from DateModel toJson but here we have DateEntry
    final data = date.toJson();
    data.remove('created_at'); // DB handles it
    // IDs are passed from client logic (cleaner to let DB handle but client generated UUIDs are fine)

    await _supabase.from('dates').insert(data);
  }

  Future<void> updateDate(DateEntry date) async {
    final data = date.toJson();
    data.remove('created_at');
    data.remove('user_id');

    await _supabase.from('dates').update(data).eq('id', date.id);
  }

  Future<void> deleteDate(String id) async {
    await _supabase.from('dates').delete().eq('id', id);
  }
}
