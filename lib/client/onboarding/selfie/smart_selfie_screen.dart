import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gen_confi/features/smart_capture/smart_capture_screen.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/constants/app_colors.dart';
import 'package:gen_confi/core/constants/app_spacing.dart';
import 'package:gen_confi/core/layout/base_scaffold.dart';
import 'package:gen_confi/core/widgets/app_button.dart';
import 'package:gen_confi/core/widgets/app_card.dart';
import 'package:gen_confi/core/providers/auth_provider.dart';

class SmartSelfieScreen extends ConsumerWidget {
  const SmartSelfieScreen({super.key});

  Future<void> _handleUpload(BuildContext context, WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      // Show loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Uploading photo...")));

      final success = await ref
          .read(authProvider.notifier)
          .uploadAvatar(image.path);

      if (success && context.mounted) {
        Navigator.pushNamed(context, AppRoutes.onboardingUserType);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to upload photo. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseScaffold(
      showBackButton: true,
      useResponsiveContainer: true,
      title: "Selfie Check",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Let’s start with a selfie.",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "This helps us understand your face, hair & skin to give you better advice.",
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Live Guide Simulation Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.face_retouching_natural,
                          size: 80,
                          color: Colors.grey,
                        ),
                        Positioned(
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Look straight and relax 🙂",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        // Face Frame
                        Positioned.fill(
                          child: Container(
                            margin: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.5),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildChecklist(),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Privacy Note
            Row(
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Your photo is safe and used only to give you personalized recommendations.",
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            AppButton(
              text: "Take Selfie",
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SmartCaptureScreen()),
                );

                if (result != null && result is String) {
                  debugPrint("Captured Selfie Path: $result");
                  // Proceed with the captured image
                  if (context.mounted) {
                    Navigator.pushNamed(context, AppRoutes.onboardingUserType);
                  }
                }
              },
              style: AppButtonStyle.primary,
              icon: Icons.camera_alt_rounded,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => _handleUpload(context, ref),
              child: const Text("Upload Photo Instead"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklist() {
    return Column(
      children: [
        _buildCheckItem("Remove glasses, mask, or cap"),
        const SizedBox(height: 8),
        _buildCheckItem("Make sure your face is clearly visible"),
        const SizedBox(height: 8),
        _buildCheckItem("Good lighting detected ✔", isChecked: true),
      ],
    );
  }

  Widget _buildCheckItem(String text, {bool isChecked = false}) {
    return Row(
      children: [
        Icon(
          isChecked ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 18,
          color: isChecked ? Colors.green : AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isChecked ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
