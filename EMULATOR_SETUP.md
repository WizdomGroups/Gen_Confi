# Android Emulator Setup Guide

## ✅ Configuration Updated

The API configuration has been set to **Emulator Mode**:
- **Environment**: `ApiEnvironment.emulator`
- **Base URL**: `http://10.0.2.2:8000/api/v1`

## Why 10.0.2.2?

Android Emulator uses a special IP address mapping:
- `10.0.2.2` in the emulator = `localhost` (127.0.0.1) on your computer
- This allows the emulator to access services running on your host machine

## Next Steps

### 1. Hot Restart the App ⚠️ CRITICAL

You **MUST** hot restart the app for the configuration change to take effect:

**In Flutter terminal, press: `R` (capital R)**

Or stop and restart:
```bash
# Press 'q' to quit
flutter run
```

### 2. Verify Backend Server is Running

Make sure your backend server is running on `localhost:8000`:

```powershell
# Check if server is running
curl http://localhost:8000/health

# If not running, start it:
cd D:\Freelance\GenConfi\Gen_Confi_Backend
.\venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 3. Test the Connection

After restarting the app, try logging in. You should see in the logs:

```
🔧 [ApiConfig] Current Environment: ApiEnvironment.emulator
🔧 [ApiConfig] Base URL: http://10.0.2.2:8000/api/v1
🌐 [DioClient] Making POST request to: http://10.0.2.2:8000/api/v1/auth/login
```

## Switching Between Environments

### For Emulator (Current)
```dart
static const ApiEnvironment currentEnvironment = ApiEnvironment.emulator;
```

### For USB-Connected Device
```dart
static const ApiEnvironment currentEnvironment = ApiEnvironment.local;
```
Then run: `adb reverse tcp:8000 tcp:8000`

### For Development Server
```dart
static const ApiEnvironment currentEnvironment = ApiEnvironment.development;
```

### For Production
```dart
static const ApiEnvironment currentEnvironment = ApiEnvironment.production;
```

## Troubleshooting

### Connection Refused Error

If you see "Connection refused":
1. ✅ Check backend server is running: `curl http://localhost:8000/health`
2. ✅ Verify you did a **hot restart** (not just hot reload)
3. ✅ Check the logs show `10.0.2.2` (not `127.0.0.1`)

### Still Not Working?

1. **Verify emulator is running**: Check Android Studio
2. **Check backend logs**: Make sure server is accepting connections
3. **Try accessing from emulator browser**: Open `http://10.0.2.2:8000/health` in emulator's browser

## Quick Reference

| Environment | Base URL | Use Case |
|------------|----------|----------|
| Emulator | `http://10.0.2.2:8000/api/v1` | Android Studio Emulator |
| Local | `http://127.0.0.1:8000/api/v1` | USB device (needs ADB forwarding) |
| Development | `http://dev.example.com:8000/api/v1` | Staging server |
| Production | `https://api.genconfi.com/api/v1` | Production server |

