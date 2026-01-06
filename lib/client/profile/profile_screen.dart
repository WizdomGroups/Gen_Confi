import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/core/providers/auth_provider.dart';
import 'package:gen_confi/core/utils/theme_extensions.dart';
import 'package:gen_confi/core/widgets/app_card.dart';
import 'package:gen_confi/core/constants/api_constants.dart';
import 'package:gen_confi/services/theme_store.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    final userName = user?.name ?? user?.email.split('@')[0] ?? "User";
    final userEmail = user?.email ?? "Not set";

    return BaseScaffold(
      title: "Profile",
      showBackButton: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.maxContentWidth,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                _buildProfileHeader(context, user, userName),
                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSection(
                    title: "Account",
                    children: [
                      _buildListTile(
                        context,
                        icon: Icons.email_outlined,
                        title: "Email",
                        subtitle: userEmail,
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.lock_outline_rounded,
                        title: "Change Password",
                        onTap: () => _showComingSoon(context),
                      ),
                      _buildThemeToggle(context),
                      _buildListTile(
                        context,
                        icon: Icons.logout_rounded,
                        title: "Log Out",
                        titleColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.login,
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user, String userName) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: context.themeSurfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: context.themeBorder, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(child: _buildAvatarImage(context, user)),
            ),

            // Edit Profile Info
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.clientProfileEdit),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.themeBackground,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          userName,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.themeTextPrimary,
          ),
        ),
        if (user?.gender != null)
          Text(
            user!.gender!,
            style: TextStyle(fontSize: 14, color: context.themeTextSecondary),
          ),
      ],
    );
  }

  Widget _buildAvatarImage(BuildContext context, user) {
    if (user?.avatarUrl != null) {
      final url = user!.avatarUrl!;
      if (url.startsWith('assets/')) {
        return Image.asset(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
        );
      } else if (url.startsWith('http')) {
        return Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
        );
      } else {
        // Handle relative paths from our backend
        final cleanUrl = url.startsWith('/') ? url : '/$url';
        return Image.network(
          '${ApiConstants.baseUrl}$cleanUrl',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
        );
      }
    }
    return _buildPlaceholderIcon();
  }

  Widget _buildPlaceholderIcon() {
    return Icon(
      Icons.person_rounded,
      size: 55,
      color: AppColors.primary.withOpacity(0.5),
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
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.themeTextPrimary,
            ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          backgroundColor: context.themeSurface,
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              return Column(
                children: [
                  child,
                  if (index < children.length - 1)
                    Divider(
                      height: 1,
                      color: context.themeBorder.withOpacity(0.5),
                    ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor ?? AppColors.primary,
              ),
            ),
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
                      color: titleColor ?? context.themeTextPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.themeTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 14,
                  color: context.themeTextSecondary,
                ),
              )
            else if (onTap != null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: context.themeTextSecondary.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final themeStore = ThemeStore();
    return ValueListenableBuilder<bool>(
      valueListenable: themeStore.themeNotifier,
      builder: (context, isDarkMode, child) {
        return InkWell(
          onTap: () => themeStore.toggleTheme(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Theme",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: context.themeTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDarkMode ? "Dark Mode" : "Light Mode",
                        style: TextStyle(
                          fontSize: 13,
                          color: context.themeTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: (value) => themeStore.setTheme(value),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showComingSoon(BuildContext context, {String msg = "Coming soon!"}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
