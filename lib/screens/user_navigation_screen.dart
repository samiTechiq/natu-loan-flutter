import 'package:flutter/material.dart';
import 'package:staff_loan/screens/user_dashboard_screen.dart';
import 'package:staff_loan/screens/user_history_screen.dart';
import 'package:staff_loan/screens/profile_screen.dart';
import 'package:staff_loan/utils/app_colors.dart';

class UserNavigationScreen extends StatefulWidget {
  const UserNavigationScreen({super.key});

  @override
  State<UserNavigationScreen> createState() => _UserNavigationScreenState();
}

class _UserNavigationScreenState extends State<UserNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    UserDashboardScreen(),
    UserHistoryScreen(),
    ProfileScreen(),
  ];

  final List<NavigationItem> _navigationItems = const [
    NavigationItem(
      icon: Icons.dashboard,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    NavigationItem(
      icon: Icons.history,
      activeIcon: Icons.history_rounded,
      label: 'History',
    ),
    NavigationItem(
      icon: Icons.person,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  _navigationItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isActive = _currentIndex == index;

                    return InkWell(
                      onTap: () => _onItemTapped(index),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isActive
                                  ? AppColors.primaryPurple.withValues(
                                    alpha: 0.1,
                                  )
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                isActive ? item.activeIcon : item.icon,
                                key: ValueKey(isActive),
                                color:
                                    isActive
                                        ? AppColors.primaryPurple
                                        : Colors.grey[600],
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall!.copyWith(
                                fontSize: 12,
                                fontWeight:
                                    isActive
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                color:
                                    isActive
                                        ? AppColors.primaryPurple
                                        : Colors.grey[600],
                              ),
                              child: Text(item.label),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });

      // Refresh user data whenever switching to dashboard
      if (index == 0) {
        UserDashboardScreen.refreshUserData();
      }
    }
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
