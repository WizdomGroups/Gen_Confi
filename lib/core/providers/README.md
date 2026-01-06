# Riverpod Providers Usage Guide

## Available Providers

### Auth Providers

#### `authProvider` - Main auth state
```dart
final authState = ref.watch(authProvider);
// Access: authState.isAuthenticated, authState.user, authState.isLoading, authState.error
```

#### `isAuthenticatedProvider` - Quick check if logged in
```dart
final isLoggedIn = ref.watch(isAuthenticatedProvider);
```

#### `currentUserProvider` - Current user data
```dart
final user = ref.watch(currentUserProvider);
```

#### `authLoadingProvider` - Loading state
```dart
final isLoading = ref.watch(authLoadingProvider);
```

#### `authErrorProvider` - Error message
```dart
final error = ref.watch(authErrorProvider);
```

### Using Auth in Widgets

```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    
    // Login
    await authNotifier.login(email, password);
    
    // Signup
    await authNotifier.signup(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    
    // Logout
    await authNotifier.logout();
  }
}
```

### User Providers

#### `usersListProvider` - Get list of users
```dart
final usersAsync = ref.watch(usersListProvider((skip: 0, limit: 10)));

usersAsync.when(
  data: (users) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

#### `userByIdProvider` - Get user by ID
```dart
final userAsync = ref.watch(userByIdProvider(1));

userAsync.when(
  data: (user) => Text(user.name),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

## Example: Login Screen

```dart
class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.login(
      _emailController.text,
      _passwordController.text,
    );
    
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      body: authState.isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TextField(controller: _emailController),
                TextField(controller: _passwordController),
                ElevatedButton(
                  onPressed: _handleLogin,
                  child: Text('Login'),
                ),
                if (authState.error != null)
                  Text(authState.error!, style: TextStyle(color: Colors.red)),
              ],
            ),
    );
  }
}
```

