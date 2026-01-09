# Script to fix APK installation issues
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Fixing APK Installation Issue" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$packageName = "com.example.gen_confi"
$apkPath = "build\app\outputs\flutter-apk\app-debug.apk"

Write-Host "Package Name: $packageName" -ForegroundColor Cyan
Write-Host "APK Path: $apkPath" -ForegroundColor Cyan
Write-Host ""

# Step 1: Verify APK exists
if (-not (Test-Path $apkPath)) {
    Write-Host "[ERROR] APK not found at: $apkPath" -ForegroundColor Red
    Write-Host "Building APK first..." -ForegroundColor Yellow
    flutter build apk --debug
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Failed to build APK" -ForegroundColor Red
        exit 1
    }
}

# Step 2: Use Flutter to uninstall (Flutter handles ADB internally)
Write-Host "Step 1: Uninstalling old app (if exists)..." -ForegroundColor Yellow
flutter uninstall 2>&1 | Out-Null
Write-Host "[OK] Uninstall attempt completed" -ForegroundColor Green
Write-Host ""

# Step 3: Try installing via Flutter
Write-Host "Step 2: Installing APK via Flutter..." -ForegroundColor Yellow
Write-Host "This will use Flutter's built-in ADB..." -ForegroundColor Cyan
Write-Host ""

# Flutter install command
flutter install --device-id=SM 2>&1 | ForEach-Object {
    Write-Host $_ -ForegroundColor Gray
    if ($_ -match "error|Error|ERROR|failed|Failed|FAILED") {
        Write-Host $_ -ForegroundColor Red
    }
}

Write-Host ""

# Alternative: Manual installation instructions
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "If installation still fails, try manually:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Option 1: Uninstall from device manually" -ForegroundColor Cyan
Write-Host "  1. Go to Settings > Apps on your device" -ForegroundColor Gray
Write-Host "  2. Find 'gen_confi' app" -ForegroundColor Gray
Write-Host "  3. Tap Uninstall" -ForegroundColor Gray
Write-Host "  4. Then run: flutter run" -ForegroundColor Gray
Write-Host ""
Write-Host "Option 2: Use ADB directly (if available)" -ForegroundColor Cyan
Write-Host "  1. Find ADB in: C:\src\flutter\bin\cache\artifacts\engine\android-x64\" -ForegroundColor Gray
Write-Host "  2. Run: adb uninstall $packageName" -ForegroundColor Gray
Write-Host "  3. Run: adb install $apkPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Option 3: Install APK manually on device" -ForegroundColor Cyan
Write-Host "  1. Copy APK to your device" -ForegroundColor Gray
Write-Host "  2. Open file manager on device" -ForegroundColor Gray
Write-Host "  3. Tap the APK file to install" -ForegroundColor Gray
Write-Host ""
Write-Host "Option 4: Check device settings" -ForegroundColor Cyan
Write-Host "  1. Enable 'Install via USB' in Developer Options" -ForegroundColor Gray
Write-Host "  2. Enable USB Debugging" -ForegroundColor Gray
Write-Host "  3. Allow USB debugging when prompted" -ForegroundColor Gray
Write-Host ""

