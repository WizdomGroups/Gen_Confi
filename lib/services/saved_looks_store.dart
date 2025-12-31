import 'package:gen_confi/features/smart_capture/data/dummy_analysis_data.dart';

/// Service to manage saved hairstyle looks
class SavedLooksStore {
  // Singleton pattern
  static final SavedLooksStore _instance = SavedLooksStore._internal();
  factory SavedLooksStore() => _instance;
  SavedLooksStore._internal();

  // In-memory storage for saved looks
  final List<HairstyleRecommendation> _savedLooks = [];

  // Getters
  List<HairstyleRecommendation> get savedLooks => List.unmodifiable(_savedLooks);
  int get savedCount => _savedLooks.length;
  bool get hasSavedLooks => _savedLooks.isNotEmpty;

  /// Check if a hairstyle is saved
  bool isSaved(HairstyleRecommendation hairstyle) {
    return _savedLooks.any((saved) => saved.name == hairstyle.name);
  }

  /// Save a hairstyle look
  bool saveLook(HairstyleRecommendation hairstyle) {
    if (!isSaved(hairstyle)) {
      _savedLooks.add(hairstyle);
      // TODO: Persist to local storage (SharedPreferences/Hive)
      return true;
    }
    return false; // Already saved
  }

  /// Remove a saved hairstyle look
  bool removeLook(HairstyleRecommendation hairstyle) {
    final initialLength = _savedLooks.length;
    _savedLooks.removeWhere((saved) => saved.name == hairstyle.name);
    final removed = initialLength > _savedLooks.length;
    // TODO: Update local storage
    return removed;
  }

  /// Toggle save status (save if not saved, remove if saved)
  bool toggleSave(HairstyleRecommendation hairstyle) {
    if (isSaved(hairstyle)) {
      return removeLook(hairstyle);
    } else {
      return saveLook(hairstyle);
    }
  }

  /// Clear all saved looks
  void clearAll() {
    _savedLooks.clear();
    // TODO: Clear from local storage
  }

  /// Get saved look by name
  HairstyleRecommendation? getLookByName(String name) {
    try {
      return _savedLooks.firstWhere((look) => look.name == name);
    } catch (e) {
      return null;
    }
  }
}

