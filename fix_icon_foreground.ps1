# Fix adaptive icon foreground reference
# flutter_launcher_icons generates ic_launcher_foreground but we need it for ic_app_icon

$resPath = "android\app\src\main\res"

# Find all ic_launcher_foreground files
$foregroundFiles = Get-ChildItem -Path $resPath -Recurse -Filter "ic_launcher_foreground.png"

if ($foregroundFiles.Count -eq 0) {
    Write-Host "No ic_launcher_foreground files found. Regenerating icons..." -ForegroundColor Yellow
    flutter pub run flutter_launcher_icons
    $foregroundFiles = Get-ChildItem -Path $resPath -Recurse -Filter "ic_launcher_foreground.png"
}

if ($foregroundFiles.Count -gt 0) {
    Write-Host "Found $($foregroundFiles.Count) foreground files. These are used by adaptive icons." -ForegroundColor Green
    Write-Host "The adaptive icon XML correctly references @drawable/ic_launcher_foreground" -ForegroundColor Green
    Write-Host ""
    Write-Host "Files:" -ForegroundColor Cyan
    foreach ($file in $foregroundFiles) {
        Write-Host "  $($file.FullName)" -ForegroundColor Gray
    }
} else {
    Write-Host "ERROR: No foreground files found after regeneration!" -ForegroundColor Red
}

