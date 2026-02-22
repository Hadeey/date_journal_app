import 'package:date_journal_app/core/constants/app_colors.dart';
import 'package:date_journal_app/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffoldShell extends StatelessWidget {
  final Widget child;
  final String currentLocation;

  const MainScaffoldShell({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: Container(
        height: 64, // Slightly larger
        width: 64,
        margin: const EdgeInsets.only(top: 30), // Push it up slightly
        child: FloatingActionButton(
          onPressed: () => context.push('/date/new'),
          backgroundColor: AppColors.primary,
          elevation: 4,
          shape: const CircleBorder(), // Round
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        height: 80, // Increased to fit content comfortably
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Side
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavBarItem(
                      icon: Icons.calendar_today_outlined,
                      activeIcon: Icons.calendar_today,
                      label: AppStrings.navHome,
                      isSelected: currentLocation == '/',
                      onTap: () => context.go('/'),
                    ),
                    _NavBarItem(
                      icon: Icons.people_outline,
                      activeIcon: Icons.people,
                      label: 'Rencontres',
                      isSelected: currentLocation == '/persons',
                      onTap: () => context.go('/persons'),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 48), // Gap for FAB

              // Right Side
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavBarItem(
                      icon: Icons.bar_chart_outlined,
                      activeIcon: Icons.bar_chart,
                      label: AppStrings.navStats,
                      isSelected: currentLocation == '/stats',
                      onTap: () => context.go('/stats'),
                    ),
                    _NavBarItem(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: AppStrings.navProfile,
                      isSelected: currentLocation == '/profile',
                      onTap: () => context.go('/profile'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.grey500,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.grey500,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
