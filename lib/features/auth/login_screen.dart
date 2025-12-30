import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';
import 'package:gen_confi/app/routes/app_routes.dart';

class InstagramColors {
  static const Color pureBlack = Color(0xFF000000);
  static const Color deepDark = Color(0xFF050505);
  static const Color cardDark = Color(0xFF161616);
  static const Color borderDark = Color(0xFF262626);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  
  static const Color gradientPurple = Color(0xFF833AB4);
  static const Color gradientRed = Color(0xFFFD1D1D);
  static const Color gradientOrange = Color(0xFFF77737);
  
  static const LinearGradient instagramGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientPurple, gradientRed, gradientOrange],
  );
}

class PremiumLoginScreen extends StatefulWidget {
  const PremiumLoginScreen({super.key});

  @override
  State<PremiumLoginScreen> createState() => _PremiumLoginScreenState();
}

class _PremiumLoginScreenState extends State<PremiumLoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    // Screen height to calculate dynamic spacing
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: InstagramColors.pureBlack,
      resizeToAvoidBottomInset: false, // Prevents resizing (and thus scrolling) when keyboard appears
      body: Stack(
        children: [
          // 1. Premium Background Aura
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: InstagramColors.gradientPurple.withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Logo Section
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: InstagramColors.instagramGradient,
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: InstagramColors.pureBlack,
                          child: const Icon(
                            Icons.auto_awesome_rounded, // More "premium" icon
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'GENCONFI',
                        style: GoogleFonts.lexend( // Switched to Lexend for a cleaner premium look
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 4.0,
                        ),
                      ),
                      Text(
                        'THE ART OF GROOMING',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: InstagramColors.textMuted,
                          letterSpacing: 3.0,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Input Section
                  Column(
                    children: [
                      _buildPremiumTextField(
                        controller: _emailController,
                        hint: 'Username or Email',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildPremiumTextField(
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.inter(
                              color: InstagramColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Login Button
                  _buildLoginButton(context),

                  const Spacer(flex: 3),

                  // Footer Section
                  Column(
                    children: [
                      Text(
                        'OR CONTINUE WITH',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: InstagramColors.textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialBtn(FontAwesomeIcons.google, 'Google'),
                          const SizedBox(width: 20),
                          _buildSocialBtn(FontAwesomeIcons.instagram, 'Instagram'),
                          const SizedBox(width: 20),
                          _buildSocialBtn(FontAwesomeIcons.facebook, 'Facebook'),
                        ],
                      ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.signup);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "New here? ",
                              style: GoogleFonts.inter(color: InstagramColors.textMuted),
                            ),
                            Text(
                              "Create Account",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: InstagramColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: InstagramColors.borderDark, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: InstagramColors.textMuted, fontSize: 14),
          prefixIcon: Icon(icon, color: InstagramColors.textSecondary, size: 20),
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: InstagramColors.textMuted, size: 18),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ) 
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: InstagramColors.instagramGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: () {
          final email = _emailController.text.trim();
          final password = _passwordController.text.trim();
          
          // Check for hardcoded credentials
          if (email.toLowerCase() == 'user@example.com' && password == 'User') {
            // Navigate to home screen
            Navigator.pushReplacementNamed(context, AppRoutes.clientShell);
          } else {
            // Show error for invalid credentials
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Invalid email or password',
                  style: GoogleFonts.inter(),
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          'SIGN IN',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtn(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        // Handle social login
        debugPrint('$label login tapped');
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: InstagramColors.borderDark),
        ),
        child: FaIcon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}