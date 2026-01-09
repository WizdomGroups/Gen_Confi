# Script to uninstall and reinstall the app
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Uninstall and Reinstall App" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$packageName = "com.example.gen_confi"
$apkPath = "build\app\outputs\flutter-apk\app-debug.apk"

# Step 1: Check devices
Write-Host "Step 1: Checking connected devices..." -ForegroundColor Yellow
flutter devices
Write-Host ""

# Step 2: Uninstall using Flutter
Write-Host "Step 2: Uninstalling app..." -ForegroundColor Yellow
Write-Host "Package: $packageName" -ForegroundColor Cyan

# Try to find and use Flutter's ADB
$flutterPath = "C:\src\flutter"
$possibleAdbPaths = @(
    "$flutterPath\bin\cache\artifacts\engine\android-x64\adb.exe",
    "$flutterPath\bin\cache\artifacts\engine\android-arm64\adb.exe",
    "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
)

$adbPath = $null
foreach ($path in $possibleAdbPaths) {
    if (Test-Path $path) {
        $adbPath = $path
        break
    }
}

if ($adbPath) {
    Write-Host "Found ADB at: $adbPath" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "Checking devices..." -ForegroundColor Yellow
    & $adbPath devices
    Write-Host ""
    
    Write-Host "Uninstalling app..." -ForegroundColor Yellow
    & $adbPath uninstall $packageName 2>&1 | ForEach-Object {
        if ($_ -match "Success") {
            Write-Host $_ -ForegroundColor Green
        } elseif ($_ -match "not found|does not exist") {
            Write-Host "[OK] App not installed (this is fine)" -ForegroundColor Yellow
        } else {
            Write-Host $_ -ForegroundColor Gray
        }
    }
    Write-Host ""
    
    Write-Host "Installing new APK..." -ForegroundColor Yellow
    if (Test-Path $apkPath) {
        & $adbPath install -r $apkPath 2>&1 | ForEach-Object {
            Write-Host $_ -ForegroundColor $(if ($_ -match "Success|success") { "Green" } else { "Gray" })
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "SUCCESS! App installed successfully!" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Red
            Write-Host "Installation failed" -ForegroundColor Red
            Write-Host "========================================" -ForegroundColor Red
            Write-Host ""
            Write-Host "Troubleshooting:" -ForegroundColor Yellow
            Write-Host "1. Make sure device is connected and USB debugging is enabled" -ForegroundColor Cyan
            Write-Host "2. Uninstall the app manually from device Settings > Apps" -ForegroundColor Cyan
            Write-Host "3. Enable 'Install via USB' in Developer Options" -ForegroundColor Cyan
            Write-Host "4. Try: adb kill-server && adb start-server" -ForegroundColor Cyan
        }
    } else {
        Write-Host "[ERROR] APK not found. Building it first..." -ForegroundColor Red
        flutter build apk --debug
    }
} else {
    Write-Host "[!] ADB not found in standard locations" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Manual installation steps:" -ForegroundColor Yellow
    Write-Host "1. Uninstall 'gen_confi' app from your device manually" -ForegroundColor Cyan
    Write-Host "2. Copy the APK to your device: $apkPath" -ForegroundColor Cyan
    Write-Host "3. Install it manually using a file manager" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "OR use Flutter:" -ForegroundColor Yellow
    Write-Host "1. Make sure device is connected via USB" -ForegroundColor Cyan
    Write-Host "2. Run: flutter run" -ForegroundColor Cyan
}

