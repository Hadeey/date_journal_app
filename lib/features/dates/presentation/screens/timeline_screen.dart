import 'package:date_journal_app/core/constants/app_colors.dart';
import 'package:date_journal_app/core/theme/text_styles.dart';
import 'package:date_journal_app/features/dates/presentation/providers/dates_provider.dart';
import 'package:date_journal_app/features/dates/presentation/widgets/date_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datesAsync = ref.watch(datesProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF6B9D),
                  Color(0xFFF8C4D8),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment:
                    Alignment.centerLeft, // ⬅️ gauche + centré verticalement
                child: Text(
                  'Mes Dates',
                  style: AppTextStyles.h2.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: datesAsync.when(
        data: (dates) {
          if (dates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border,
                      size: 60, color: AppColors.grey300),
                  const SizedBox(height: 16),
                  Text(
                    'Pas encore de dates ?\nC\'est le moment de sortir !',
                    textAlign: TextAlign.center,
                    style:
                        AppTextStyles.body.copyWith(color: AppColors.grey500),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(datesProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(26),
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                return DateCard(
                  date: date,
                  onTap: () {
                    context.push('/date/${date.id}');
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}
