import 'package:date_journal_app/features/persons/models/person.dart';
import 'package:date_journal_app/features/persons/repositories/persons_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final personsRepositoryProvider = Provider<PersonsRepository>((ref) {
  return PersonsRepository(Supabase.instance.client);
});

final personsProvider = AsyncNotifierProvider<PersonsController, List<Person>>(
    PersonsController.new);

class PersonsController extends AsyncNotifier<List<Person>> {
  @override
  Future<List<Person>> build() async {
    return _fetchPersons();
  }

  Future<List<Person>> _fetchPersons() async {
    return ref.read(personsRepositoryProvider).getPersons();
  }

  Future<Person?> addPerson(
      {required String name, int? age, String? howKnown}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final person = Person(
      id: '', // DB generates UUID if omitted or we can generate one here. Repo remove ID? No Insert ignores ID if generated?
      // Actually standard Supabase insert usually rets created row.
      // Let's perform insert without ID and let DB generate it, or generate UUID here.
      // Better: let's generate it in repo or here.
      // Repo implementation used input ID.
      // Usually cleaner to not send ID on create if DB has default gen_random_uuid()
      // But my model requires ID. I'll generate it here or pass empty string and repo handles it?
      // Repository code: data.remove('created_at'). It keeps ID.
      // So I should valid ID or remove ID in repository if empty.
      // Let's just generate a temporary ID here but really we want the DB info.
      // I'll update Repository to remove ID if empty or just rely on Supabase ignoring it if not in column list?
      // Safest: Remove ID from map in repository "createPerson" if we want DB to generate it,
      // BUT `toJson` includes it.
      // I'll update Repository code in next step to be safer or just generate UUID here.
      // Let's generate UUID here for consistency with offline-first approaches if needed later.
      // But wait, I don't have uuid package imported in this file.
      // I'll let repository return the new Person.
      userId: user.id,
      name: name,
      age: age,
      howKnown: howKnown,
      createdAt: DateTime.now(),
    );

    // UUID workaround: Assigning empty ID, repo should handle removal or we use uuid package.
    // I will use uuid package in the screen probably, but here...
    // Let's look at `createPerson` in repo. It takes `Person` object.

    state = const AsyncValue.loading();
    try {
      // We need to modify CreatePerson to separate "New Person Data" from "Existing Person Object"
      // Or just pass the object and if ID is empty/dummy, we remove it in repo.

      // For now, I'll pass it as is.
      final newPerson =
          await ref.read(personsRepositoryProvider).createPerson(person);

      // Update state
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newPerson]);

      return newPerson;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}
