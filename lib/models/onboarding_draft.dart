class OnboardingDraft {
  final String? gender;
  final String? mode;
  final String? bodyType;
  final List<String> styleTags;
  final String? fitPreference;
  final List<String> colorPrefs;
  final String? skinType;
  final String? hairType;
  final String? beardPreference;
  final String? makeupFrequency;
  final List<String> groomingConcerns;
  final String? hairGoal;
  final String? skinGoal;

  const OnboardingDraft({
    this.gender,
    this.mode,
    this.bodyType,
    this.styleTags = const [],
    this.fitPreference,
    this.colorPrefs = const [],
    this.skinType,
    this.hairType,
    this.beardPreference,
    this.makeupFrequency,
    this.groomingConcerns = const [],
    this.hairGoal,
    this.skinGoal,
  });

  OnboardingDraft copyWith({
    String? gender,
    String? mode,
    String? bodyType,
    List<String>? styleTags,
    String? fitPreference,
    List<String>? colorPrefs,
    String? skinType,
    String? hairType,
    String? beardPreference,
    String? makeupFrequency,
    List<String>? groomingConcerns,
    String? hairGoal,
    String? skinGoal,
  }) {
    return OnboardingDraft(
      gender: gender ?? this.gender,
      mode: mode ?? this.mode,
      bodyType: bodyType ?? this.bodyType,
      styleTags: styleTags ?? this.styleTags,
      fitPreference: fitPreference ?? this.fitPreference,
      colorPrefs: colorPrefs ?? this.colorPrefs,
      skinType: skinType ?? this.skinType,
      hairType: hairType ?? this.hairType,
      beardPreference: beardPreference ?? this.beardPreference,
      makeupFrequency: makeupFrequency ?? this.makeupFrequency,
      groomingConcerns: groomingConcerns ?? this.groomingConcerns,
      hairGoal: hairGoal ?? this.hairGoal,
      skinGoal: skinGoal ?? this.skinGoal,
    );
  }

  // Serialization for future use
  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'mode': mode,
      'bodyType': bodyType,
      'styleTags': styleTags,
      'fitPreference': fitPreference,
      'colorPrefs': colorPrefs,
      'skinType': skinType,
      'hairType': hairType,
      'beardPreference': beardPreference,
      'makeupFrequency': makeupFrequency,
      'groomingConcerns': groomingConcerns,
      'hairGoal': hairGoal,
      'skinGoal': skinGoal,
    };
  }

  factory OnboardingDraft.fromJson(Map<String, dynamic> json) {
    return OnboardingDraft(
      gender: json['gender'] as String?,
      mode: json['mode'] as String?,
      bodyType: json['bodyType'] as String?,
      styleTags:
          (json['styleTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      fitPreference: json['fitPreference'] as String?,
      colorPrefs:
          (json['colorPrefs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      skinType: json['skinType'] as String?,
      hairType: json['hairType'] as String?,
      beardPreference: json['beardPreference'] as String?,
      makeupFrequency: json['makeupFrequency'] as String?,
      groomingConcerns:
          (json['groomingConcerns'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      hairGoal: json['hairGoal'] as String?,
      skinGoal: json['skinGoal'] as String?,
    );
  }
}
