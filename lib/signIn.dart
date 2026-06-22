import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'fresh_grads/widgets/fresh_grad_navigation.dart';
import 'fresh_grads/theme/app_theme.dart';
import 'fresh_grads/utils/profile_provider.dart';
import 'student/student_main_navigation.dart';
import 'services/student_identity_service.dart';
import 'services/user_session.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _loginMessage = '';
  bool _isLoading = false;
  bool _registrationHasError = false;
  bool _passwordHasError = false;

  final StudentIdentityService _identityService = StudentIdentityService();

  bool _isErrorMessage(String message) {
    final lower = message.toLowerCase();
    return lower.startsWith('please') ||
        lower.startsWith('invalid') ||
        lower.startsWith('unknown') ||
        lower.startsWith('admin portal not available');
  }

  Future<void> _signIn() async {
    final collegeId = _registrationController.text.trim();
    final password = _passwordController.text;
    final hasCollegeId = collegeId.isNotEmpty;
    final hasPassword = password.isNotEmpty;

    setState(() {
      _registrationHasError = !hasCollegeId;
      _passwordHasError = !hasPassword;
    });

    if (!hasCollegeId || !hasPassword) {
      setState(() {
        _loginMessage = !hasCollegeId
            ? 'Please enter your registration number'
            : 'Please enter your password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _loginMessage = 'Checking registration number...';
    });

    try {
      final sessionData = await _identityService.resolveByCollegeId(
        collegeId,
        password: password,
      );

      // Populate the global UserSession
      UserSession.instance
        ..userId = sessionData.userId
        ..studentId = sessionData.studentId
        ..name = sessionData.name
        ..role = sessionData.role
        ..collegeId = sessionData.collegeId;

      // Save college ID to fresh-grad ProfileProvider too
      if (mounted) {
        context.read<ProfileProvider>().setCollegeId(sessionData.collegeId);
      }

      if (sessionData.role == 'FRESH_GRAD') {
        // Load full profile data from freshgraduate table
        if (mounted) {
          await context.read<ProfileProvider>().loadFromDatabase();
        }
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FreshGradNavigation()),
        );
      } else if (sessionData.role == 'STUDENT') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentMainNavigation()),
        );
      } else if (sessionData.role == 'ADMIN') {
        setState(() {
          _isLoading = false;
          _loginMessage = 'Admin portal not available in this app.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _loginMessage = 'Unknown role. Please contact support.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _loginMessage = 'Invalid registration number or password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration buildDecoration({
      required String hintText,
      required bool hasError,
    }) {
      return InputDecoration(
        filled: true,
        fillColor: AppColors.inputBackground,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? Colors.red : Colors.transparent,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? Colors.red : Colors.transparent,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? Colors.red : AppColors.interactive,
            width: 1.8,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.interactive,
                            AppColors.darkInteractive,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('AAST Connect', style: AppTextStyles.h1),
                    const SizedBox(height: 4),
                    const Text(
                      'Your path to training and opportunities',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              Card(
                color: AppColors.card,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Registration Number',
                        style: AppTextStyles.label,
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: _registrationController,
                        decoration: buildDecoration(
                          hintText: 'Enter your registration number',
                          hasError: _registrationHasError,
                        ),
                        onChanged: (_) {
                          if (_registrationHasError && _registrationController.text.trim().isNotEmpty) {
                            setState(() {
                              _registrationHasError = false;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Password',
                        style: AppTextStyles.label,
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: buildDecoration(
                          hintText: 'Enter your password',
                          hasError: _passwordHasError,
                        ),
                        onChanged: (_) {
                          if (_passwordHasError && _passwordController.text.isNotEmpty) {
                            setState(() {
                              _passwordHasError = false;
                            });
                          }
                        },
                      ),

                      if (_loginMessage.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          _loginMessage,
                          style: TextStyle(
                            color: _isErrorMessage(_loginMessage)
                                ? Colors.red
                                : AppColors.interactive,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.interactive,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _registrationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
