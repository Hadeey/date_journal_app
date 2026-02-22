import 'package:date_journal_app/core/constants/app_colors.dart';
import 'package:date_journal_app/core/theme/text_styles.dart';
import 'package:date_journal_app/features/persons/presentation/providers/persons_provider.dart';
import 'package:date_journal_app/shared/widgets/loading_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonsListScreen extends ConsumerWidget {
  const PersonsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personsAsync = ref.watch(personsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mes Rencontres',
          style: AppTextStyles.h2.copyWith(color: AppColors.text, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: personsAsync.when(
        data: (persons) {
          if (persons.isEmpty) {
            return Center(
              child: Text(
                'Aucune personne enregistrée',
                style: AppTextStyles.body.copyWith(color: AppColors.grey500),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: persons.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final person = persons[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        person.name.isNotEmpty
                            ? person.name.substring(0, 1).toUpperCase()
                            : '?',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    person.name,
                    style: AppTextStyles.h3.copyWith(fontSize: 18),
                  ),
                  subtitle: Text(
                    [
                      if (person.age != null) '${person.age} ans',
                      if (person.howKnown != null) person.howKnown!,
                    ].join(' • '),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${person.dateCount} dates',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingSpinner(),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}
