// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../screens/home_screen.dart';
// import '../screens/opportunities_screen.dart';
// import '../screens/profile_screen.dart';
// import '../screens/support_screen.dart';
// import '../screens/fresh_grad_notifications.dart';
// import '../widgets/aast_app_bar.dart';
// import '../theme/app_theme.dart';
// import '../../services/fresh_grad_opportunity_notification_service.dart';
// import '../../services/notification_service.dart';
// import '../../services/user_session.dart';
//
// class _NavItem {
//   final IconData icon;
//   final IconData activeIcon;
//   final String label;
//
//   const _NavItem({
//     required this.icon,
//     required this.activeIcon,
//     required this.label,
//   });
// }
//
// class FreshGradNavigation extends StatefulWidget {
//   const FreshGradNavigation({super.key});
//
//   @override
//   State<FreshGradNavigation> createState() => _FreshGradNavigationState();
// }
//
// class _FreshGradNavigationState extends State<FreshGradNavigation> {
//   int _currentIndex = 0;
//   int _unreadCount = 0;
//
//   RealtimeChannel? _notifChannel;
//   RealtimeChannel? _vacancyChannel;
//   final NotificationService _notificationService = NotificationService();
//   final FreshGradOpportunityNotificationService
//   _opportunityNotificationService = FreshGradOpportunityNotificationService();
//   final SupabaseClient _supabase = Supabase.instance.client;
//
//   final List<Widget> _screens = const [
//     HomeScreen(),
//     OpportunitiesScreen(),
//     ProfileScreen(),
//     SupportScreen(),
//   ];
//
//   static const List<_NavItem> _navItems = [
//     _NavItem(
//       icon: Icons.home_outlined,
//       activeIcon: Icons.home_rounded,
//       label: 'Home',
//     ),
//     _NavItem(
//       icon: Icons.work_outline,
//       activeIcon: Icons.work_rounded,
//       label: 'Opportunities',
//     ),
//     _NavItem(
//       icon: Icons.person_outline,
//       activeIcon: Icons.person_rounded,
//       label: 'Profile',
//     ),
//     _NavItem(
//       icon: Icons.help_outline,
//       activeIcon: Icons.help_rounded,
//       label: 'Support',
//     ),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUnreadCount();
//     _listenForNotifications();
//     _listenForGraduateVacancies();
//   }
//
//   int get _userId => UserSession.instance.userId!;
//
//   Future<void> _loadUnreadCount() async {
//     final notificationCount = await _notificationService.getUnreadCount(
//       _userId,
//     );
//     final opportunityCount = await _opportunityNotificationService
//         .unreadOpportunityCount(_userId);
//     if (!mounted) return;
//     setState(() => _unreadCount = notificationCount + opportunityCount);
//   }
//
//   void _listenForNotifications() {
//     _notifChannel = _notificationService.listenToNotifications(_userId, (
//       payload,
//     ) {
//       if (!mounted) return;
//       setState(() => _unreadCount++);
//
//       final message = payload['message']?.toString() ?? 'New notification';
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           action: SnackBarAction(label: 'View', onPressed: _openNotifications),
//         ),
//       );
//     });
//   }
//
//   void _listenForGraduateVacancies() {
//     _vacancyChannel = _supabase
//         .channel('fresh-grad-vacancies')
//         .onPostgresChanges(
//           event: PostgresChangeEvent.insert,
//           schema: 'public',
//           table: 'vacancies',
//           callback: (payload) async {
//             final vacancy = payload.newRecord;
//             final audience = vacancy['target_audience']?.toString();
//             if (audience != 'GRADUATE' && audience != 'BOTH') return;
//
//             final title = vacancy['title']?.toString() ?? 'New opportunity';
//             final company =
//                 vacancy['company_name']?.toString() ?? 'AAST Connect';
//             final message =
//                 'New graduate opportunity posted: $title at $company';
//
//             if (!mounted) return;
//             setState(() => _unreadCount++);
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(message),
//                 action: SnackBarAction(
//                   label: 'View',
//                   onPressed: _openNotifications,
//                 ),
//               ),
//             );
//           },
//         )
//         .subscribe();
//   }
//
//   void _openNotifications() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const FreshGradNotificationsScreen()),
//     ).then((_) => _loadUnreadCount());
//   }
//
//   @override
//   void dispose() {
//     _notifChannel?.unsubscribe();
//     _vacancyChannel?.unsubscribe();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: AppTheme.light(),
//       child: Scaffold(
//         appBar: AastAppBar(
//           isDark: false,
//           onThemeToggle: () {},
//           unreadNotificationCount: _unreadCount,
//           onNotificationsPressed: _openNotifications,
//         ),
//         body: IndexedStack(index: _currentIndex, children: _screens),
//         bottomNavigationBar: _buildCustomBottomNavBar(false),
//       ),
//     );
//   }
//
//   Widget _buildCustomBottomNavBar(bool isDark) {
//     const Color inactiveIcon = AppColors.textSecondary;
//
//     final Color navBg = isDark ? AppColors.darkCardBg : Colors.white;
//
//     return Container(
//       height: 80,
//       decoration: BoxDecoration(
//         color: navBg,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: List.generate(_navItems.length, (index) {
//           final bool isSelected = _currentIndex == index;
//           final item = _navItems[index];
//
//           return Expanded(
//             child: GestureDetector(
//               behavior: HitTestBehavior.opaque,
//               onTap: () => setState(() => _currentIndex = index),
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? const Color(0xFFD6EAF1)
//                       : Colors.transparent,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       isSelected ? item.activeIcon : item.icon,
//                       color: isSelected
//                           ? const Color(0xFF1B6FA8)
//                           : inactiveIcon,
//                       size: 24,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       item.label,
//                       style: TextStyle(
//                         color: isSelected
//                             ? const Color(0xFF1B6FA8)
//                             : inactiveIcon,
//                         fontSize: 12,
//                         fontWeight: isSelected
//                             ? FontWeight.w600
//                             : FontWeight.w400,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/app_colors.dart';
import '../screens/home_screen.dart';
import '../screens/opportunities_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/fresh_grad_tracking.dart';
import '../screens/fresh_grad_notifications.dart';
import '../screens/support_screen.dart';
import '../widgets/aast_app_bar.dart';
import '../../services/app_refresh_service.dart';
import '../../services/fresh_grad_opportunity_notification_service.dart';
import '../../services/notification_service.dart';
import '../../services/theme_provider.dart';
import '../../services/user_session.dart';
import '../../widgets/professional_app_chrome.dart';

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

