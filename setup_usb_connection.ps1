# Script to setup USB connection for Flutter app
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "USB Connection Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$adbPath = "C:\Users\QS-FAR-LT-0010\AppData\Local\Android\Sdk\platform-tools\adb.exe"

if (-not (Test-Path $adbPath)) {
    Write-Host "[ERROR] ADB not found at: $adbPath" -ForegroundColor Red
    Write-Host "Please install Android SDK Platform Tools" -ForegroundColor Yellow
    exit 1
}

Write-Host "Step 1: Checking device connection..." -ForegroundColor Yellow
$devices = & $adbPath devices
Write-Host $devices

$deviceConnected = $devices -match "device$" -and $devices -notmatch "List|offline|unauthorized"

if (-not $deviceConnected) {
    Write-Host ""
    Write-Host "[ERROR] No device connected or device not authorized!" -ForegroundColor Red
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Connect your phone via USB" -ForegroundColor Cyan
    Write-Host "2. Enable USB debugging on your phone" -ForegroundColor Cyan
    Write-Host "3. Allow USB debugging when prompted" -ForegroundColor Cyan
    exit 1
}

Write-Host "[OK] Device connected" -ForegroundColor Green
Write-Host ""

Write-Host "Step 2: Setting up ADB port forwarding..." -ForegroundColor Yellow
Write-Host "This allows your app to use 'localhost:8000' to reach the backend server" -ForegroundColor Cyan
Write-Host ""

# Remove existing port forwarding for port 8000
& $adbPath reverse --remove tcp:8000 2>&1 | Out-Null

# Set up new port forwarding
Write-Host "Forwarding localhost:8000 (phone) -> localhost:8000 (computer)..." -ForegroundColor Yellow
$forwardResult = & $adbPath reverse tcp:8000 tcp:8000 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Port forwarding set up successfully!" -ForegroundColor Green
} else {
    Write-Host "[!] Port forwarding setup had issues" -ForegroundColor Yellow
    Write-Host $forwardResult
}

Write-Host ""

Write-Host "Step 3: Verifying port forwarding..." -ForegroundColor Yellow
$reverseList = & $adbPath reverse --list
Write-Host $reverseList

if ($reverseList -match "tcp:8000") {
    Write-Host "[OK] Port forwarding is active" -ForegroundColor Green
} else {
    Write-Host "[!] Port forwarding verification failed" -ForegroundColor Yellow
}

Write-Host ""

Write-Host "Step 4: Checking backend server..." -ForegroundColor Yellow
try {
    $serverResponse = Invoke-WebRequest -Uri "http://localhost:8000/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "[OK] Backend server is running on localhost:8000" -ForegroundColor Green
    Write-Host "   Response: $($serverResponse.Content)" -ForegroundColor Gray
} catch {
    Write-Host "[!] Backend server is NOT running on localhost:8000" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Please start the backend server:" -ForegroundColor Yellow
    Write-Host "   cd D:\Freelance\GenConfi\Gen_Confi_Backend" -ForegroundColor Cyan
    Write-Host "   .\venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   OR run: cd D:\Freelance\GenConfi\gen_confi; .\start_backend_server.ps1" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your Flutter app is now configured to use:" -ForegroundColor Cyan
Write-Host "   http://localhost:8000/api/v1" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Make sure backend server is running (see above)" -ForegroundColor Gray
Write-Host "2. Hot restart your Flutter app (press 'R' in flutter run)" -ForegroundColor Gray
Write-Host "3. Try logging in again" -ForegroundColor Gray
Write-Host ""

