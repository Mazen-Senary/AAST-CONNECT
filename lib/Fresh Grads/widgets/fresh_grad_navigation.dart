import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/opportunities_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/support_screen.dart';
import '../widgets/aast_app_bar.dart';
import '../theme/app_theme.dart';

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class MainScaffold extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeToggle;

  const MainScaffold({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    OpportunitiesScreen(),
    ProfileScreen(),
    SupportScreen(),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.work_outline,
      activeIcon: Icons.work_rounded,
      label: 'Opportunities',
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
    _NavItem(
      icon: Icons.help_outline,
      activeIcon: Icons.help_rounded,
      label: 'Support',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AastAppBar(
        isDark: widget.isDark,
        onThemeToggle: widget.onThemeToggle,
        onLogout: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  Widget _buildCustomBottomNavBar() {
    final isDark = widget.isDark;

    const Color activeHighlight = Color(0xFFE8F5E9);
    const Color activeIcon = AppColors.primaryGreen;
    const Color inactiveIcon = AppColors.textSecondary;
    final Color navBg = isDark ? AppColors.darkCardBg : Colors.white;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: navBg,
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
          final item = _navItems[index];

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _currentIndex = index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                      ? AppColors.primaryGreen.withOpacity(0.15)
                      : activeHighlight)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected ? activeIcon : inactiveIcon,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? activeIcon : inactiveIcon,
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