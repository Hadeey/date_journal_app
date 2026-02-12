import 'package:date_journal_app/core/constants/app_colors.dart';
import 'package:date_journal_app/core/theme/text_styles.dart';
import 'package:date_journal_app/features/persons/models/person.dart';
import 'package:date_journal_app/features/persons/presentation/providers/persons_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonSelector extends ConsumerWidget {
  final Person? selectedPerson;
  final Function(Person?) onPersonSelected;

  const PersonSelector({
    super.key,
    required this.selectedPerson,
    required this.onPersonSelected,
  });

  void _showAddPersonDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle personne'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Prénom',
            hintText: 'Ex: Sophie',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await ref.read(personsProvider.notifier).addPerson(
                  firstName: nameController.text.trim(),
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personsAsync = ref.watch(personsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Avec qui ?', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        personsAsync.when(
          data: (persons) {
            return DropdownButtonFormField<Person?>(
              value: selectedPerson,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.grey300),
                ),
              ),
              hint: Text('Sélectionner une personne', style: AppTextStyles.body.copyWith(color: AppColors.grey500)),
              items: [
                ...persons.map((person) => DropdownMenuItem<Person?>(
                      value: person,
                      child: Text(person.firstName, style: AppTextStyles.body),
                    )),
                // Special item to add new person
                DropdownMenuItem<Person?>(
                  value: null,
                  enabled: false,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Close dropdown logic if possible, or just catch strict tap
                      // Dropdown handling of buttons inside items is tricky.
                      // Better approach: Add a button next to dropdown or as a specific action.
                      // But for now let's try to put it outside or use a trick.
                      // Actually, standard DropdownMenuItem doesn't support tap well if enabled=false.
                      // Let's just put it in the list but handle selection differently? 
                      // Or use a "+" button next to the dropdown.
                    }, 
                    icon: const Icon(Icons.add),
                    label: const Text('Nouvelle personne'),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onPersonSelected(value);
                }
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Erreur: $err', style: const TextStyle(color: AppColors.error)),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => _showAddPersonDialog(context, ref),
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text('Nouvelle personne'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
