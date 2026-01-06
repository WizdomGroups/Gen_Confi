import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/providers/auth_provider.dart';

enum ResetState { email, otp, newPassword }

class PremiumForgotPasswordScreen extends ConsumerStatefulWidget {
  const PremiumForgotPasswordScreen({super.key});

  @override
  ConsumerState<PremiumForgotPasswordScreen> createState() =>
      _PremiumForgotPasswordScreenState();
}

class _PremiumForgotPasswordScreenState
    extends ConsumerState<PremiumForgotPasswordScreen> {
  ResetState _currentState = ResetState.email;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleAction() async {
    final notifier = ref.read(authProvider.notifier);

    // Clear previous errors
    // ref.refresh(authErrorProvider); // Optional, might not be needed if state clears

    if (_currentState == ResetState.email) {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        _showError('Please enter your email');
        return;
      }

      final success = await notifier.forgotPassword(email);
      if (success) {
        setState(() => _currentState = ResetState.otp);
        _showSuccess('Reset code sent! Check your terminal/logs.');
      }
    } else if (_currentState == ResetState.otp) {
      final token = _otpController.text.trim();
      if (token.isEmpty) {
        _showError('Please enter the verification code');
        return;
      }
      // Since we don't have a verify-token-only endpoint, we assume it's valid
      // and move to password creation. The final check happens there.
      setState(() => _currentState = ResetState.newPassword);
    } else if (_currentState == ResetState.newPassword) {
      final newPass = _passwordController.text.trim();
      final confirmPass = _confirmPasswordController.text.trim();
      final token = _otpController.text.trim();

      if (newPass.isEmpty || confirmPass.isEmpty) {
        _showError('Please fill all fields');
        return;
      }

      if (newPass != confirmPass) {
        _showError('Passwords do not match');
        return;
      }

      final success = await notifier.resetPassword(
        token: token,
        newPassword: newPass,
      );
      if (success) {
        _showSuccess('Password reset successfully!');
        if (mounted) Navigator.pop(context);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    // Listen for errors from provider
    ref.listen(authErrorProvider, (previous, next) {
      if (next != null) {
        _showError(next);
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Premium Background Aura (Top Right)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gradientStart.withOpacity(isDark ? 0.15 : 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Minimal Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      if (_currentState == ResetState.email)
                        Navigator.pop(context);
                      else
                        setState(
                          () => _currentState =
                              ResetState.values[_currentState.index - 1],
                        );
                    },
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
                              _buildStateIcon(),
                              const SizedBox(height: 24),
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
                                _getHeaderSubtitle(),
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

                          // Dynamic Form Content
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildFormContent(),
                          ),

                          const SizedBox(height: 32),

                          // Action Button
                          _buildActionButton(),

                          const SizedBox(height: 40),
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

  Widget _buildStateIcon() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    IconData icon;
    switch (_currentState) {
      case ResetState.email:
        icon = Icons.lock_reset_rounded;
        break;
      case ResetState.otp:
        icon = Icons.mark_email_read_outlined;
        break;
      case ResetState.newPassword:
        icon = Icons.security_rounded;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
      ),
      child: CircleAvatar(
        radius: 38,
        backgroundColor: colorScheme.surface,
        child: Icon(icon, size: 32, color: colorScheme.onSurface),
      ),
    );
  }

  String _getHeaderSubtitle() {
    switch (_currentState) {
      case ResetState.email:
        return 'FORGOT PASSWORD';
      case ResetState.otp:
        return 'VERIFY CODE';
      case ResetState.newPassword:
        return 'NEW CREDENTIALS';
    }
  }

  Widget _buildFormContent() {
    switch (_currentState) {
      case ResetState.email:
        return _buildInputGroup('Reset Link', 'Enter email to receive OTP', [
          _buildTextField(
            _emailController,
            'Email Address',
            Icons.email_outlined,
          ),
        ]);
      case ResetState.otp:
        return _buildInputGroup(
          'Verification Code',
          'Enter the code/token provided',
          // Changed isCenter to false to accommodate long tokens
          [
            _buildTextField(
              _otpController,
              'Enter Token',
              Icons.vpn_key_rounded,
              isCenter: false,
            ),
          ],
        );
      case ResetState.newPassword:
        return _buildInputGroup(
          'Reset Password',
          'Set your new secure password',
          [
            _buildTextField(
              _passwordController,
              'New Password',
              Icons.lock_outline,
              isPass: true,
              isNewPassword: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _confirmPasswordController,
              'Confirm Password',
              Icons.lock_outline,
              isPass: true,
              isNewPassword: false,
            ),
          ],
        );
    }
  }

  Widget _buildInputGroup(String title, String desc, List<Widget> fields) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Column(
      key: ValueKey(title),
      children: [
        Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          desc,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 32),
        ...fields,
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPass = false,
    bool isCenter = false,
    bool isNewPassword = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final bool obscureText =
        isPass && (isNewPassword ? _obscurePassword : _obscureConfirmPassword);

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
        obscureText: obscureText,
        textAlign: isCenter ? TextAlign.center : TextAlign.start,
        // Changed to text input type to allow alphanumeric tokens
        keyboardType: isCenter ? TextInputType.number : TextInputType.text,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: isCenter ? 24 : 15,
          fontWeight: isCenter ? FontWeight.bold : FontWeight.normal,
          letterSpacing: isCenter ? 8 : 0,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            fontSize: 14,
            letterSpacing: isCenter ? 4 : 0,
          ),
          prefixIcon: isCenter
              ? null
              : Icon(
                  icon,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  size: 20,
                ),
          suffixIcon: isPass
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isNewPassword) {
                        _obscurePassword = !_obscurePassword;
                      } else {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      }
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String label = _currentState == ResetState.email
        ? 'SEND CODE'
        : (_currentState == ResetState.otp ? 'VERIFY' : 'UPDATE PASSWORD');

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
          if (!isLoading) _handleAction();
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
            if (isLoading) {
              return const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              );
            }
            return Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: Colors.white,
                fontSize: 14,
              ),
            );
          },
        ),
      ),
    );
  }
}
