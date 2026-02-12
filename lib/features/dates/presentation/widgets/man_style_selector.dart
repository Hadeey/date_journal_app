import 'package:date_journal_app/core/constants/app_colors.dart';
import 'package:date_journal_app/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

class ManStyleSelector extends StatelessWidget {
  final String? selectedStyle;
  final Function(String) onSelected;

  const ManStyleSelector({
    super.key,
    required this.selectedStyle,
    required this.onSelected,
  });

  static const List<String> styles = [
    'Timide',
    'Romantique',
    'Confiant',
    'Drôle',
    'Mystérieux',
    'Intellectuel',
    'Aventurier',
    'Artiste',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Son style', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: styles.map((style) {
            final isSelected = selectedStyle == style;
            return ChoiceChip(
              label: Text(style),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onSelected(style);
              },
              backgroundColor: AppColors.white,
              selectedColor: AppColors.secondary,
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.text,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.grey300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
