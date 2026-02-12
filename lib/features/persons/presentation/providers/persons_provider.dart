import 'package:date_journal_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:date_journal_app/features/persons/models/person.dart';
import 'package:date_journal_app/features/persons/repositories/persons_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final personsRepositoryProvider = Provider<PersonsRepository>((ref) {
  return PersonsRepository(Supabase.instance.client);
});

final personsProvider = AsyncNotifierProvider<PersonsController, List<Person>>(PersonsController.new);

class PersonsController extends AsyncNotifier<List<Person>> {
  @override
  Future<List<Person>> build() async {
    return _fetchPersons();
  }

  Future<List<Person>> _fetchPersons() async {
     // Ensure user is authenticated
     final user = ref.read(authRepositoryProvider).getCurrentUser();
     // Ideally we should wait or check, but repository handles auth check usually or returns empty/error
     // The repository implementation checks for currentUser.
     return ref.read(personsRepositoryProvider).getPersons();
  }

  Future<void> addPerson({required String firstName, String? notes}) async {
    state = const AsyncValue.loading();
    await AsyncValue.guard(() async {
      await ref.read(personsRepositoryProvider).addPerson(firstName: firstName, notes: notes);
    });
    ref.invalidateSelf(); // Reload list
  }

  Future<void> deletePerson(String id) async {
    // Optimistic update could be done here, but simple reload is safer for MVP
    await ref.read(personsRepositoryProvider).deletePerson(id);
    ref.invalidateSelf();
  }
}
