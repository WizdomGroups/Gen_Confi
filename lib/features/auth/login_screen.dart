import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';
import 'package:gen_confi/core/widgets/app_button.dart';
import 'package:gen_confi/core/widgets/app_text_field.dart';
import 'package:gen_confi/services/auth_store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final success = AuthStore().login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (success) {
      _routeAfterLogin();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid email or password"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _routeAfterLogin() {
    final role = AuthStore().role;
    final isOnboarded = AuthStore().isOnboardingCompleteForRole;

    if (role == UserRole.admin) {
      Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      return;
    }

    if (role == UserRole.expert) {
      if (isOnboarded) {
        Navigator.pushReplacementNamed(context, AppRoutes.expertHome);
      } else {
        Navigator.pushReplacementNamed(context, '/expert/onboarding');
      }
      return;
    }

    if (role == UserRole.client) {
      if (isOnboarded) {
        Navigator.pushReplacementNamed(context, AppRoutes.clientHome);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.genderModeSelection);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Teal Background for status bar area
      body: Stack(
        children: [
          // 1. Top Teal Background Area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Container(
              color: AppColors.primary,
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Hello',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40), // Space for card overlap
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Bottom White Card
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        // Card Title
                        const Text(
                          'Login Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Form Fields
                        const Text(
                          "Email Address",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: _emailController,
                          label:
                              'Your Email Address', // Using label as hint style based on design
                          hint: 'example@email.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon:
                              Icons.person_outline, // Matching design icon
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          "Password",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: '••••••••',
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                        ),

                        const SizedBox(height: 16),

                        // Forgot Password Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Placeholder for "Save Password" check if needed later
                            const SizedBox(),
                            GestureDetector(
                              onTap: () {
                                // Reset password
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Login Button (Themed)
                        AppButton(
                          text: _isLoading ? 'Signing In...' : 'Login Account',
                          onPressed: _isLoading ? null : _handleLogin,
                          width: double.infinity,
                          // Explicitly styling to match the Teal Theme requested
                          style: AppButtonStyle.primary,
                        ),

                        const SizedBox(height: 24),

                        // Create Account Link
                        Center(
                          child: GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.signup),
                            child: const Text(
                              'Create New Account',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
