enum UserRole { client, expert, admin, none }

class AuthStore {
  // Singleton pattern
  static final AuthStore _instance = AuthStore._internal();
  factory AuthStore() => _instance;
  AuthStore._internal();

  UserRole _currentRole = UserRole.none;
  String? _currentUserEmail;

  // Onboarding status (in-memory mock)
  bool _clientOnboardingComplete = false;
  bool _expertOnboardingComplete = false;
  
  // Grooming status (in-memory mock)
  bool _hasCompletedGrooming = false;
  String? _groomingImagePath;
  String? _avatarUrl;
  
  // Getters
  UserRole get role => _currentRole;
  String? get userEmail => _currentUserEmail;
  bool get isLoggedIn => _currentRole != UserRole.none;
  bool get hasCompletedGrooming => _hasCompletedGrooming;
  String? get groomingImagePath => _groomingImagePath;
  String? get avatarUrl => _avatarUrl;
  
  void setGroomingCompleted(bool value, {String? imagePath}) {
    _hasCompletedGrooming = value;
    if (imagePath != null) {
      _groomingImagePath = imagePath;
    }
  }

  void setAvatarUrl(String url) {
    _avatarUrl = url;
  }

  bool get isOnboardingCompleteForRole {
    if (_currentRole == UserRole.client) return _clientOnboardingComplete;
    if (_currentRole == UserRole.expert) return _expertOnboardingComplete;
    // Admin has no onboarding
    return true;
  }

  // Login logic with dummy credentials
  bool login(String email, String password) {
    if (email == 'user@example.com' && password == 'User') {
      _currentRole = UserRole.client;
      _currentUserEmail = email;
      _clientOnboardingComplete = true; // Existing user mock
      return true;
    }
    if (email == 'prajwal@example.com' && password == 'Prajwal') {
      _currentRole = UserRole.expert;
      _currentUserEmail = email;
      _expertOnboardingComplete = true; // Existing user mock
      return true;
    }
    if (email == 'admin@example.com' && password == 'Admin') {
      _currentRole = UserRole.admin;
      _currentUserEmail = email;
      return true;
    }
    return false;
  }

  // Logout
  void logout() {
    _currentRole = UserRole.none;
    _currentUserEmail = null;
  }

  // Fake Signup Logic
  void signup(String email, String password, UserRole role) {
    _currentRole = role;
    _currentUserEmail = email;
    // In a real app, we'd save the password/user to a DB here.
    // For now, we just auto-login the user into this session.
  }

  // Mark onboarding complete
  void markOnboardingCompleteForCurrentRole() {
    if (_currentRole == UserRole.client) {
      _clientOnboardingComplete = true;
    } else if (_currentRole == UserRole.expert) {
      _expertOnboardingComplete = true;
    }
    // TODO: Persist this status to local storage (Hive/SharedPrefs)
  }
}
