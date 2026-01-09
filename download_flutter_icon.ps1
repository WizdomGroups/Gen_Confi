# PowerShell script to download Flutter icon
Write-Host "Downloading Flutter icon..."

$iconUrl = "https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59b1a48dca87.png"
$outputPath = "assets/images/flutter_icon.png"

# Create directory if it doesn't exist
$dir = Split-Path -Parent $outputPath
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

try {
    Invoke-WebRequest -Uri $iconUrl -OutFile $outputPath
    Write-Host "Flutter icon downloaded successfully to $outputPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Run: flutter pub run flutter_launcher_icons" -ForegroundColor Cyan
    Write-Host "2. Run: flutter clean" -ForegroundColor Cyan
    Write-Host "3. Rebuild your app" -ForegroundColor Cyan
} catch {
    Write-Host "Download failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please download manually:" -ForegroundColor Yellow
    Write-Host "1. Visit: https://flutter.dev/brand" -ForegroundColor Cyan
    Write-Host "2. Download Flutter logo PNG format, 1024x1024 size" -ForegroundColor Cyan
    Write-Host "3. Save as: assets/images/flutter_icon.png" -ForegroundColor Cyan
}
