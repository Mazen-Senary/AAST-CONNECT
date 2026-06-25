import 'dart:async';

import 'package:aast_connect/widgets/custom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'screens/student_home.dart';
import 'screens/student_opportunities.dart';
import 'screens/student_profile.dart';
import 'screens/student_tracking.dart';
import 'screens/student_notifications.dart';
import 'screens/student_support.dart';
import '../services/app_refresh_service.dart';
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
  RealtimeChannel? _applicationChannel;
  RealtimeChannel? _trainingRecordChannel;
  RealtimeChannel? _studentChannel;
  Timer? _refreshDebounce;
  final NotificationService _notificationService = NotificationService();

  int get _userId => UserSession.instance.userId!;
  int get _studentRecordId => UserSession.instance.studentId ?? _userId;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    _listenForNotifications();
    _listenForLiveDataChanges();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount(_userId);
      if (!mounted) return;
      setState(() => _unreadCount = count);
    } catch (e) {
      debugPrint('Error loading unread count: $e');
    }
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

  void _listenForLiveDataChanges() {
    final supabase = Supabase.instance.client;

    _applicationChannel = supabase
        .channel('student-application-live:$_userId')
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

    _trainingRecordChannel = supabase
        .channel('student-trainingrecord-live:$_studentRecordId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'trainingrecord',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'studentid',
            value: _studentRecordId,
          ),
          callback: (_) => _scheduleRefresh(),
        )
        .subscribe();

    _studentChannel = supabase
        .channel('student-row-live:$_studentRecordId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'student',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'studentid',
            value: _studentRecordId,
          ),
          callback: (_) => _scheduleRefresh(),
        )
        .subscribe();
  }

  void _changeTab(int index) {
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
    AppRefreshService.instance.notifyDataChanged();
  }

  void _goToTraining() {
    setState(() {
      _currentIndex = 1;
    });
    AppRefreshService.instance.notifyDataChanged();
  }

  @override
  void dispose() {
    _notifChannel?.unsubscribe();
    _applicationChannel?.unsubscribe();
    _trainingRecordChannel?.unsubscribe();
    _studentChannel?.unsubscribe();
    _refreshDebounce?.cancel();
    super.dispose();
  }

  int get _selectedNavIndex => _currentIndex > 3 ? _previousIndex : _currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          StudentHome(
            onSeeAll: _goToTraining,
            unreadNotificationCount: _unreadCount,
            onProfileTab: () => _changeTab(2),
            onTrackingTab: () => _changeTab(3),
            onSupportTab: () => _changeTab(4),
          ),
          StudentOpportunities(
            onProfileTab: () => _changeTab(2),
            onTrackingTab: () => _changeTab(3),
            onSupportTab: () => _changeTab(4),
          ),
          StudentProfile(
            shouldRefresh: _currentIndex == 2 && _previousIndex != 2,
            onProfileTab: () => _changeTab(2),
            onTrackingTab: () => _changeTab(3),
            onSupportTab: () => _changeTab(4),
          ),
          StudentTrackingScreen(
            onProfileTab: () => _changeTab(2),
            onTrackingTab: () => _changeTab(3),
            onSupportTab: () => _changeTab(4),
          ),
          StudentSupport(
            embedded: true,
            onProfileTab: () => _changeTab(2),
            onTrackingTab: () => _changeTab(3),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CustomNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isSelected: _selectedNavIndex == 0,
                onTap: () => _changeTab(0),
              ),
              CustomNavItem(
                icon: Icons.work_outline,
                label: 'Training',
                isSelected: _selectedNavIndex == 1,
                onTap: () => _changeTab(1),
              ),
              CustomNavItem(
                icon: Icons.person_outline,
                label: 'Profile',
                isSelected: _selectedNavIndex == 2,
                onTap: () => _changeTab(2),
              ),
              CustomNavItem(
                icon: Icons.track_changes_outlined,
                label: 'Tracking',
                isSelected: _selectedNavIndex == 3,
                onTap: () => _changeTab(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
