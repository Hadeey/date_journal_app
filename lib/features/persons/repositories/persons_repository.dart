import 'package:date_journal_app/features/persons/models/person.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonsRepository {
  final SupabaseClient _supabase;

  PersonsRepository(this._supabase);

  Future<List<Person>> getPersons() async {
    final response = await _supabase
        .from('persons')
        .select('*, dates(count)')
        .order('name', ascending: true);

    return (response as List).map((e) => Person.fromJson(e)).toList();
  }

  Future<Person> createPerson(Person person) async {
    final data = person.toJson();
    data.remove('created_at'); // DB handles it
    data.remove('id'); // Remove ID so DB generates a new UUID

    final response =
        await _supabase.from('persons').insert(data).select().single();

    return Person.fromJson(response);
  }

  Future<void> updatePerson(Person person) async {
    final data = person.toJson();
    data.remove('created_at');
    data.remove('user_id');

    await _supabase.from('persons').update(data).eq('id', person.id);
  }
}
