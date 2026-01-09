# Script to help force a hot restart
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Force Hot Restart Instructions" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "The app is still using the old IP address because:" -ForegroundColor Yellow
Write-Host "  - DioClient is cached by Riverpod Provider" -ForegroundColor Gray
Write-Host "  - Hot reload doesn't recreate providers" -ForegroundColor Gray
Write-Host "  - Only HOT RESTART will fix this" -ForegroundColor Gray
Write-Host ""

Write-Host "SOLUTION: In your Flutter terminal, press:" -ForegroundColor Green
Write-Host ""
Write-Host "  R  (capital R - for Hot Restart)" -ForegroundColor Cyan
Write-Host ""
Write-Host "NOT lowercase 'r' (that's just hot reload)" -ForegroundColor Yellow
Write-Host ""

Write-Host "After hot restart, you should see in the logs:" -ForegroundColor Yellow
Write-Host "  📱 [ApiConstants] Android detected - Using: http://localhost:8000/api/v1" -ForegroundColor Gray
Write-Host "  🔧 [DioClient] Initializing with baseUrl: http://localhost:8000/api/v1" -ForegroundColor Gray
Write-Host ""

Write-Host "If you still see 10.20.190.66, the hot restart didn't work." -ForegroundColor Red
Write-Host "Try stopping the app completely and restarting:" -ForegroundColor Yellow
Write-Host "  1. Press 'q' to quit Flutter" -ForegroundColor Cyan
Write-Host "  2. Run: flutter run" -ForegroundColor Cyan
Write-Host ""

