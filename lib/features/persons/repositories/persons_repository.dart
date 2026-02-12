import 'package:date_journal_app/features/persons/models/person.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonsRepository {
  final SupabaseClient _supabase;

  PersonsRepository(this._supabase);

  Future<List<Person>> getPersons() async {
    final response = await _supabase
        .from('persons')
        .select()
        .order('first_name', ascending: true);
    
    return (response as List).map((e) => Person.fromJson(e)).toList();
  }

  Future<void> addPerson({required String firstName, String? notes}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _supabase.from('persons').insert({
      'user_id': user.id,
      'first_name': firstName,
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updatePerson(Person person) async {
    await _supabase.from('persons').update({
      'first_name': person.firstName,
      'notes': person.notes,
    }).eq('id', person.id);
  }

  Future<void> deletePerson(String id) async {
    await _supabase.from('persons').delete().eq('id', id);
  }
}
