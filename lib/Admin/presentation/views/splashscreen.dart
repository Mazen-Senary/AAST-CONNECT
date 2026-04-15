import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late AnimationController _progressController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation
    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    // Bounce animation
    _bounceController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _bounceAnimation =
        Tween<double>(begin: 0, end: -10).animate(_bounceController);

    // Progress animation
    _progressController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
          ..repeat();

    _fadeController.forward();

    Timer(const Duration(milliseconds: 2500), () {
      Navigator.pushReplacementNamed(context, '/signin');
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF5B7C99),
              Color(0xFF7A9BB8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Bouncing Icon
                AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _bounceAnimation.value),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.school, // GraduationCap equivalent
                      size: 56,
                      color: Color(0xFF5B7C99),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  "AAST Connect Staff",
                  style: TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Administrative oversight for academic training",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 48),

                // Animated Progress Bar
                SizedBox(
                  width: 64,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _progressController.value,
                          backgroundColor: Colors.white30,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}