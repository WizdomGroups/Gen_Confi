# API Configuration Guide

## Overview

All API endpoints and configurations are now centralized in `lib/core/config/api_config.dart`. This makes it easy to switch between different environments (emulator, local, development, production).

## Quick Start

### 1. Open the Configuration File

Edit: `lib/core/config/api_config.dart`

### 2. Change the Environment

Find this line and change it:

```dart
static const ApiEnvironment currentEnvironment = ApiEnvironment.local;
```

**Available Options:**
- `ApiEnvironment.emulator` - For Android Emulator
- `ApiEnvironment.local` - For USB-connected device (requires ADB port forwarding)
- `ApiEnvironment.development` - Development/staging server
- `ApiEnvironment.production` - Production server

### 3. Update Server URLs (if needed)

If you need to change the server URLs, edit these constants:

```dart
// Emulator (Android Emulator)
static const String emulatorBaseUrl = 'http://10.0.2.2:8000/api/v1';

// Local (USB-connected device)
static const String localBaseUrl = 'http://127.0.0.1:8000/api/v1';

// Development (staging server)
static const String developmentBaseUrl = 'http://dev.example.com:8000/api/v1';

// Production
static const String productionBaseUrl = 'https://api.genconfi.com/api/v1';
```

## Environment Details

### Emulator (`ApiEnvironment.emulator`)
- **Use Case**: Testing on Android Emulator
- **Base URL**: `http://10.0.2.2:8000/api/v1`
- **Setup**: No additional setup needed
- **Note**: `10.0.2.2` is a special IP that maps to the host machine's localhost in Android Emulator

### Local (`ApiEnvironment.local`)
- **Use Case**: Testing on physical device connected via USB
- **Base URL**: `http://127.0.0.1:8000/api/v1`
- **Setup Required**: 
  ```powershell
  adb reverse tcp:8000 tcp:8000
  ```
- **Note**: Requires ADB port forwarding to work

### Development (`ApiEnvironment.development`)
- **Use Case**: Testing against staging/development server
- **Base URL**: Update `developmentBaseUrl` with your dev server URL
- **Setup**: Ensure your development server is accessible

### Production (`ApiEnvironment.production`)
- **Use Case**: Production/release builds
- **Base URL**: Update `productionBaseUrl` with your production server URL
- **Setup**: Ensure your production server is accessible

## Usage in Code

### Getting Base URL

```dart
import 'package:gen_confi/core/config/api_config.dart';

final baseUrl = ApiConfig.baseUrl;
```

### Using Endpoints

```dart
import 'package:gen_confi/core/config/api_config.dart';

// Auth endpoints
final loginUrl = ApiConfig.login; // '/auth/login'
final signupUrl = ApiConfig.signup; // '/auth/signup'

// User endpoints
final usersUrl = ApiConfig.users; // '/users'
final userUrl = ApiConfig.userById(123); // '/users/123'

// Get full URL
final fullLoginUrl = ApiConfig.getFullUrl(ApiConfig.login);
```

### Checking Environment

```dart
if (ApiConfig.isProduction) {
  // Production-specific code
}

if (ApiConfig.isDevelopment) {
  // Development-specific code
}
```

## Migration from Old Code

### Old Way (Deprecated)
```dart
import 'package:gen_confi/core/constants/api_constants.dart';

final url = ApiConstants.baseUrl;
final login = ApiConstants.login;
```

### New Way (Recommended)
```dart
import 'package:gen_confi/core/config/api_config.dart';

final url = ApiConfig.baseUrl;
final login = ApiConfig.login;
```

## Troubleshooting

### Connection Refused Error

If you see "Connection refused" errors:

1. **For Emulator**: Make sure your backend server is running on `localhost:8000`
2. **For Local (USB)**: 
   - Run: `adb reverse tcp:8000 tcp:8000`
   - Verify: `adb reverse --list` should show `tcp:8000 tcp:8000`
   - Make sure backend server is running on `localhost:8000`
3. **For Development/Production**: Check that the server URL is correct and accessible

### Switching Environments

After changing `currentEnvironment`, you need to:
1. **Hot Restart** the app (press `R` in Flutter terminal)
2. Or stop and restart the app completely

Hot reload won't work because the DioClient provider is cached.

## Example Configuration

```dart
// For development on physical device
static const ApiEnvironment currentEnvironment = ApiEnvironment.local;

// For testing on emulator
static const ApiEnvironment currentEnvironment = ApiEnvironment.emulator;

// For staging/testing
static const ApiEnvironment currentEnvironment = ApiEnvironment.development;

// For production release
static const ApiEnvironment currentEnvironment = ApiEnvironment.production;
```

## Best Practices

1. **Never commit production credentials** in the config file
2. **Use environment variables** for sensitive URLs in production
3. **Test all environments** before releasing
4. **Document your server URLs** in team documentation
5. **Use different configs** for different build flavors if needed

