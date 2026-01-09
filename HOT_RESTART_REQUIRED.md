# ⚠️ HOT RESTART REQUIRED

## Problem
The app is still using the old IP address (`10.20.190.66`) even though the code has been updated to use `localhost:8000`.

## Why This Happens
- `DioClient` is created by a Riverpod Provider
- Riverpod providers are **cached** and persist across hot reloads
- Hot reload only updates changed widgets, not provider instances
- The `DioClient` instance was created with the old URL and is still cached

## Solution: HOT RESTART (Not Hot Reload)

### In Flutter Terminal:
1. **Press `R` (capital R)** in the terminal where `flutter run` is active
   - This does a **HOT RESTART** which recreates all providers
   - Hot reload (lowercase `r`) won't work for this change

2. **OR** Stop and restart the app:
   - Press `q` to quit
   - Run `flutter run` again

### What You Should See After Restart:
```
📱 [ApiConstants] Android detected - Using: http://localhost:8000/api/v1
🔧 [DioClient] Initializing with baseUrl: http://localhost:8000/api/v1
```

### Verify It's Working:
After hot restart, try logging in. You should see:
- ✅ No more `10.20.190.66` in the error messages
- ✅ URL should show `http://localhost:8000/api/v1/auth/login`
- ✅ Connection should succeed (if ADB port forwarding is active)

## Quick Check Commands

### Verify ADB Port Forwarding:
```powershell
cd D:\Freelance\GenConfi\gen_confi
$adbPath = "C:\Users\QS-FAR-LT-0010\AppData\Local\Android\Sdk\platform-tools\adb.exe"
& $adbPath reverse --list
```

Should show: `tcp:8000 tcp:8000`

### If Port Forwarding is Missing:
```powershell
.\setup_usb_connection.ps1
```

## Summary
- ✅ Code is correct: `localhost:8000` is set
- ✅ ADB port forwarding is active
- ⚠️ **Need HOT RESTART** to apply the change
- Press `R` in Flutter terminal or restart the app

