# Fix API Connection Error

## Problem
The app shows `❌ API Error: [null] /auth/login` which means it cannot connect to the backend server.

## Root Cause
The configured IP address in `api_constants.dart` doesn't match your computer's current IP address.

## Solution

### Step 1: Find Your Computer's IP Address
```powershell
ipconfig | findstr IPv4
```

Or run:
```powershell
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" }
```

### Step 2: Update API Constants
Edit `gen_confi/lib/core/constants/api_constants.dart` and update the IP address:

```dart
if (io.Platform.isAndroid) {
  // Update this IP to your computer's IP address
  final url = 'http://YOUR_IP_HERE:8000/api/v1';
  return url;
}
```

### Step 3: Verify Backend Server is Running
```powershell
# Check if server is running
curl http://localhost:8000/health

# If not running, start it:
cd D:\Freelance\GenConfi\Gen_Confi_Backend
.\venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Step 4: Test Connection
Run the diagnostic script:
```powershell
cd D:\Freelance\GenConfi\gen_confi
.\check_backend_connection.ps1
```

### Step 5: Hot Restart Flutter App
After updating the IP, hot restart your Flutter app (not just hot reload):
- Press `R` in the terminal where `flutter run` is active
- Or stop and restart the app

## Current Configuration
- **Server Status**: ✅ Running on localhost:8000
- **Current IP**: 10.93.242.66
- **Configured IP**: 10.93.242.66 (updated)
- **API Base URL**: http://10.93.242.66:8000/api/v1

## Troubleshooting

### If connection still fails:

1. **Check Windows Firewall**
   - Allow port 8000 for incoming connections
   - Or temporarily disable firewall to test

2. **Verify Same Network**
   - Device and computer must be on the same Wi-Fi network
   - Check device's Wi-Fi settings

3. **Try Emulator IP**
   - If using Android emulator, use: `http://10.0.2.2:8000/api/v1`

4. **Check Server Binding**
   - Server must be started with `--host 0.0.0.0` (not just `localhost`)
   - Command: `uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`

## Quick Fix Script
```powershell
# Get your IP and update the file automatically
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" } | Select-Object -First 1).IPAddress
Write-Host "Your IP: $ip"
Write-Host "Update gen_confi/lib/core/constants/api_constants.dart with: http://$ip:8000/api/v1"
```

