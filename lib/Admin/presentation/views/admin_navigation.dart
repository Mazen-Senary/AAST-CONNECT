import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_dashboard.dart';
import 'opportunities_screen.dart';
import 'student_profiles_screen.dart';
import 'approvals_screen.dart';
import 'theme_provider.dart';
import '../../theme/app_colors.dart';

class AdminNavigation extends StatefulWidget {
  final int adminId;

  const AdminNavigation({super.key, required this.adminId});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const AdminDashboard(),
      OpportunitiesScreen(adminId: widget.adminId),
      const StudentProfilesScreen(),
      const ApprovalsScreen(),
    ];
  }

  final List<NavigationItem> _navItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    NavigationItem(
      icon: Icons.work_outline,
      activeIcon: Icons.work,
      label: 'Opportunities',
    ),
    NavigationItem(
      icon: Icons.group_outlined,
      activeIcon: Icons.group,
      label: 'Students',
    ),
    NavigationItem(
      icon: Icons.access_time_outlined,
      activeIcon: Icons.access_time,
      label: 'Approvals',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Theme(
          data: themeProvider.currentTheme,
          child: Scaffold(
            body: IndexedStack(index: _currentIndex, children: _screens),
            bottomNavigationBar: _buildCustomBottomNavBar(themeProvider),
          ),
        );
      },
    );
  }

  Widget _buildCustomBottomNavBar(ThemeProvider themeProvider) {
    final isDark = themeProvider.isDarkMode;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_navItems.length, (index) {
          final bool isSelected = _currentIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentInfo : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _navItems[index].icon,
                      color: isSelected
                          ? AppColors.interactive
                          : AppColors.textMuted,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _navItems[index].label,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.interactive
                            : AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
