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

  void reset() {
    _draft = const OnboardingDraft();
  }
}