class FreshGradNavigation extends StatefulWidget {
  const FreshGradNavigation({super.key});

  @override
  State<FreshGradNavigation> createState() => _FreshGradNavigationState();
}

class _FreshGradNavigationState extends State<FreshGradNavigation> {
  int _currentIndex = 0;
  int _previousIndex = 0;
  int _unreadCount = 0;

  RealtimeChannel? _notifChannel;
  RealtimeChannel? _vacancyChannel;
  RealtimeChannel? _applicationChannel;
  Timer? _refreshDebounce;

  final NotificationService _notificationService = NotificationService();
  final FreshGradOpportunityNotificationService
  _opportunityNotificationService =
  FreshGradOpportunityNotificationService();

  final SupabaseClient _supabase = Supabase.instance.client;

  final List<Widget> _screens = const [
    HomeScreen(),
    OpportunitiesScreen(),
    ProfileScreen(),
    FreshGradTrackingScreen(embedded: true),
    SupportScreen(embedded: true),
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
      icon: Icons.track_changes_outlined,
      activeIcon: Icons.track_changes,
      label: 'Tracking',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    _listenForNotifications();
    _listenForGraduateVacancies();
    _listenForLiveDataChanges();
  }

  int get _userId => UserSession.instance.userId!;

  Future<void> _loadUnreadCount() async {
    final notificationCount =
    await _notificationService.getUnreadCount(_userId);
    final opportunityCount =
    await _opportunityNotificationService
        .unreadOpportunityCount(_userId);

    if (!mounted) return;
    setState(() => _unreadCount = notificationCount + opportunityCount);
  }

