// FILE: lib/mock/grooming_mock.dart

import 'package:gen_confi/models/onboarding_draft.dart';

class GroomingStep {
  final String title;
  final String description;
  final int? durationSeconds;

  const GroomingStep({
    required this.title,
    required this.description,
    this.durationSeconds,
  });
}

List<GroomingStep> getRoutineSteps({
  required String routineKey,
  required OnboardingDraft draft,
}) {
  // Personalize slightly based on onboarding
  final isOily = draft.skinType == 'Oily';
  final isDry = draft.skinType == 'Dry';
  final isSensitive = draft.skinType == 'Sensitive';

  switch (routineKey) {
    // --- SKIN AM ---
    case 'skin_am_quick':
      return [
        GroomingStep(
          title: 'Cleanse',
          description: isOily
              ? 'Use a foaming cleanser to remove excess oil.'
              : 'Splash face with lukewarm water or use a gentle cleanser.',
          durationSeconds: 30,
        ),
        GroomingStep(
          title: 'Moisturize & Protect',
          description: 'Apply a moisturizer with SPF 30 or higher.',
          durationSeconds: 30,
        ),
      ];

    case 'skin_am_balanced':
      return [
        GroomingStep(
          title: 'Cleanse',
          description: 'Wash face thoroughly to remove impurities.',
          durationSeconds: 45,
        ),
        if (isDry)
          const GroomingStep(
            title: 'Hydrate',
            description: 'Apply a hydrating toner or serum.',
            durationSeconds: 30,
          ),
        const GroomingStep(
          title: 'Moisturize',
          description: 'Apply a lightweight moisturizer to lock in hydration.',
          durationSeconds: 30,
        ),
        const GroomingStep(
          title: 'Sun Protection',
          description: 'Apply sunscreen evenly across face and neck.',
          durationSeconds: 45,
        ),
      ];

    case 'skin_am_full':
      return [
        const GroomingStep(
          title: 'Cleanse',
          description: 'Start with a gentle cleanser.',
          durationSeconds: 60,
        ),
        const GroomingStep(
          title: 'Tone',
          description: 'Balance your skin pH with a toner.',
          durationSeconds: 30,
        ),
        const GroomingStep(
          title: 'Serum',
          description: 'Apply Vitamin C serum for brightness.',
          durationSeconds: 45,
        ),
        const GroomingStep(
          title: 'Eye Cream',
          description: 'Gently tap eye cream around the orbital bone.',
          durationSeconds: 30,
        ),
        const GroomingStep(
          title: 'Moisturize',
          description: 'Seal everything in with a good moisturizer.',
          durationSeconds: 45,
        ),
        const GroomingStep(
          title: 'SPF',
          description: 'Finish with broad-spectrum sunscreen.',
          durationSeconds: 60,
        ),
      ];

    // --- SKIN PM ---
    case 'skin_pm_quick':
      return [
        const GroomingStep(
          title: 'Cleanse',
          description: 'Wash away the day\'s dirt and grime.',
          durationSeconds: 45,
        ),
        GroomingStep(
          title: 'Moisturize',
          description: isOily
              ? 'Use a gel-based night moisturizer.'
              : 'Apply a rich night cream.',
          durationSeconds: 45,
        ),
      ];

    case 'skin_pm_balanced':
      return [
        const GroomingStep(
          title: 'Cleanse',
          description: 'Use a cleanser suitable for your skin type.',
          durationSeconds: 60,
        ),
        if (isSensitive)
          const GroomingStep(
            title: 'Calm',
            description: 'Apply a soothing serum or essence.',
            durationSeconds: 30,
          ),
        const GroomingStep(
          title: 'Treat',
          description: 'Apply spot treatment if needed.',
          durationSeconds: 30,
        ),
        const GroomingStep(
          title: 'Moisturize',
          description: 'Hydrate your skin while you sleep.',
          durationSeconds: 45,
        ),
      ];

    case 'skin_pm_full':
      return [
        const GroomingStep(
          title: 'Double Cleanse (Oil)',
          description: 'Dissolve sunscreen and makeup with an oil cleanser.',
          durationSeconds: 60,
        ),
        const GroomingStep(
          title: 'Double Cleanse (Water)',
          description: 'Follow up with a water-based cleanser.',
          durationSeconds: 45,
        ),
        const GroomingStep(
          title: 'Exfoliate',
          description: 'Use a chemical exfoliant (2-3 times a week).',
          durationSeconds: 60,
        ),
        const GroomingStep(
          title: 'Serum',
          description: 'Apply a retinol or night serum.',
          durationSeconds: 45,
        ),
        const GroomingStep(
          title: 'Moisturize',
          description: 'Apply a thick layer of moisturizer.',
          durationSeconds: 60,
        ),
      ];

    default:
      return [
        const GroomingStep(
          title: 'General Care',
          description: 'Take care of your grooming needs.',
          durationSeconds: 60,
        ),
      ];
  }
}
