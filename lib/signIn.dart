import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'fresh_grads/widgets/fresh_grad_navigation.dart';
import 'fresh_grads/theme/app_theme.dart';
import 'fresh_grads/utils/profile_provider.dart';
import 'student/student_main_navigation.dart';
import 'services/user_session.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _registrationController = TextEditingController();
  String _loginMessage = '';
  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  Future<void> _signIn() async {
    final collegeId = _registrationController.text.trim();

    if (collegeId.isEmpty) {
      setState(() {
        _loginMessage = 'Please enter your registration number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _loginMessage = 'Checking registration number...';
    });

    try {
      // Look up the user in the users table
      final response = await supabase
          .from('users')
          .select('userid, name, role, college_id')
          .eq('college_id', collegeId)
          .single();

      final role = response['role'];
      final userId = response['userid'] as int;
      final name = response['name'] ?? '';
      final userCollegeId = response['college_id'] ?? collegeId;

      // Populate the global UserSession
      UserSession.instance
        ..userId = userId
        ..name = name
        ..role = role
        ..collegeId = userCollegeId;

      // Save college ID to fresh-grad ProfileProvider too
      if (mounted) {
        context.read<ProfileProvider>().setCollegeId(userCollegeId);
      }

      if (role == 'FRESH_GRAD') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FreshGradNavigation()),
        );
      } else if (role == 'STUDENT') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentMainNavigation()),
        );
      } else if (role == 'ADMIN') {
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
        _loginMessage = 'College ID not found. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.inputBackground,
                          hintText: 'Enter your registration number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      if (_loginMessage.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          _loginMessage,
                          style: const TextStyle(
                            color: AppColors.interactive,
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
    super.dispose();
  }
}
