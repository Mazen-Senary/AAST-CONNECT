import 'package:flutter/material.dart';

import 'student/screens/student_home.dart';
import 'student/screens/student_opportunities.dart';
import 'student/screens/student_profile.dart';
import 'student/screens/student_support.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDark = false;

  void toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDark 
        ? ThemeData.dark(useMaterial3: true).copyWith(
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              elevation: 0,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              iconTheme: IconThemeData(color: Color(0xFF284B8C)),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1E1E1E),
              selectedItemColor: Color(0xFF284B8C),
              unselectedItemColor: Colors.grey,
            ),
            cardColor: const Color(0xFF2C2C2C),
          )
        : ThemeData(
            fontFamily: 'Inter',
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xffF9F9F9),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              titleTextStyle: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
              iconTheme: IconThemeData(color: Color(0xFF284B8C)),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFF284B8C),
              unselectedItemColor: Colors.grey,
            ),
            cardColor: Colors.white,
          ),
      home: MainNavigation(toggleTheme: toggleTheme, isDark: _isDark),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;

  const MainNavigation({super.key, required this.toggleTheme, required this.isDark});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _goToTraining() {
    setState(() {
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      StudentHome(
        onSeeAll: _goToTraining,
        toggleTheme: widget.toggleTheme,
        isDark: widget.isDark,
      ),
      StudentOpportunities(
        toggleTheme: widget.toggleTheme,
        isDark: widget.isDark,
      ),
      const StudentProfile(),
      StudentSupport(
        toggleTheme: widget.toggleTheme,
        isDark: widget.isDark,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF284B8C),
        unselectedItemColor: Colors.grey,
        backgroundColor: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
        onTap: (index) {
          setState(() {
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