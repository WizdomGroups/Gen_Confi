// FILE: lib/features/experts/ui/experts_screen.dart

import 'package:flutter/material.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/core/layout/responsive_container.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpertsScreen extends StatelessWidget {
  const ExpertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In BaseScaffold context from shell, we usually don't need another BaseScaffold if 
    // the Shell handles the scaffold. But here we are page inside IndexedStack.
    // ClientShell provides the Scaffold and BottomNav. We just return body content.
    
    return ResponsiveContainer(
      fullWidthMobile: true,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "Your Expert Team",
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Based on your face scan, we've matched you with these specialists.",
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          _buildExpertCard(
            "Dr. Sarah Miller",
            "Dermatologist",
            "Specializes in Sensitive Skin",
            "4.9",
            "https://randomuser.me/api/portraits/women/44.jpg",
          ),
          _buildExpertCard(
            "James Carter",
            "Hair Stylist",
            "Expert in Textured Crops",
            "4.8",
            "https://randomuser.me/api/portraits/men/32.jpg",
          ),
          _buildExpertCard(
            "Elena Rose",
            "Eyewear Consultant",
            "Face Shape Analysis Pro",
            "5.0",
            "https://randomuser.me/api/portraits/women/68.jpg",
          ),
        ],
      ),
    );
  }

  Widget _buildExpertCard(String name, String role, String specialty, String rating, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl),
            backgroundColor: AppColors.surface,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  specialty,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
            ],
          )
        ],
      ),
    );
  }
}
