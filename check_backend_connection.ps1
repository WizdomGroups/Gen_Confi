# Script to check backend server connection
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Backend Connection Diagnostic" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://10.20.190.66:8000"
$healthEndpoint = "$baseUrl/health"
$apiBase = "$baseUrl/api/v1"

Write-Host "Checking backend server connection..." -ForegroundColor Yellow
Write-Host "Base URL: $baseUrl" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if server is running on localhost
Write-Host "Step 1: Checking localhost:8000..." -ForegroundColor Yellow
try {
    $localhostResponse = Invoke-WebRequest -Uri "http://localhost:8000/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "[OK] Server is running on localhost:8000" -ForegroundColor Green
    Write-Host "   Response: $($localhostResponse.Content)" -ForegroundColor Gray
} catch {
    Write-Host "[!] Server not running on localhost:8000" -ForegroundColor Yellow
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
}
Write-Host ""

# Step 2: Get current IP address
Write-Host "Step 2: Getting current IP address..." -ForegroundColor Yellow
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" } | Select-Object -ExpandProperty IPAddress
Write-Host "Your IP addresses:" -ForegroundColor Cyan
foreach ($ip in $ipAddresses) {
    Write-Host "  - $ip" -ForegroundColor Gray
}
Write-Host ""

# Step 3: Check configured IP
Write-Host "Step 3: Checking configured IP (10.20.190.66)..." -ForegroundColor Yellow
try {
    $configuredResponse = Invoke-WebRequest -Uri $healthEndpoint -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "[OK] Server is reachable at $baseUrl" -ForegroundColor Green
    Write-Host "   Response: $($configuredResponse.Content)" -ForegroundColor Gray
} catch {
    Write-Host "[!] Server NOT reachable at $baseUrl" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "This is why your app shows '[null] /auth/login' error!" -ForegroundColor Red
}
Write-Host ""

# Step 4: Test API endpoint
Write-Host "Step 4: Testing API endpoint..." -ForegroundColor Yellow
try {
    $apiResponse = Invoke-WebRequest -Uri "$apiBase/auth/login" -Method POST -ContentType "application/json" -Body '{"email":"test@test.com","password":"test"}' -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "[OK] API endpoint is reachable" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "[OK] API endpoint is reachable (401 is expected for invalid credentials)" -ForegroundColor Green
    } else {
        Write-Host "[!] API endpoint test failed" -ForegroundColor Yellow
        Write-Host "   Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Gray
    }
}
Write-Host ""

# Step 5: Recommendations
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Recommendations" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

$serverRunning = $false
try {
    $test = Invoke-WebRequest -Uri "http://localhost:8000/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
    $serverRunning = $true
} catch {
    $serverRunning = $false
}

if (-not $serverRunning) {
    Write-Host "1. Start the backend server:" -ForegroundColor Cyan
    Write-Host "   cd D:\Freelance\GenConfi\Gen_Confi_Backend" -ForegroundColor Gray
    Write-Host "   .\venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "2. Update API base URL in Flutter app:" -ForegroundColor Cyan
Write-Host "   File: gen_confi/lib/core/constants/api_constants.dart" -ForegroundColor Gray
Write-Host ""
if ($ipAddresses.Count -gt 0) {
    Write-Host "   Suggested IP addresses to try:" -ForegroundColor Yellow
    foreach ($ip in $ipAddresses) {
        Write-Host "   - http://$ip:8000/api/v1" -ForegroundColor Gray
    }
} else {
    Write-Host "   Use: http://10.0.2.2:8000/api/v1 (for Android emulator)" -ForegroundColor Gray
    Write-Host "   Or: http://YOUR_COMPUTER_IP:8000/api/v1 (for physical device)" -ForegroundColor Gray
}
Write-Host ""

Write-Host "3. Check Windows Firewall:" -ForegroundColor Cyan
Write-Host "   Make sure port 8000 is allowed for incoming connections" -ForegroundColor Gray
Write-Host ""

Write-Host "4. Verify device and computer are on the same network" -ForegroundColor Cyan
Write-Host ""

