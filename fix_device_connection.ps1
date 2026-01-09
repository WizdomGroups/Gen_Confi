# Script to fix device connection and install APK
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Fix Device Connection & Install APK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$packageName = "com.example.gen_confi"
$apkPath = "build\app\outputs\flutter-apk\app-debug.apk"
$adbPath = "C:\Users\QS-FAR-LT-0010\AppData\Local\Android\Sdk\platform-tools\adb.exe"

if (-not (Test-Path $adbPath)) {
    Write-Host "[ERROR] ADB not found at: $adbPath" -ForegroundColor Red
    Write-Host "Please install Android SDK Platform Tools" -ForegroundColor Yellow
    exit 1
}

Write-Host "Step 1: Restarting ADB server..." -ForegroundColor Yellow
& $adbPath kill-server 2>&1 | Out-Null
Start-Sleep -Seconds 2
& $adbPath start-server 2>&1 | Out-Null
Start-Sleep -Seconds 2
Write-Host "[OK] ADB server restarted" -ForegroundColor Green
Write-Host ""

Write-Host "Step 2: Checking devices..." -ForegroundColor Yellow
$devicesOutput = & $adbPath devices 2>&1 | Out-String
Write-Host $devicesOutput

$deviceOnline = $devicesOutput -match "\tdevice$" -and $devicesOutput -notmatch "offline|unauthorized"

if (-not $deviceOnline) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Device is offline or not authorized!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please do the following on your device:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Unlock your device" -ForegroundColor Cyan
    Write-Host "2. Check for 'Allow USB debugging?' popup and tap 'Allow'" -ForegroundColor Cyan
    Write-Host "3. Enable 'Install via USB' in Developer Options" -ForegroundColor Cyan
    Write-Host "4. Try unplugging and replugging the USB cable" -ForegroundColor Cyan
    Write-Host "5. Make sure USB debugging is enabled" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Then run this script again or run: flutter run" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "[OK] Device is online!" -ForegroundColor Green
Write-Host ""

Write-Host "Step 3: Uninstalling old app..." -ForegroundColor Yellow
$uninstallResult = & $adbPath uninstall $packageName 2>&1
if ($uninstallResult -match "Success") {
    Write-Host "[OK] App uninstalled successfully" -ForegroundColor Green
} elseif ($uninstallResult -match "not found|does not exist") {
    Write-Host "[OK] App not installed (this is fine)" -ForegroundColor Yellow
} else {
    Write-Host "[!] Uninstall result: $uninstallResult" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "Step 4: Installing new APK..." -ForegroundColor Yellow
if (-not (Test-Path $apkPath)) {
    Write-Host "[ERROR] APK not found. Building it..." -ForegroundColor Red
    flutter build apk --debug
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Failed to build APK" -ForegroundColor Red
        exit 1
    }
}

$installResult = & $adbPath install -r $apkPath 2>&1
$installOutput = $installResult | Out-String

if ($installOutput -match "Success") {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SUCCESS! APK installed successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now run: flutter run" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "Installation failed" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error details:" -ForegroundColor Yellow
    Write-Host $installOutput -ForegroundColor Red
    Write-Host ""
    Write-Host "Try these solutions:" -ForegroundColor Yellow
    Write-Host "1. Uninstall the app manually from device Settings > Apps" -ForegroundColor Cyan
    Write-Host "2. Enable 'Install via USB' in Developer Options" -ForegroundColor Cyan
    Write-Host "3. Check device has enough storage space" -ForegroundColor Cyan
    Write-Host "4. Try installing APK manually by copying to device" -ForegroundColor Cyan
}

