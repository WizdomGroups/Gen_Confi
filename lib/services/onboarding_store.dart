import 'package:gen_confi/models/onboarding_draft.dart';

class OnboardingStore {
  // Singleton pattern
  static final OnboardingStore _instance = OnboardingStore._internal();
  factory OnboardingStore() => _instance;
  OnboardingStore._internal();

  OnboardingDraft _draft = const OnboardingDraft();

  OnboardingDraft get draft => _draft;

  void update(OnboardingDraft newDraft) {
    _draft = newDraft;
  }

  void updateDraft({
    String? gender,
    String? bodyType,
    String? fitPreference,
    List<String>? styleTags,
    String? hairType,
    String? skinType,
    String? beardPreference,
    String? makeupFrequency,
    String? hairGoal,
    String? skinGoal,
  }) {
    _draft = _draft.copyWith(
      gender: gender,
      bodyType: bodyType,
      fitPreference: fitPreference,
      styleTags: styleTags,
      hairType: hairType,
      skinType: skinType,
      beardPreference: beardPreference,
      makeupFrequency: makeupFrequency,
      hairGoal: hairGoal,
      skinGoal: skinGoal,
    );
  }

  void reset() {
    _draft = const OnboardingDraft();
  }
}
