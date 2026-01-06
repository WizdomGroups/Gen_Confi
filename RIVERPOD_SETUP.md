# Riverpod Integration Setup Guide

## ✅ What's Been Integrated

### 1. Packages Added
- `flutter_riverpod` - State management
- `dio` - HTTP client
- `shared_preferences` - Token storage
- `json_annotation` & `json_serializable` - JSON serialization

### 2. Files Created

#### Models
- `lib/core/models/user_model.dart` - User data model
- `lib/core/models/auth_models.dart` - Auth request/response models

#### API Layer
- `lib/core/api/dio_client.dart` - Dio client with interceptors
- `lib/core/api/api_exceptions.dart` - Custom exceptions
- `lib/core/constants/api_constants.dart` - API endpoints

#### Services
- `lib/core/services/auth_service.dart` - Authentication API calls
- `lib/core/services/user_service.dart` - User API calls
- `lib/core/storage/token_storage.dart` - Secure token storage

#### Providers
- `lib/core/providers/api_providers.dart` - Service providers
- `lib/core/providers/auth_provider.dart` - Auth state management
- `lib/core/providers/user_provider.dart` - User data providers

## 🚀 Setup Steps

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Generate JSON Serialization Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `user_model.g.dart`
- `auth_models.g.dart`

### Step 3: Update API Base URL

Edit `lib/core/constants/api_constants.dart`:

```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

// For iOS Simulator
static const String baseUrl = 'http://localhost:8000/api/v1';

// For Physical Device (use your computer's IP)
static const String baseUrl = 'http://192.168.1.100:8000/api/v1';
```

### Step 4: Update Your Login/Signup Screens

Convert your auth screens to use Riverpod:

```dart
// Change from StatelessWidget to ConsumerStatefulWidget
class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Use ref.read(authProvider.notifier) to call login
  // Use ref.watch(authProvider) to listen to auth state
}
```

## 📱 Usage Examples

### Login Example
```dart
final authNotifier = ref.read(authProvider.notifier);
final success = await authNotifier.login(email, password);
if (success) {
  // Navigate to home
}
```

### Check Auth Status
```dart
final isLoggedIn = ref.watch(isAuthenticatedProvider);
final user = ref.watch(currentUserProvider);
```

### Signup Example
```dart
final authNotifier = ref.read(authProvider.notifier);
final success = await authNotifier.signup(
  name: name,
  email: email,
  phone: phone,
  password: password,
);
```

## 🔧 Architecture

```
lib/
├── core/
│   ├── api/
│   │   ├── dio_client.dart          # HTTP client with interceptors
│   │   └── api_exceptions.dart      # Error handling
│   ├── constants/
│   │   └── api_constants.dart       # API endpoints
│   ├── models/
│   │   ├── user_model.dart          # User model
│   │   └── auth_models.dart         # Auth models
│   ├── providers/
│   │   ├── api_providers.dart       # Service providers
│   │   ├── auth_provider.dart       # Auth state
│   │   └── user_provider.dart       # User data
│   ├── services/
│   │   ├── auth_service.dart        # Auth API calls
│   │   └── user_service.dart        # User API calls
│   └── storage/
│       └── token_storage.dart       # Token storage
```

## 🔑 Key Features

1. **Automatic Token Management**
   - Token automatically added to all requests
   - Auto-clears on 401 errors
   - Persists across app restarts

2. **Reactive State**
   - UI automatically updates when auth state changes
   - No manual setState needed

3. **Type Safety**
   - Compile-time error checking
   - Auto-completion support

4. **Error Handling**
   - Centralized error handling
   - User-friendly error messages

## 🧪 Testing

### Test Login
```dart
// In your login screen
final authNotifier = ref.read(authProvider.notifier);
final success = await authNotifier.login('user@example.com', 'password');
```

### Test Token Persistence
1. Login
2. Close app
3. Reopen app
4. Should auto-login if token is valid

## 📝 Next Steps

1. Update your login/signup screens to use Riverpod
2. Update splash screen to check auth status
3. Add navigation based on auth state
4. Update profile screens to use user provider
5. Add error handling UI

## ⚠️ Important Notes

- Run `build_runner` after any model changes
- Update `api_constants.dart` with correct base URL
- Token expires in 30 days (configurable in backend)
- All API calls automatically include token in headers

