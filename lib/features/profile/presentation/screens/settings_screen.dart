import 'package:date_journal_app/core/constants/app_colors.dart';
import 'package:date_journal_app/core/theme/text_styles.dart';
import 'package:date_journal_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:date_journal_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:date_journal_app/shared/widgets/bottom_nav_bar.dart';
import 'package:date_journal_app/shared/widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: profileAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Non connecté'));
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                ProfileHeader(
                  displayName: user.displayName,
                  email: user.email,
                ),
                const SizedBox(height: 48),

                // Settings Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline, color: AppColors.primary),
                        title: const Text('Modifier le nom'),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.grey500),
                        onTap: () {
                          _showEditNameDialog(context, ref, user.displayName ?? '');
                        },
                      ),
                      const SizedBox(height: 8, child: Divider(height: 0.5, color: AppColors.grey300)),
                      ListTile(
                        leading: const Icon(Icons.fingerprint, color: AppColors.primary),
                        title: const Text('Touch ID / Face ID'),
                        trailing: Switch(
                          value: user.bioEnabled,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                             ref.read(profileControllerProvider.notifier).toggleBiometrics(val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.grey500),
                  title: const Text('À propos'),
                  subtitle: const Text('Version 1.0.0'),
                ),
                
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _showLogoutDialog(context, ref);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Se déconnecter'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingSpinner(),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le nom'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nom affiché'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                 await ref.read(profileControllerProvider.notifier).updateDisplayName(controller.text.trim());
                 if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(profileControllerProvider.notifier).signOut();
              if (context.mounted) context.go('/login'); // Force navigation
            },
            child: const Text('Se déconnecter', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
