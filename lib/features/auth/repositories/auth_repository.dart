import 'package:date_journal_app/features/auth/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  Stream<User?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((event) {
      final session = event.session;
      if (session?.user == null) return null;
      return User(
        id: session!.user.id,
        email: session.user.email ?? '',
      );
    });
  }

  Future<User?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      
      return User.fromSupabase(data, user.email);
    } catch (e) {
      return User(id: user.id, email: user.email ?? '');
    }
  }

  Future<void> signInWithEmail({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail({required String email, required String password}) async {
      await _supabase.auth.signUp(
        email: email,
        password: password,
      );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> updateProfile({String? displayName, bool? bioEnabled}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{};
    if (displayName != null) updates['display_name'] = displayName;
    if (bioEnabled != null) updates['bio_enabled'] = bioEnabled;
    updates['updated_at'] = DateTime.now().toIso8601String();

    await _supabase.from('profiles').update(updates).eq('id', user.id);
  }
}
