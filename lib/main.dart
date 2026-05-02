import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import 'student/screens/student_home.dart';
import 'student/screens/student_opportunities.dart';
import 'student/screens/student_profile.dart';
import 'student/screens/student_support.dart';
import 'student/screens/student_notifications.dart';
import 'supabase_config.dart';
import 'services/theme_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
    debug: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
            home: const MainNavigation(),
          );
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  int _previousIndex = 0; // track previous tab
  int _unreadCount = 0;
  late final RealtimeChannel _notifChannel;
  final NotificationService _notificationService = NotificationService();
  final int _studentId = 5; // Replace with actual userId when auth is implemented

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    _listenForNotifications();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount(_studentId);
      setState(() => _unreadCount = count);
    } catch (e) {
      print('Error loading unread count: $e');
    }
  }

  void _listenForNotifications() {
    _notifChannel =
        _notificationService.listenToNotifications(_studentId, (payload) {
      setState(() => _unreadCount++);

      // Show snackbar with notification
      if (mounted) {
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
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentNotificationsScreen(),
                ),
              ),
            ),
          ),
        );
      }
    });
  }

  void _goToTraining() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  void dispose() {
    _notifChannel.unsubscribe();
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
          // pass shouldRefresh=true when switching TO profile tab
          StudentProfile(shouldRefresh: _currentIndex == 2 && _previousIndex != 2),
          const StudentSupport(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onTap: (index) {
          setState(() {
            _previousIndex = _currentIndex;
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: "Training",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            activeIcon: Icon(Icons.help),
            label: "Support",
          ),
        ],
      ),
    );
  }
}