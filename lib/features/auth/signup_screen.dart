import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/providers/auth_provider.dart';
import 'package:gen_confi/core/constants/app_colors.dart';

class PremiumSignupScreen extends ConsumerStatefulWidget {
  const PremiumSignupScreen({super.key});

  @override
  ConsumerState<PremiumSignupScreen> createState() =>
      _PremiumSignupScreenState();
}

class _PremiumSignupScreenState extends ConsumerState<PremiumSignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true, // Allow resize for form input
      body: Stack(
        children: [
          // 1. Premium Background Aura (Top Left for Sign Up to distinguish from Login)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gradientEnd.withOpacity(isDark ? 0.12 : 0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                // Minimal Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: colorScheme.onSurface,
                      size: 18,
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Header Section
                          Column(
                            children: [
                              Text(
                                'GENCONFI',
                                style: GoogleFonts.lexend(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                  letterSpacing: 4.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'START YOUR JOURNEY',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight,
                                  letterSpacing: 2.5,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // Form Section
                          _buildPremiumTextField(
                            controller: _nameController,
                            hint: 'Full Name',
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 16),
                          _buildPremiumTextField(
                            controller: _emailController,
                            hint: 'Email Address',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _buildPremiumTextField(
                            controller: _phoneController,
                            hint: 'Phone Number',
                            icon: Icons.phone_android_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _buildPremiumTextField(
                            controller: _passwordController,
                            hint: 'Create Password',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                          ),

                          const SizedBox(height: 24),

                          // Signup Button
                          _buildSignupButton(),

                          const SizedBox(height: 40),

                          // Footer
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialBtn(
                                    FontAwesomeIcons.google,
                                    'Google',
                                  ),
                                  const SizedBox(width: 20),
                                  _buildSocialBtn(
                                    FontAwesomeIcons.instagram,
                                    'Instagram',
                                  ),
                                  const SizedBox(width: 20),
                                  _buildSocialBtn(
                                    FontAwesomeIcons.facebook,
                                    'Facebook',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.login,
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.inter(fontSize: 13),
                                    children: [
                                      TextSpan(
                                        text: "Already a member? ",
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.textMutedDark
                                              : AppColors.textMutedLight,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "Sign In",
                                        style: TextStyle(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        keyboardType: keyboardType,
        style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            fontSize: 13,
          ),
          prefixIcon: Icon(
            icon,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            size: 18,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                    size: 16,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSignupButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientStart.withOpacity(isDark ? 0.2 : 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          final isLoading = ref.read(authLoadingProvider);
          if (!isLoading) {
            _handleSignup();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.transparent,
        ),
        child: Consumer(
          builder: (context, ref, child) {
            final isLoading = ref.watch(authLoadingProvider);
            return isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'CREATE ACCOUNT',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  );
          },
        ),
      ),
    );
  }

  void _handleSignup() async {
    // Get form values
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    // Validate inputs
    if (name.isEmpty) {
      _showError('Please enter your full name');
      return;
    }

    if (email.isEmpty) {
      _showError('Please enter your email address');
      return;
    }

    if (!_isValidEmail(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    if (phone.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }

    if (password.isEmpty) {
      _showError('Please enter a password');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    // Get auth notifier
    final authNotifier = ref.read(authProvider.notifier);

    // Perform signup via API
    final success = await authNotifier.signup(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    if (!mounted) return;

    if (success) {
      // Get user from provider
      final user = ref.read(currentUserProvider);

      // Navigate directly to home based on user role (skip role selection)
      if (user != null) {
        print('🚀 Signup successful. Navigating to ${user.role} home');
        switch (user.role.toLowerCase()) {
          case 'client':
            Navigator.pushReplacementNamed(context, AppRoutes.clientHome);
            break;
          case 'expert':
            Navigator.pushReplacementNamed(context, AppRoutes.expertHome);
            break;
          case 'admin':
            Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
            break;
          default:
            // Default to client home if role is unknown
            Navigator.pushReplacementNamed(context, AppRoutes.clientHome);
        }
      } else {
        // Fallback to client home if user data not available
        print(
          '⚠️ User data unavailable after signup, defaulting to client home',
        );
        Navigator.pushReplacementNamed(context, AppRoutes.clientHome);
      }
    } else {
      // Show error from provider
      final error = ref.read(authErrorProvider);
      _showError(error ?? 'Signup failed. Please try again.');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildSocialBtn(IconData icon, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        // Handle social signup
        debugPrint('$label signup tapped');
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: FaIcon(icon, color: colorScheme.onSurface, size: 20),
      ),
    );
  }
}
