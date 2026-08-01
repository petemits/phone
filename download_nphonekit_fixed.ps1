# nPhoneKIT Download Script - FIXED VERSION
# This script handles various filename issues and provides better error handling

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "nPhoneKIT PowerShell Downloader - FIXED VERSION" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

$url = "https://github.com/nlckysolutions/nPhoneKIT/archive/refs/heads/main.zip"
$output = "nphonekit_temp.zip"  # Changed filename to avoid confusion
$extractPath = "."

Write-Host "Downloading from: $url" -ForegroundColor Yellow
Write-Host "--------------------------------------------------"

# Download with progress
Write-Host "Downloading nPhoneKIT..." -ForegroundColor Yellow
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($url, $output)
    Write-Host "✅ Download complete!" -ForegroundColor Green
    
    # Verify file was downloaded and has content
    if (Test-Path $output) {
        $fileSize = (Get-Item $output).Length
        Write-Host "📁 File size: $fileSize bytes" -ForegroundColor Gray
        
        if ($fileSize -eq 0) {
            Write-Host "❌ Downloaded file is empty!" -ForegroundColor Red
            Remove-Item $output -Force -ErrorAction SilentlyContinue
            exit 1
        }
    }
}
catch {
    Write-Host "❌ Download failed: $_" -ForegroundColor Red
    exit 1
}

# Check if file exists before extraction
if (-not (Test-Path $output)) {
    Write-Host "❌ Error: File '$output' not found after download!" -ForegroundColor Red
    exit 1
}

# Try different extraction methods
Write-Host "Extracting files..." -ForegroundColor Yellow

# Method 1: Try Expand-Archive (PowerShell native)
try {
    Expand-Archive -Path $output -DestinationPath $extractPath -Force
    Write-Host "✅ Extraction complete (using Expand-Archive)!" -ForegroundColor Green
}
catch {
    Write-Host "⚠️ Expand-Archive failed, trying alternative method..." -ForegroundColor Yellow
    
    # Method 2: Try using .NET's ZipFile (more reliable)
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::OpenRead("$PWD\$output")
        $zip.Entries | ForEach-Object {
            $targetFile = Join-Path -Path $extractPath -ChildPath $_.FullName
            $targetDir = Split-Path -Path $targetFile -Parent
            
            # Create directory if it doesn't exist
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }
            
            # Extract file
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, $targetFile, $true)
        }
        $zip.Dispose()
        Write-Host "✅ Extraction complete (using .NET ZipFile)!" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ All extraction methods failed!" -ForegroundColor Red
        Write-Host "Error details: $_" -ForegroundColor Red
        exit 1
    }
}

# Look for the extracted folder (it might have different names)
Write-Host "Looking for extracted folder..." -ForegroundColor Yellow

$possibleFolders = @(
    "nPhoneKIT-main",
    "nPhoneKIT-main*",
    "*nPhoneKIT*"
)

$extractedFolder = $null
foreach ($pattern in $possibleFolders) {
    $folders = Get-ChildItem -Path . -Directory -Name | Where-Object { $_ -like $pattern }
    if ($folders) {
        $extractedFolder = $folders[0]
        Write-Host "✅ Found folder: $extractedFolder" -ForegroundColor Green
        break
    }
}

if ($extractedFolder) {
    # Rename folder
    if (Test-Path ".\nPhoneKIT") {
        Write-Host "Removing existing nPhoneKIT directory..." -ForegroundColor Yellow
        Remove-Item -Path ".\nPhoneKIT" -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "Renaming folder to 'nPhoneKIT'..." -ForegroundColor Yellow
    Rename-Item -Path $extractedFolder -NewName "nPhoneKIT" -ErrorAction SilentlyContinue
    
    if (Test-Path ".\nPhoneKIT") {
        Write-Host "✅ Rename complete!" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Rename failed, but folder '$extractedFolder' exists" -ForegroundColor Yellow
        Write-Host "   You can manually rename it to 'nPhoneKIT'" -ForegroundColor Yellow
    }
}
else {
    Write-Host "❌ Could not find extracted folder!" -ForegroundColor Red
    Write-Host "   Please check the current directory contents:" -ForegroundColor Yellow
    Get-ChildItem -Path . -Directory
}

# Clean up
Write-Host "Cleaning up temporary files..." -ForegroundColor Yellow
Remove-Item $output -Force -ErrorAction SilentlyContinue
Write-Host "✅ Cleanup complete!" -ForegroundColor Green

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🎉 Process completed!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan

# Show final directory contents
Write-Host "`nCurrent directory contents:" -ForegroundColor Cyan
Get-ChildItem -Path . | Format-Table Name, Length, LastWriteTime -AutoSize