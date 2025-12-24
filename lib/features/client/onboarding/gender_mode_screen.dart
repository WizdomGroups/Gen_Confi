import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/core/utils/navigation.dart';
import 'package:gen_confi/services/onboarding_store.dart';
import 'package:gen_confi/core/widgets/app_button.dart';

class GenderModeScreen extends StatefulWidget {
  const GenderModeScreen({super.key});

  @override
  State<GenderModeScreen> createState() => _GenderModeScreenState();
}

class _GenderModeScreenState extends State<GenderModeScreen> {
  String? _selectedGender;
  String? _selectedMode;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<Map<String, String>> _modes = [
    {
      'title': 'AI Styling Only',
      'description': 'Automated recommendations based on your profile.',
    },
    {
      'title': 'AI + Expert Consultation',
      'description': 'Get personal advice from professional stylists.',
    },
  ];

  bool get _canContinue => _selectedGender != null && _selectedMode != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D9488), // Teal-600
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Section (Teal Background)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom AppBar-like row
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                      const Text(
                        'Step 1 of 4',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 20), // Balance the back button
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Let’s get to know you',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your identity helps us tailor the perfect style recommendations.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Bottom Section (White Card)
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'I identify as...',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: _genders.map((gender) {
                                  final isSelected = _selectedGender == gender;
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: gender == _genders.last ? 0 : 12,
                                      ),
                                      child: _SelectionChip(
                                        label: gender,
                                        isSelected: isSelected,
                                        onTap: () => setState(
                                          () => _selectedGender = gender,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 32),

                              const Text(
                                'My Goal',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ..._modes.map(
                                (mode) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _SelectionCard(
                                    title: mode['title']!,
                                    description: mode['description'],
                                    isSelected: _selectedMode == mode['title'],
                                    onTap: () => setState(
                                      () => _selectedMode = mode['title'],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                      // Sticky Bottom Button
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(
                              color: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: AppButton(
                          text: 'Continue',
                          onPressed: () {
                            final store = OnboardingStore();
                            store.update(
                              store.draft.copyWith(
                                gender: _selectedGender,
                                mode: _selectedMode,
                              ),
                            );
                            AppNavigation.pushNamed(
                              context,
                              AppRoutes.bodyTypeSelection,
                            );
                          },
                          isDisabled: !_canContinue,
                          style: AppButtonStyle.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0D9488)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String title;
  final String? description;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.title,
    this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF0FDFA) // Light Teal bg
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0D9488)
                : const Color(0xFFE2E8F0),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF0D9488).withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF0D9488)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected
                            ? const Color(0xFF0F766E).withOpacity(0.8)
                            : const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF0D9488)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0D9488)
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
