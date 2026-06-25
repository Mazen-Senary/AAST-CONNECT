import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'providers/CachedChatProvider.dart';
import 'fresh_grads/widgets/fresh_grad_navigation.dart';
import 'fresh_grads/theme/app_theme.dart';
import 'fresh_grads/utils/opportunities_provider.dart';
import 'fresh_grads/utils/profile_provider.dart';
import 'services/fresh_grad_home_service.dart';
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
  final FocusNode _registrationFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  String _loginMessage = '';
  bool _isLoading = false;
  bool _registrationHasError = false;
  bool _passwordHasError = false;

  final StudentIdentityService _identityService = StudentIdentityService();

  @override
  void initState() {
    super.initState();
    _registrationFocusNode.addListener(_validateRegistrationOnBlur);
    _passwordFocusNode.addListener(_validatePasswordOnBlur);
  }

  void _validateRegistrationOnBlur() {
    if (!_registrationFocusNode.hasFocus) {
      setState(() {
        _registrationHasError = _registrationController.text.trim().isEmpty;
      });
    }
  }

  void _validatePasswordOnBlur() {
    if (!_passwordFocusNode.hasFocus) {
      setState(() {
        _passwordHasError = _passwordController.text.isEmpty;
      });
    }
  }

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
      if (mounted) {
        context.read<ProfileProvider>().reset();
        context.read<OpportunitiesProvider>().reset();
        context.read<CachedChatProvider>().clearActiveSession();
      }

      FreshGradHomeService.invalidateCache();
      UserSession.instance.clear();

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
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: TextStyle(
          color: const Color(0xFF8A8A8A),
          fontSize: 14.sp,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: hasError ? Colors.red : Colors.transparent,
            width: 1.5.w,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: hasError ? Colors.red : Colors.transparent,
            width: 1.5.w,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: hasError ? Colors.red : AppColors.interactive,
            width: 1.8.w,
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.all(24.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.vertical),
            child: Column(
              children: [
                SizedBox(height: 28.h),

                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.interactive,
                              AppColors.darkInteractive,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.school,
                          size: 40.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'AAST Connect',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2D2D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Your path to training and opportunities',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          color: const Color(0xFF4A4A4A),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 36.h),

                Card(
                  color: AppColors.card,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D2D2D),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        const Text(
                          'Registration Number',
                          style: AppTextStyles.label,
                        ),
                        SizedBox(height: 8.h),

                        TextField(
                          controller: _registrationController,
                          focusNode: _registrationFocusNode,
                          style: const TextStyle(
                            color: Color(0xFF1F1F1F),
                            fontSize: 14,
                          ),
                          cursorColor: AppColors.interactive,
                          decoration: buildDecoration(
                            hintText: 'Enter your registration number',
                            hasError: _registrationHasError,
                          ),
                          onChanged: (_) {
                            if (_registrationHasError &&
                                _registrationController.text.trim().isNotEmpty) {
                              setState(() {
                                _registrationHasError = false;
                              });
                            }
                          },
                        ),

                        SizedBox(height: 16.h),

                        const Text(
                          'Password',
                          style: AppTextStyles.label,
                        ),
                        SizedBox(height: 8.h),

                        TextField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: true,
                          style: const TextStyle(
                            color: Color(0xFF1F1F1F),
                            fontSize: 14,
                          ),
                          cursorColor: AppColors.interactive,
                          decoration: buildDecoration(
                            hintText: 'Enter your password',
                            hasError: _passwordHasError,
                          ),
                          onChanged: (_) {
                            if (_passwordHasError &&
                                _passwordController.text.isNotEmpty) {
                              setState(() {
                                _passwordHasError = false;
                              });
                            }
                          },
                        ),

                        if (_loginMessage.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          Text(
                            _loginMessage,
                            style: TextStyle(
                              color: _isErrorMessage(_loginMessage)
                                  ? Colors.red
                                  : AppColors.interactive,
                              fontWeight: FontWeight.w500,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                        SizedBox(height: 20.h),
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.interactive,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15.sp,
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
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _registrationFocusNode.dispose();
    _passwordFocusNode.dispose();
    _registrationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
