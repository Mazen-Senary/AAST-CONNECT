import 'package:aast_connect/providers/CachedChatProvider.dart';
import 'package:aast_connect/widgets/custom_navbar.dart';
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
    return MultiProvider( // Changed to MultiProvider
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) =>CachedChatProvider()), // Add ChatProvider here
      ],
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

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => ThemeProvider(),
//       child: Consumer<ThemeProvider>(
//         builder: (context, themeProvider, child) {
//           return MaterialApp(
//             debugShowCheckedModeBanner: false,
//             theme: themeProvider.lightTheme,
//             darkTheme: themeProvider.darkTheme,
//             themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
//             home: const MainNavigation(),
//           );
//         },
//       ),
//     );
//   }
// }

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  int _previousIndex = 0;
  int _unreadCount = 0;

  RealtimeChannel? _notifChannel;
  final NotificationService _notificationService = NotificationService();
  final int _studentId = 5;

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
        // color: Colors.white,
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