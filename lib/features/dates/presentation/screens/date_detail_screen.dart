import 'package:date_journal_app/core/constants/app_colors.dart';
import 'package:date_journal_app/core/theme/text_styles.dart';
import 'package:date_journal_app/features/dates/models/date_entry.dart';
import 'package:date_journal_app/features/dates/presentation/providers/dates_provider.dart';
import 'package:date_journal_app/shared/widgets/loading_spinner.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class DateDetailScreen extends ConsumerWidget {
  final String dateId;

  const DateDetailScreen({super.key, required this.dateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateAsync = ref.watch(dateDetailProvider(dateId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/date/$dateId/edit');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Supprimer'),
                  content:
                      const Text('Voulez-vous vraiment supprimer cette date ?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Supprimer',
                            style: TextStyle(color: AppColors.error))),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(datesProvider.notifier).deleteDate(dateId);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: dateAsync.when(
        data: (date) {
          if (date == null)
            return const Center(child: Text('Date introuvable'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date.person?.firstName ?? 'Inconnu',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 32,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            index < date.ratingOverall.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _DetailSection(
                      title: 'Date',
                      content: DateFormat('EEEE d MMMM yyyy', 'fr_FR')
                          .format(date.dateTime),
                      icon: Icons.calendar_today),
                ),

                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _DetailSection(
                      title: 'Heure',
                      content:
                          DateFormat('HH:mm', 'fr_FR').format(date.dateTime),
                      icon: Icons.access_time),
                ),

                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _DetailSection(
                      title: 'Lieu', content: date.location, icon: Icons.place),
                ),
                const SizedBox(height: 24),

                // Radar Chart
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evaluation détaillée',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 250,
                        child: RadarChart(
                          RadarChartData(
                            dataSets: [
                              RadarDataSet(
                                fillColor: AppColors.primary.withOpacity(0.2),
                                borderColor: AppColors.primary,
                                entryRadius: 3,
                                dataEntries: [
                                  RadarEntry(
                                      value: date.ratingChemistry.toDouble()),
                                  RadarEntry(
                                      value:
                                          date.ratingConversation.toDouble()),
                                  RadarEntry(
                                      value: date.ratingPunctuality.toDouble()),
                                  RadarEntry(
                                      value: date.ratingAppearance.toDouble()),
                                ],
                              ),
                            ],
                            radarBackgroundColor: Colors.transparent,
                            borderData: FlBorderData(show: false),
                            radarBorderData:
                                const BorderSide(color: AppColors.grey300),
                            titlePositionPercentageOffset: 0.2,
                            titleTextStyle: AppTextStyles.caption
                                .copyWith(color: AppColors.text, fontSize: 12),
                            getTitle: (index, angle) {
                              switch (index) {
                                case 0:
                                  return const RadarChartTitle(
                                      text: 'Alchimie');
                                case 1:
                                  return const RadarChartTitle(
                                      text: 'Conversation');
                                case 2:
                                  return const RadarChartTitle(
                                      text: 'Ponctualité');
                                case 3:
                                  return const RadarChartTitle(
                                      text: 'Apparence');
                                default:
                                  return const RadarChartTitle(text: '');
                              }
                            },
                            tickCount: 1,
                            ticksTextStyle:
                                const TextStyle(color: Colors.transparent),
                            gridBorderData: const BorderSide(
                                color: AppColors.grey300, width: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (date.whatWeDid != null && date.whatWeDid!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: _DetailSection(
                        title: 'Activité',
                        content: date.whatWeDid!,
                        icon: Icons.local_activity),
                  ),
                if (date.manStyle != null && date.manStyle!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: _DetailSection(
                        title: 'Style',
                        content: date.manStyle!,
                        icon: Icons.style),
                  ),
                if (date.hisBehavior != null && date.hisBehavior!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: _DetailSection(
                        title: 'Son comportement',
                        content: date.hisBehavior!,
                        icon: Icons.person_outline),
                  ),

                const SizedBox(height: 16),
                if (date.greenFlags != null && date.greenFlags!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.success.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle,
                                color: AppColors.success, size: 20),
                            const SizedBox(width: 8),
                            Text('Green Flags',
                                style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          date.greenFlags!,
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                if (date.redFlags != null && date.redFlags!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.warning,
                                color: AppColors.error, size: 20),
                            const SizedBox(width: 8),
                            Text('Red Flags',
                                style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          date.redFlags!,
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                if (date.myNotes != null && date.myNotes!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Mes notes privées', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(date.myNotes!,
                      style: AppTextStyles.body
                          .copyWith(fontStyle: FontStyle.italic)),
                ],

                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const LoadingSpinner(),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _DetailSection(
      {required this.title, required this.content, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
