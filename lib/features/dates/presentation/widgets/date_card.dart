import 'package:date_journal_app/core/constants/app_colors.dart';
import 'package:date_journal_app/core/theme/text_styles.dart';
import 'package:date_journal_app/features/dates/models/date_entry.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateCard extends StatelessWidget {
  final DateEntry date;
  final VoidCallback onTap;

  const DateCard({super.key, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Date Format
    // Using simple format for now as requested.
    // Ideally use DateFormat from intl package with correct locale.
    final dateString = DateFormat('d MMM', 'fr_FR').format(date.dateTime);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Initial Container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  (date.person?.name ?? '').isNotEmpty
                      ? date.person!.name.substring(0, 1).toUpperCase()
                      : '?',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    date.person?.name ?? 'Inconnu',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 16, color: AppColors.grey500),
                      const SizedBox(width: 6),
                      Text(
                        dateString,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: AppColors.grey500),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          date.location,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < date.ratingOverall
                            ? Icons.star
                            : Icons.star_border,
                        size: 20,
                        color: index < date.ratingOverall
                            ? AppColors.primary
                            : AppColors.grey300,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
