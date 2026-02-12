import 'package:date_journal_app/core/constants/app_colors.dart';
import 'package:date_journal_app/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String? displayName;
  final String email;

  const ProfileHeader({super.key, required this.displayName, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.secondary,
          child: Icon(Icons.person, size: 60, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text(
          displayName ?? 'Utilisateur',
          style: AppTextStyles.h2,
        ),
        Text(
          email,
          style: AppTextStyles.body.copyWith(color: AppColors.grey500),
        ),
      ],
    );
  }
}
