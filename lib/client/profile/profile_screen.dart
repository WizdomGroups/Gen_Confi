import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/core/widgets/app_card.dart';
import 'package:gen_confi/services/auth_store.dart';
import 'package:gen_confi/services/onboarding_store.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final draft = OnboardingStore().draft;
    final userName = AuthStore().userEmail?.split('@')[0] ?? "Alex";
    final gender = draft.gender ?? "Client";

    return BaseScaffold(
      title: "Profile",
      showBackButton: true,
      useResponsiveContainer: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // 1) Profile Header
            _buildProfileHeader(context, userName, gender),
            const SizedBox(height: AppSpacing.xxl),

            // 2) My Style & Grooming
            _buildSection(
              title: "My Style & Grooming",
              children: [
                _buildListTile(
                  context,
                  icon: Icons.face_retouching_natural_rounded,
                  title: "Style & Grooming Details",
                  subtitle: "Body type, skin goals, and preferences",
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.clientProfileStyleDetails,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // 3) My Activity
            _buildSection(
              title: "My Activity",
              children: [
                _buildListTile(
                  context,
                  icon: Icons.favorite_border_rounded,
                  title: "Saved Outfits",
                  onTap: () => _showComingSoon(context),
                ),
                _buildListTile(
                  context,
                  icon: Icons.checkroom_rounded,
                  title: "My Wardrobe",
                  onTap: () => _showComingSoon(context),
                ),
                _buildListTile(
                  context,
                  icon: Icons.calendar_month_rounded,
                  title: "Planner",
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // 4) Account
            _buildSection(
              title: "Account",
              children: [
                _buildListTile(
                  context,
                  icon: Icons.email_outlined,
                  title: "Email",
                  trailingText: AuthStore().userEmail ?? "Not set",
                ),
                _buildListTile(
                  context,
                  icon: Icons.lock_outline_rounded,
                  title: "Change Password",
                  onTap: () => _showComingSoon(context),
                ),
                _buildListTile(
                  context,
                  icon: Icons.logout_rounded,
                  title: "Log Out",
                  titleColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () {
                    AuthStore().logout();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String userName,
    String gender,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.clientProfileEdit),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            gender,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white, // Explicit white
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              return Column(
                children: [
                  child,
                  if (index < children.length - 1)
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? titleColor,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? AppColors.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              )
            else if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFFCBD5E1),
              ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Coming soon!")));
  }
}
