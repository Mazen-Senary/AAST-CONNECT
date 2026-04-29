import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Admin/presentation/views/admin_navigation.dart';
import 'Admin/presentation/views/theme_provider.dart';
// import 'Student/ui/student_navigation.dart';
// import 'Graduate/ui/graduate_navigation.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _registrationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _loginMessage = '';

  final supabase = Supabase.instance.client;

  Future<void> _signIn() async {
    final collegeId = _registrationController.text.trim();
    final password = _passwordController.text.trim();

    if (collegeId.isEmpty || password.isEmpty) {
      setState(() {
        _loginMessage = 'Invalid Admin ID or password';
      });
      return;
    }
    setState(() {
      _loginMessage = 'Checking admin ID...';
    });

    try {
      final response = await supabase.rpc(
        'signin_admin',
        params: {'input_college_id': collegeId, 'input_password': password},
      );

      if (response == null || response.isEmpty) {
        setState(() {
          _loginMessage = 'Invalid Admin ID or password';
        });
        return;
      }

      final adminId = response[0]['adminid'];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ThemeProvider(),
            child: AdminNavigation(adminId: adminId),
          ),
        ),
      );
    } catch (e) {
      debugPrint('SIGN IN ERROR: $e');

      setState(() {
        _loginMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              /// Logo + Title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B7C99), Color(0xFF7A9BB8)],
                        ),
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'AAST Connect Staff',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Administrative oversight for academic training',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        color: Color(0xFF6B6B6B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              /// Login Card
              Card(
                color: const Color(0xFFFFFFFF),
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
                      const SizedBox(height: 8),

                      TextField(
                        controller: _registrationController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFFAF9F6),
                          hintText: 'Registration number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFFAF9F6),
                          hintText: 'Password',
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
                            color: Color(0xFF5B7C99),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B7C99),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
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
