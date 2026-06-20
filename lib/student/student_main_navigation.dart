import 'package:aast_connect/widgets/custom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'screens/student_home.dart';
import 'screens/student_opportunities.dart';
import 'screens/student_profile.dart';
import 'screens/student_support.dart';
import 'screens/student_notifications.dart';
import '../services/notification_service.dart';
import '../services/user_session.dart';

class StudentMainNavigation extends StatefulWidget {
  const StudentMainNavigation({super.key});

  @override
  State<StudentMainNavigation> createState() => _StudentMainNavigationState();
}

class _StudentMainNavigationState extends State<StudentMainNavigation> {
  int _currentIndex = 0;
  int _previousIndex = 0;
  int _unreadCount = 0;

  RealtimeChannel? _notifChannel;
  final NotificationService _notificationService = NotificationService();

  int get _studentId => UserSession.instance.userId!;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    _listenForNotifications();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount(_studentId);
      if (!mounted) return;
      setState(() => _unreadCount = count);
    } catch (e) {
      debugPrint('Error loading unread count: $e');
    }
  }

  void _listenForNotifications() {
    _notifChannel =
        _notificationService.listenToNotifications(_studentId, (payload) {
          if (!mounted) return;

          setState(() => _unreadCount++);

          final message = payload['message'] ?? 'New notification';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              margin: const EdgeInsets.all(16),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              elevation: 0,
              content: AwesomeSnackbarContent(
                title: 'New Notification',
                message: message,
                contentType: ContentType.success,
              ),
              action: SnackBarAction(
                label: 'View',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentNotificationsScreen(),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

  void _changeTab(int index) {
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
  }

  void _goToTraining() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  void dispose() {
    _notifChannel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          StudentHome(
            onSeeAll: _goToTraining,
            unreadNotificationCount: _unreadCount,
          ),
          const StudentOpportunities(),
          StudentProfile(
            shouldRefresh: _currentIndex == 2 && _previousIndex != 2,
          ),
          const StudentSupport(),
        ],
      ),

      bottomNavigationBar: Container(
        color:Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CustomNavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              isSelected: _currentIndex == 0,
              onTap: () => _changeTab(0),
            ),
            CustomNavItem(
              icon: Icons.work_outline,
              label: 'Training',
              isSelected: _currentIndex == 1,
              onTap: () => _changeTab(1),
            ),
            CustomNavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              isSelected: _currentIndex == 2,
              onTap: () => _changeTab(2),
            ),
            CustomNavItem(
              icon: Icons.help_outline,
              label: 'Support',
              isSelected: _currentIndex == 3,
              onTap: () => _changeTab(3),
            ),
          ],
        ),
      ),
    );
  }
}
