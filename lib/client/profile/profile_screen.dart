import 'dart:io'; // Added for File usage
import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/core/widgets/app_card.dart';
import 'package:gen_confi/services/auth_store.dart';
import 'package:gen_confi/services/onboarding_store.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // We rely on AuthStore for the source of truth, but setState triggers rebuild

  @override
  Widget build(BuildContext context) {
    final draft = OnboardingStore().draft;
    final userName = AuthStore().userEmail?.split('@')[0] ?? "Alex";
    final gender = draft.gender ?? "Client";

    return BaseScaffold(
      title: "Profile",
      showBackButton: true,
      useResponsiveContainer: false,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSpacing.maxContentWidth,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
            child: Column(
              children: [
                _buildProfileHeader(context, userName, gender),
                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSection(
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
                      _buildListTile(
                        context,
                        icon: Icons.bookmark_border_rounded,
                        title: "Saved Grooming Styles",
                        onTap: () => _showComingSoon(context),
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.camera_front_rounded,
                        title: "My Looks",
                        subtitle: "History of your face scans",
                        onTap: () => _showComingSoon(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSection(
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
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String userName,
    String gender,
  ) {
    // Current Avatar Logic
    // 1. AuthStore.avatarUrl
    // 2. AuthStore.groomingImagePath (Real selfie) -> Maybe use this if no avatar? User requested "cartoon".
    // Let's prioritize Avatar > Real Selfie > Default Icon

    final avatarUrl = AuthStore().avatarUrl;
    final realImage = AuthStore().groomingImagePath;

    ImageProvider? imageProvider;
    if (avatarUrl != null) {
      if (avatarUrl.startsWith('http')) {
        imageProvider = NetworkImage(avatarUrl);
      } else {
        imageProvider = AssetImage(avatarUrl); // For local assets if any
      }
    } else if (realImage != null) {
      imageProvider = FileImage(File(realImage));
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                image: imageProvider != null
                    ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                    : null,
              ),
              child: imageProvider == null
                  ? const Icon(
                      Icons.person_rounded,
                      size: 55,
                      color: AppColors.primary,
                    )
                  : null,
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
            ),

            // Cartoon Avatar Selection
            Positioned(
              left: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => _showAvatarSelectionSheet(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.emoji_emotions_rounded,
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
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        // Removed "Client" label container as per user request
      ],
    );
  }

  void _showAvatarSelectionSheet(BuildContext context) {
    // Get gender from state or store
    final draft = OnboardingStore().draft;
    final gender = draft.gender ?? "Male"; // Default to Male if unknown

    // Define seed lists based on gender
    List<String> seeds;

    // We will apply specific style constraints via URL params to ensure gender aesthetics
    // Using 'avataaars' style from DiceBear

    if (gender == "Female") {
      seeds = [
        'Bella',
        'Sophia',
        'Luna',
        'Zoe',
        'Ava',
        'Mia',
        'Lily',
        'Chloe',
        'Ruby',
        'Emma',
        'Grace',
        'Ivy',
      ];
    } else if (gender == "Male") {
      seeds = [
        'Leo',
        'Max',
        'Liam',
        'Kai',
        'Noah',
        'Ethan',
        'Lucas',
        'Mason',
        'Logan',
        'James',
        'Felix',
        'Aiden',
      ];
    } else {
      // Mixed/Other
      seeds = [
        'Alex',
        'Sky',
        'Jordan',
        'Taylor',
        'Casey',
        'Jamie',
        'Riley',
        'Avery',
        'Morgan',
        'Quinn',
        'Rowan',
        'Sage',
      ];
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // For custom rounded aesthetic
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          height: MediaQuery.of(context).size.height * 0.6, // Taller sheet
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Choose Avatar",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Based on your profile ($gender)",
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  // Maybe a filter button later?
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: seeds.length + 1, // +1 for Upload
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Upload Option
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _showComingSoon(context, msg: "Opening Gallery...");
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                    width: 1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.add_a_photo_rounded,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Upload",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final seed = seeds[index - 1];
                    // Construct URL with constraints
                    // Using 9.x API
                    String url =
                        "https://api.dicebear.com/9.x/avataaars/png?seed=$seed&backgroundColor=b6e3f4";

                    if (gender == "Female") {
                      // Female: Long hair styles, no facial hair
                      url +=
                          "&top=longHair,curvy,shaggyMullet,straight01,straight02,straightStrand&facialHairProbability=0";
                    } else if (gender == "Male") {
                      // Male: Short hair styles, some facial hair allowed
                      url +=
                          "&top=shortFlat,shortRound,shortWaved,caesar,caesarSidePart,dreads,frizzle&facialHairProbability=50";
                    }
                    // 'Other' uses default randomness

                    return GestureDetector(
                      onTap: () {
                        // Update Store
                        AuthStore().setAvatarUrl(url);
                        // Force refresh
                        setState(() {});
                        Navigator.pop(ctx);
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          color: Colors.grey[100],
                                          child: const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.error_outline,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            seed, // Using seed name as a label for now
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ... _buildSection and _buildListTile are same ...
  // Re-pasting helper methods for completeness within the StatefulWidget

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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white,
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

  void _showComingSoon(BuildContext context, {String msg = "Coming soon!"}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
