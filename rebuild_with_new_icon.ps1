# Complete script to rebuild APK with new icon
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Rebuilding APK with New Icon" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Cleaning build cache..." -ForegroundColor Yellow
flutter clean
Write-Host ""

Write-Host "Step 2: Getting dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host ""

Write-Host "Step 3: Removing old APK if exists..." -ForegroundColor Yellow
Remove-Item "build\app\outputs\flutter-apk\*.apk" -Force -ErrorAction SilentlyContinue
Write-Host ""

Write-Host "Step 4: Building new APK..." -ForegroundColor Yellow
Write-Host "IMPORTANT: Make sure to UNINSTALL the old app from your device first!" -ForegroundColor Red
Write-Host ""
flutter build apk --release
Write-Host ""

if ($LASTEXITCODE -eq 0) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SUCCESS! APK built with new icon" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "APK Location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. UNINSTALL the old app from your device" -ForegroundColor Red
    Write-Host "2. Install the new APK: adb install build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
    Write-Host "   OR copy the APK to your device and install manually" -ForegroundColor Cyan
} else {
    Write-Host "Build failed. Check errors above." -ForegroundColor Red
}

