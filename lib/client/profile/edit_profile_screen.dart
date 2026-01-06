import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/core/widgets/app_button.dart';
import 'package:gen_confi/core/providers/auth_provider.dart';
import 'package:gen_confi/core/utils/theme_extensions.dart';
import 'package:gen_confi/core/constants/api_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String _selectedGender;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.name ?? "");
    _emailController = TextEditingController(text: user?.email ?? "");
    _selectedGender = user?.gender ?? "Male";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final success = await ref.read(authProvider.notifier).updateProfile({
      'name': _nameController.text,
      'gender': _selectedGender,
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image != null && mounted) {
      final croppedFile = await _cropImage(image.path);
      if (croppedFile != null && mounted) {
        final success = await ref
            .read(authProvider.notifier)
            .uploadAvatar(croppedFile.path);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile photo updated!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<CroppedFile?> _cropImage(String path) async {
    return await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Square crop
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Adjust Photo',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          activeControlsWidgetColor: AppColors.primary,
        ),
        IOSUiSettings(
          title: 'Adjust Photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.themeSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Update Profile Photo",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.themeTextPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionItem(
              icon: Icons.camera_alt_rounded,
              label: "Take Photo",
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            _buildOptionItem(
              icon: Icons.photo_library_rounded,
              label: "Choose from Gallery",
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            _buildOptionItem(
              icon: Icons.face_rounded,
              label: "Select Avatar",
              onTap: () {
                Navigator.pop(context);
                _showAvatarPicker();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker() {
    final isDark = context.isDarkMode;

    final List<String> paths;
    if (_selectedGender == "Female") {
      paths = List.generate(6, (i) => "assets/female/female$i.png");
    } else {
      paths = List.generate(6, (i) => "assets/male/male$i.png");
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: context.themeSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // Drag Handle
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: context.themeBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Avatar",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: context.themeTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Based on your profile ($_selectedGender)",
                      style: TextStyle(
                        fontSize: 14,
                        color: context.themeTextSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    (_selectedGender == "Female") ? Icons.female : Icons.male,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.85,
                ),
                itemCount: paths.length,
                itemBuilder: (context, index) {
                  final path = paths[index];

                  return GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await ref.read(authProvider.notifier).updateProfile({
                        'avatar_url': path,
                      });
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.themeBorder,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    isDark ? 0.2 : 0.05,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                path,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.error_outline,
                                  color: context.themeTextMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Avatar ${index + 1}",
                          style: TextStyle(
                            fontSize: 12,
                            color: context.themeTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: TextStyle(
          color: context.themeTextPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isDark = context.isDarkMode;
    final isLoading = ref.watch(authLoadingProvider);

    return BaseScaffold(
      title: "Edit Profile",
      showBackButton: true,
      useResponsiveContainer: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _showPhotoOptions,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: context.themeSurfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.themeBorder,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.3 : 0.05,
                            ),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(child: _buildAvatarImage(context, user)),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: _showPhotoOptions,
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
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Form Fields
            _buildTextField(
              context,
              label: "Full Name",
              controller: _nameController,
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildTextField(
              context,
              label: "Email Address",
              controller: _emailController,
              enabled: false, // Email is primary ID, usually read-only
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Gender Selection
            _buildGenderDropdown(context),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: AppButton(
                text: "Save Changes",
                onPressed: isLoading ? null : _handleSave,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildGenderDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gender",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.themeTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.themeSurface,
            border: Border.all(color: context.themeBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              isExpanded: true,
              dropdownColor: context.themeSurface,
              style: TextStyle(color: context.themeTextPrimary, fontSize: 15),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: context.themeTextSecondary,
              ),
              items: [
                "Male",
                "Female",
                "Other",
              ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedGender = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.themeTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(
            color: enabled ? context.themeTextPrimary : context.themeTextMuted,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? context.themeSurface
                : context.themeSurfaceElevated,
            prefixIcon: Icon(
              icon,
              color: AppColors.primary.withOpacity(0.7),
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.themeBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.themeBorder),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.themeBorder.withOpacity(0.5),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
