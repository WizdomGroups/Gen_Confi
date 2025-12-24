class OnboardingDraft {
  final String? gender;
  final String? mode;
  final String? bodyType;
  final List<String> styleTags;
  final String? fitPreference;
  final List<String> colorPrefs;
  final String? skinType;
  final String? hairType;
  final String? groomingGoal;
  final String? facialPreference;

  const OnboardingDraft({
    this.gender,
    this.mode,
    this.bodyType,
    this.styleTags = const [],
    this.fitPreference,
    this.colorPrefs = const [],
    this.skinType,
    this.hairType,
    this.groomingGoal,
    this.facialPreference,
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
    String? groomingGoal,
    String? facialPreference,
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
      groomingGoal: groomingGoal ?? this.groomingGoal,
      facialPreference: facialPreference ?? this.facialPreference,
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
      'groomingGoal': groomingGoal,
      'facialPreference': facialPreference,
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
      groomingGoal: json['groomingGoal'] as String?,
      facialPreference: json['facialPreference'] as String?,
    );
  }
}
