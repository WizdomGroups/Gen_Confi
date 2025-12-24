import 'package:flutter/material.dart';
import 'package:gen_confi/app/routes/app_routes.dart';
import 'package:gen_confi/client/onboarding/widgets/onboarding_shell.dart';
import 'package:gen_confi/services/onboarding_store.dart';

class BodyTypeScreen extends StatefulWidget {
  const BodyTypeScreen({super.key});

  @override
  State<BodyTypeScreen> createState() => _BodyTypeScreenState();
}

class _BodyTypeScreenState extends State<BodyTypeScreen> {
  String? _selectedBodyType;

  // Use reliable Unsplash IDs for realistic body representations
  // Fallback to icons if needed
  final Map<String, List<BodyTypeOption>> _optionsByGender = {
    'Male': [
      BodyTypeOption(
        id: 'slim',
        label: 'Slim',
        description: 'Lean and slender build',
        icon: Icons.accessibility_new_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1615887023596-f56f43272dfa?w=400&fit=crop', // Slim man
      ),
      BodyTypeOption(
        id: 'athletic',
        label: 'Athletic',
        description: 'Toned and muscular',
        icon: Icons.fitness_center_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400&fit=crop', // Athletic man
      ),
      BodyTypeOption(
        id: 'average',
        label: 'Average',
        description: 'Medium build',
        icon: Icons.person_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1617134301135-fa5e62f5581b?w=400&fit=crop', // Casual man
      ),
      BodyTypeOption(
        id: 'broad',
        label: 'Broad',
        description: 'Broad shoulders',
        icon: Icons.person_add_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&fit=crop', // Broad frame
      ),
      BodyTypeOption(
        id: 'images',
        label: 'Plus',
        description: 'Fuller figure',
        icon: Icons.person_4_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1544098363-2280d9ad2d84?w=400&fit=crop', // Plus size
      ),
    ],
    'Female': [
      BodyTypeOption(
        id: 'slim',
        label: 'Slim',
        description: 'Lean and slender build',
        icon: Icons.accessibility_new_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1534030347209-7147ca44199c?w=400&fit=crop', // Slim woman
      ),
      BodyTypeOption(
        id: 'athletic',
        label: 'Athletic',
        description: 'Toned and muscular',
        icon: Icons.fitness_center_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=400&fit=crop', // Athletic woman
      ),
      BodyTypeOption(
        id: 'average',
        label: 'Average',
        description: 'Medium build',
        icon: Icons.person_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&fit=crop', // Average woman
      ),
      BodyTypeOption(
        id: 'curvy',
        label: 'Curvy',
        description: 'Hourglass figure',
        icon: Icons.hourglass_empty_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1525151433895-7117e366a6a7?w=400&fit=crop', // Curvy woman
      ),
      BodyTypeOption(
        id: 'plus',
        label: 'Plus',
        description: 'Fuller figure',
        icon: Icons.person_4_rounded,
        imageUrl:
            'https://images.unsplash.com/photo-1607599026210-671c26d7d6b0?w=400&fit=crop', // Plus woman
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedBodyType = OnboardingStore().draft.bodyType;
  }

  void _handleContinue() {
    if (_selectedBodyType != null) {
      OnboardingStore().update(
        OnboardingStore().draft.copyWith(bodyType: _selectedBodyType),
      );
      Navigator.pushNamed(context, AppRoutes.clientOnboardingStylePreferences);
    }
  }

  List<BodyTypeOption> get _currentOptions {
    final gender = OnboardingStore().draft.gender ?? 'Male';
    // Fallback if exact gender string doesn't match keys (e.g. 'Other' -> 'Male')
    return _optionsByGender[gender] ?? _optionsByGender['Male']!;
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      stepIndex: 2,
      totalSteps: 4,
      title: 'Your body type',
      subtitle:
          'This helps us recommend better fits. You can change this later.',
      primaryCtaText: 'Continue',
      primaryEnabled: _selectedBodyType != null,
      onPrimaryPressed: _handleContinue,
      onSkip: () {
        // Default based on gender
        OnboardingStore().update(
          OnboardingStore().draft.copyWith(bodyType: 'average'),
        );
        Navigator.pushNamed(
          context,
          AppRoutes.clientOnboardingStylePreferences,
        );
      },
      showSkip: true,
      child: Column(
        children: _currentOptions.map((option) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _BodyTypeCard(
              option: option,
              isSelected: _selectedBodyType == option.id,
              onTap: () {
                setState(() {
                  _selectedBodyType = option.id;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BodyTypeOption {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final String imageUrl;

  BodyTypeOption({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.imageUrl,
  });
}

class _BodyTypeCard extends StatelessWidget {
  final BodyTypeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _BodyTypeCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0FDFA) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: const Color(0xFF0D9488).withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12), // Reduced padding
            child: Row(
              children: [
                // Image Container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 70, // Smaller width
                  height: 70, // Smaller height (was 100)
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0D9488)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      option.imageUrl,
                      fit: BoxFit.cover,
                      opacity: AlwaysStoppedAnimation(isSelected ? 1.0 : 0.8),
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            option.icon,
                            size: 32,
                            color: isSelected
                                ? const Color(0xFF0D9488)
                                : const Color(0xFF94A3B8),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? const Color(0xFF0D9488)
                              : const Color(0xFF1E293B),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Radio Button Checkmark
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0D9488)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0D9488)
                          : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
