import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';
import 'package:gen_confi/core/widgets/app_button.dart';
import 'package:gen_confi/core/widgets/app_text_field.dart';
import 'package:gen_confi/core/widgets/selectable_card.dart';
import 'package:gen_confi/services/auth_store.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.client;
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    AuthStore().signup(email, password, _selectedRole);

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (_selectedRole == UserRole.client) {
      Navigator.pushNamed(context, AppRoutes.genderModeSelection);
    } else {
      Navigator.pushNamed(context, AppRoutes.expertOnboarding);
    }
  }

  void _handleSocialSignup(String provider) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$provider signup in progress..."),
        backgroundColor: AppColors.primary,
      ),
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          // 1. Top Teal Background Area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height:
                MediaQuery.of(context).size.height *
                0.35, // Slightly shorter for Signup
            child: Container(
              color: AppColors.primary,
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Join Us',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create Free Account',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Bottom White Card
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        // Compact Social Login Row (Requested here)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SmallSocialButton(
                              icon: Icons.g_mobiledata,
                              onTap: () => _handleSocialSignup('Google'),
                              color: AppColors.textPrimary,
                            ),
                            const SizedBox(width: 24),
                            _SmallSocialButton(
                              icon: Icons.camera_alt_outlined,
                              onTap: () => _handleSocialSignup('Instagram'),
                              color: const Color(0xFFE4405F),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Section Title
                        const Text(
                          'Personal Info',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your details below to create your account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Fields
                        _CompactLabelField(label: 'Full Name'),
                        AppTextField(
                          controller: _nameController,
                          hint: 'First Name   Last Name',
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),

                        _CompactLabelField(label: 'Email Address'),
                        AppTextField(
                          controller: _emailController,
                          hint: 'your.email@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),

                        _CompactLabelField(label: 'Phone Number'),
                        AppTextField(
                          controller: _phoneController,
                          hint: '123-456-7890',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                        ),
                        const SizedBox(height: 16),

                        _CompactLabelField(label: 'Password'),
                        AppTextField(
                          controller: _passwordController,
                          hint: '••••••••',
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                        ),

                        const SizedBox(height: 24),

                        // Role Selector (Compact)
                        const Text(
                          "I want to...",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: SelectableCard(
                                title: "Client",
                                subtitle: null, // Compact
                                isSelected: _selectedRole == UserRole.client,
                                onTap: () => setState(
                                  () => _selectedRole = UserRole.client,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SelectableCard(
                                title: "Expert",
                                subtitle: null,
                                isSelected: _selectedRole == UserRole.expert,
                                onTap: () => setState(
                                  () => _selectedRole = UserRole.expert,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Signup Button
                        AppButton(
                          text: _isLoading ? 'Saving...' : 'Save & Continue',
                          onPressed: _isLoading ? null : _handleSignup,
                          width: double.infinity,
                          style: AppButtonStyle.primary, // Teal
                        ),

                        const SizedBox(height: 20),

                        // Back to Login
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Back to Login',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
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

class _SmallSocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _SmallSocialButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}

class _CompactLabelField extends StatelessWidget {
  final String label;
  const _CompactLabelField({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