  void _scheduleRefresh() {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _loadUnreadCount();
      AppRefreshService.instance.notifyDataChanged();
    });
  }

  void _listenForNotifications() {
    _notifChannel =
        _notificationService.listenToNotifications(_userId, (payload) {
          if (!mounted) return;

          setState(() => _unreadCount++);
          _scheduleRefresh();

          final message =
              payload['message']?.toString() ?? 'New notification';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              action: SnackBarAction(
                label: 'View',
                onPressed: _openNotifications,
              ),
            ),
          );
        });
  }

  void _listenForLiveDataChanges() {
    _applicationChannel = _supabase
        .channel('fresh-grad-application-live:$_userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'application',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'applicantid',
            value: _userId,
          ),
          callback: (_) => _scheduleRefresh(),
        )
        .subscribe();
  }

  void _listenForGraduateVacancies() {
    _vacancyChannel = _supabase
        .channel('fresh-grad-vacancies')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'vacancies',
      callback: (payload) async {
        final vacancy = payload.newRecord;
        final audience =
        vacancy['target_audience']?.toString();

        if (audience != 'GRADUATE' && audience != 'BOTH') return;

        final title =
            vacancy['title']?.toString() ?? 'New opportunity';
        final company =
            vacancy['company_name']?.toString() ?? 'AAST Connect';

        final message =
            'New graduate opportunity posted: $title at $company';

        if (!mounted) return;

        setState(() => _unreadCount++);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            action: SnackBarAction(
              label: 'View',
              onPressed: _openNotifications,
            ),
          ),
        );
      },
    )
        .subscribe();
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FreshGradNotificationsScreen(),
      ),
    ).then((_) => _loadUnreadCount());
  }

  void _openTracking() {
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = 3;
    });
    AppRefreshService.instance.notifyDataChanged();
  }

  void _openSupport() {
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = 4;
    });
    AppRefreshService.instance.notifyDataChanged();
  }

  int get _selectedNavIndex => _currentIndex > 3 ? _previousIndex : _currentIndex;

  @override
  void dispose() {
    _notifChannel?.unsubscribe();
    _vacancyChannel?.unsubscribe();
    _applicationChannel?.unsubscribe();
    _refreshDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AastAppBar(
        isDark: isDark,
        onThemeToggle: () =>
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
        unreadNotificationCount: _unreadCount,
        onTrackingPressed: _openTracking,
        onSupportPressed: _openSupport,
        onNotificationsPressed: _openNotifications,
        onProfilePressed: () => setState(() {
          _previousIndex = _currentIndex;
          _currentIndex = 2;
        AppRefreshService.instance.notifyDataChanged();
        }),
        onChatbotPressed: () => showChatbotSheet(context),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(child: _buildCustomBottomNavBar()),
    );
  }
  Widget _buildCustomBottomNavBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? Theme.of(context).colorScheme.surface : Colors.white;
    final selectedBg = isDark
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.16)
        : AppColors.navSelectedBackground;
    final selectedColor = isDark
        ? Theme.of(context).colorScheme.primary
        : AppColors.navSelectedIcon;
    final unselectedColor = isDark
        ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.62)
        : AppColors.navUnselectedIcon;

    return Container(
      height: 86.h,
      decoration: BoxDecoration(
        color: navBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_navItems.length, (index) {
          final isSelected = _selectedNavIndex == index;
          final item = _navItems[index];

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() {
                _previousIndex = _currentIndex;
                _currentIndex = index;
                AppRefreshService.instance.notifyDataChanged();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? selectedBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected ? selectedColor : unselectedColor,
                      size: 24.sp,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected
                            ? selectedColor
                            : unselectedColor,
                        fontSize: 12.sp,
                        fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
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
