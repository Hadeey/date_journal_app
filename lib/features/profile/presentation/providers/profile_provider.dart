import 'package:date_journal_app/features/auth/models/user.dart';
import 'package:date_journal_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for user profile data (just reuses auth user logic but could be extended)
final profileProvider = FutureProvider<User?>((ref) async {
  final authRepo = ref.read(authRepositoryProvider);
  return authRepo.getCurrentUser();
});

class ProfileController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateDisplayName(String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).updateProfile(displayName: name);
      ref.invalidate(profileProvider); // Refresh profile data
    });
  }

  Future<void> toggleBiometrics(bool enabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // In a real app, we would verify biometrics before enabling
      if (enabled) {
         final LocalAuthentication auth = LocalAuthentication();
         final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
         if (!canAuthenticateWithBiometrics) {
           throw Exception('Biométrie non disponible');
         }
         // We might ask for auth here to confirm
      }
      
      // Save preference locally or in DB.
      // The schema has bio_enabled.
      await ref.read(authRepositoryProvider).updateProfile(bioEnabled: enabled);
      ref.invalidate(profileProvider);
      
      // Also save to shared prefs for quick check at launch
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometrics_enabled', enabled);
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await ref.read(authControllerProvider.notifier).signOut();
    // Router should handle redirect
  }
}

final profileControllerProvider = AsyncNotifierProvider<ProfileController, void>(ProfileController.new);
