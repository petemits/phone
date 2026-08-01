# nPhoneKIT Download Script for Windows PowerShell

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "nPhoneKIT PowerShell Downloader" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$url = "https://github.com/nlckysolutions/nPhoneKIT/archive/refs/heads/main.zip"
$output = "nphonekit.zip"
$extractPath = "."

Write-Host "Downloading from: $url" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"

# Download with progress
Write-Host "Downloading nPhoneKIT..." -ForegroundColor Yellow
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($url, $output)
    Write-Host "✅ Download complete!" -ForegroundColor Green
}
catch {
    Write-Host "❌ Download failed: $_" -ForegroundColor Red
    exit 1
}

# Extract
Write-Host "Extracting files..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $output -DestinationPath $extractPath -Force
    Write-Host "✅ Extraction complete!" -ForegroundColor Green
}
catch {
    Write-Host "❌ Extraction failed: $_" -ForegroundColor Red
    exit 1
}

# Rename folder
if (Test-Path ".\nPhoneKIT-main") {
    if (Test-Path ".\nPhoneKIT") {
        Write-Host "Removing existing nPhoneKIT directory..." -ForegroundColor Yellow
        Remove-Item -Path ".\nPhoneKIT" -Recurse -Force
    }
    Write-Host "Renaming folder..." -ForegroundColor Yellow
    Rename-Item -Path ".\nPhoneKIT-main" -NewName "nPhoneKIT"
    Write-Host "✅ Rename complete!" -ForegroundColor Green
}

# Clean up
Remove-Item $output
Write-Host "✅ Cleaned up temporary files" -ForegroundColor Green

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🎉 nPhoneKIT successfully downloaded to 'nPhoneKIT\'" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan