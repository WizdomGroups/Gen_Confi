import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';
import 'package:gen_confi/app/routes/app_routes.dart';

class InstagramColors {
  static const Color pureBlack = Color(0xFF000000);
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

class PremiumSignupScreen extends StatefulWidget {
  const PremiumSignupScreen({super.key});

  @override
  State<PremiumSignupScreen> createState() => _PremiumSignupScreenState();
}

class _PremiumSignupScreenState extends State<PremiumSignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InstagramColors.pureBlack,
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
                color: InstagramColors.gradientOrange.withOpacity(0.12),
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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
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
                                  color: Colors.white,
                                  letterSpacing: 4.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'START YOUR JOURNEY',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: InstagramColors.textMuted,
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
                                  _buildSocialBtn(FontAwesomeIcons.google, 'Google'),
                                  const SizedBox(width: 20),
                                  _buildSocialBtn(FontAwesomeIcons.instagram, 'Instagram'),
                                  const SizedBox(width: 20),
                                  _buildSocialBtn(FontAwesomeIcons.facebook, 'Facebook'),
                                ],
                              ),
                              const SizedBox(height: 32),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.inter(fontSize: 13),
                                    children: [
                                      TextSpan(
                                        text: "Already a member? ",
                                        style: TextStyle(color: InstagramColors.textMuted),
                                      ),
                                      const TextSpan(
                                        text: "Sign In",
                                        style: TextStyle(
                                          color: Colors.white,
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
    return Container(
      decoration: BoxDecoration(
        color: InstagramColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: InstagramColors.borderDark, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: InstagramColors.textMuted, fontSize: 13),
          prefixIcon: Icon(icon, color: InstagramColors.textSecondary, size: 18),
          suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: InstagramColors.textMuted, size: 16),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ) 
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSignupButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: InstagramColors.instagramGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: InstagramColors.gradientPurple.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          'CREATE ACCOUNT',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtn(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        // Handle social signup
        debugPrint('$label signup tapped');
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: InstagramColors.borderDark),
        ),
        child: FaIcon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}