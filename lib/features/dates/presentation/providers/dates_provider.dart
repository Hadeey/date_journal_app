import 'package:date_journal_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:date_journal_app/features/dates/models/date_entry.dart';
import 'package:date_journal_app/features/dates/repositories/dates_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final datesRepositoryProvider = Provider<DatesRepository>((ref) {
  return DatesRepository(Supabase.instance.client);
});

final datesProvider = AsyncNotifierProvider<DatesController, List<DateEntry>>(
    DatesController.new);

class DatesController extends AsyncNotifier<List<DateEntry>> {
  @override
  Future<List<DateEntry>> build() async {
    return _fetchDates();
  }

  Future<List<DateEntry>> _fetchDates() async {
    // Ensure auth
    final user = ref.read(authRepositoryProvider).getCurrentUser();
    // Assuming repository handles permission or returns valid data for current user
    return ref.read(datesRepositoryProvider).getDates();
  }

  Future<void> createDate(DateEntry date) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(datesRepositoryProvider).createDate(date);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateDate(DateEntry date) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(datesRepositoryProvider).updateDate(date);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteDate(String id) async {
    try {
      // Optimistic update could go here, but simple invalidate is safer
      await ref.read(datesRepositoryProvider).deleteDate(id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final dateDetailProvider =
    FutureProvider.family<DateEntry?, String>((ref, id) async {
  return ref.read(datesRepositoryProvider).getDate(id);
});
