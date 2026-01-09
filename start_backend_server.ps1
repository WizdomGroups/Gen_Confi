# Script to start backend server with correct network binding
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Backend Server" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$backendPath = "D:\Freelance\GenConfi\Gen_Confi_Backend"

if (-not (Test-Path $backendPath)) {
    Write-Host "[ERROR] Backend directory not found: $backendPath" -ForegroundColor Red
    exit 1
}

Write-Host "Backend Path: $backendPath" -ForegroundColor Cyan
Write-Host ""

# Check if server is already running
Write-Host "Checking if server is already running..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
    Write-Host "[!] Server is already running on localhost:8000" -ForegroundColor Yellow
    Write-Host "   Response: $($response.Content)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "IMPORTANT: Make sure the server was started with --host 0.0.0.0" -ForegroundColor Red
    Write-Host "   If not, stop it (Ctrl+C) and restart with this script" -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit 0
    }
} catch {
    Write-Host "[OK] Server is not running. Starting it..." -ForegroundColor Green
}

Write-Host ""
Write-Host "Starting server with network binding (--host 0.0.0.0)..." -ForegroundColor Yellow
Write-Host "This allows connections from your device on the same network." -ForegroundColor Cyan
Write-Host ""

Push-Location $backendPath

# Activate virtual environment and start server
Write-Host "Activating virtual environment..." -ForegroundColor Yellow
if (Test-Path ".\venv\Scripts\Activate.ps1") {
    & ".\venv\Scripts\Activate.ps1"
} else {
    Write-Host "[ERROR] Virtual environment not found!" -ForegroundColor Red
    Write-Host "Please create it first: python -m venv venv" -ForegroundColor Yellow
    Pop-Location
    exit 1
}

Write-Host ""
Write-Host "Starting uvicorn server..." -ForegroundColor Yellow
Write-Host "Server will be accessible at:" -ForegroundColor Cyan
Write-Host "  - http://localhost:8000 (on this computer)" -ForegroundColor Gray
Write-Host "  - http://YOUR_IP:8000 (from devices on same network)" -ForegroundColor Gray
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Start server with network binding
& ".\venv\Scripts\python.exe" -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

Pop-Location

