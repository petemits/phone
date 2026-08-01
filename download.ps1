# Complete nPhoneKIT Download Script
# Copy and paste this entire block into PowerShell

$folder = "C:\Users\user\phone"
$url = "https://github.com/nlckysolutions/nPhoneKIT/archive/refs/heads/main.zip"
$zipFile = "$folder\nphonekit.zip"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "nPhoneKIT Downloader" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Create folder if it doesn't exist
if (-not (Test-Path $folder)) {
    New-Item -ItemType Directory -Path $folder -Force
    Write-Host "Created folder: $folder" -ForegroundColor Yellow
}

# Navigate to folder
Set-Location $folder
Write-Host "Working directory: $(Get-Location)" -ForegroundColor Gray

# Download
Write-Host "`n[1/5] Downloading nPhoneKIT..." -ForegroundColor Green
try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($url, $zipFile)
    Write-Host "✓ Download complete" -ForegroundColor Green
}
catch {
    Write-Host "✗ Download failed: $_" -ForegroundColor Red
    exit 1
}

# Verify download
Write-Host "`n[2/5] Verifying download..." -ForegroundColor Green
$fileInfo = Get-Item $zipFile
Write-Host "File size: $($fileInfo.Length) bytes" -ForegroundColor Yellow

if ($fileInfo.Length -lt 1MB) {
    Write-Host "✗ File is too small - download may have failed" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Download verified" -ForegroundColor Green

# Extract
Write-Host "`n[3/5] Extracting files..." -ForegroundColor Green
try {
    Expand-Archive -Path $zipFile -DestinationPath $folder -Force
    Write-Host "✓ Extraction complete" -ForegroundColor Green
}
catch {
    Write-Host "✗ Extraction failed: $_" -ForegroundColor Red
    exit 1
}

# Rename folder
Write-Host "`n[4/5] Organizing files..." -ForegroundColor Green
if (Test-Path "$folder\nPhoneKIT-main") {
    if (Test-Path "$folder\nPhoneKIT") {
        Remove-Item "$folder\nPhoneKIT" -Recurse -Force
    }
    Rename-Item "$folder\nPhoneKIT-main" "nPhoneKIT"
    Write-Host "✓ Folder renamed to nPhoneKIT" -ForegroundColor Green
} else {
    Write-Host "⚠ Folder nPhoneKIT-main not found" -ForegroundColor Yellow
}

# Clean up
Remove-Item $zipFile -Force -ErrorAction SilentlyContinue
Write-Host "✓ Temporary files cleaned up" -ForegroundColor Green

# Final check
Write-Host "`n[5/5] Final verification..." -ForegroundColor Green
if (Test-Path "$folder\nPhoneKIT") {
    $fileCount = (Get-ChildItem "$folder\nPhoneKIT" -Recurse -File).Count
    Write-Host "✓ nPhoneKIT folder exists with $fileCount files" -ForegroundColor Green
} else {
    Write-Host "✗ nPhoneKIT folder not found!" -ForegroundColor Red
}

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "Download process complete!" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Show folder contents
Write-Host "`nCurrent directory contents:" -ForegroundColor Cyan
Get-ChildItem $folder