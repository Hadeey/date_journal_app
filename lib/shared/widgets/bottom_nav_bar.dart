import 'package:date_journal_app/core/constants/app_colors.dart';
import 'package:date_journal_app/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return;
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/stats');
            break;
          case 2:
            context.go('/profile');
            break;
        }
      },
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey500,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: AppStrings.navHome,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: AppStrings.navStats,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: AppStrings.navProfile,
        ),
      ],
    );
  }
}
