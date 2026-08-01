# nPhoneKIT Download Script - WORKING VERSION
Write-Host "=================================================="
Write-Host "nPhoneKIT PowerShell Downloader"
Write-Host "=================================================="

$url = "https://github.com/nlckysolutions/nPhoneKIT/archive/refs/heads/main.zip"
$output = "nphonekit.zip"
$extractPath = "."

Write-Host "Downloading from: $url"
Write-Host "--------------------------------------------------"

# Download
Write-Host "Downloading nPhoneKIT..."
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($url, $output)
    Write-Host "Download complete!"
}
catch {
    Write-Host "Download failed: $_"
    exit 1
}

# Check if file exists
if (Test-Path $output) {
    $fileSize = (Get-Item $output).Length
    Write-Host "File size: $fileSize bytes"
    
    if ($fileSize -eq 0) {
        Write-Host "Downloaded file is empty!"
        Remove-Item $output -Force -ErrorAction SilentlyContinue
        exit 1
    }
}
else {
    Write-Host "File not found after download!"
    exit 1
}

# Extract using Shell.Application (most reliable on Windows)
Write-Host "Extracting files..."
try {
    $shell = New-Object -ComObject Shell.Application
    $zip = $shell.NameSpace((Get-Location).Path + "\" + $output)
    $destination = $shell.NameSpace((Get-Location).Path)
    $destination.CopyHere($zip.Items(), 16)
    
    # Wait for extraction to complete
    Write-Host "Waiting for extraction to complete..."
    Start-Sleep -Seconds 5
    
    Write-Host "Extraction complete!"
}
catch {
    Write-Host "Extraction failed: $_"
    exit 1
}

# Look for extracted folder
Write-Host "Looking for extracted folder..."
$extractedFolder = $null

# Check for common folder names
if (Test-Path ".\nPhoneKIT-main") {
    $extractedFolder = "nPhoneKIT-main"
    Write-Host "Found folder: nPhoneKIT-main"
}
elseif (Test-Path ".\nPhoneKIT-master") {
    $extractedFolder = "nPhoneKIT-master"
    Write-Host "Found folder: nPhoneKIT-master"
}
else {
    # Look for any folder containing "nPhoneKIT"
    $folders = Get-ChildItem -Path . -Directory | Where-Object { $_.Name -like "*nPhoneKIT*" }
    if ($folders.Count -gt 0) {
        $extractedFolder = $folders[0].Name
        Write-Host "Found folder: $extractedFolder"
    }
}

# Rename folder if found
if ($extractedFolder) {
    if (Test-Path ".\nPhoneKIT") {
        Write-Host "Removing existing nPhoneKIT directory..."
        Remove-Item -Path ".\nPhoneKIT" -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "Renaming folder to nPhoneKIT..."
    Rename-Item -Path $extractedFolder -NewName "nPhoneKIT" -ErrorAction SilentlyContinue
    
    if (Test-Path ".\nPhoneKIT") {
        Write-Host "Rename complete!"
    }
    else {
        Write-Host "Rename failed, but folder exists as: $extractedFolder"
    }
}
else {
    Write-Host "Could not find extracted folder!"
}

# Clean up
Write-Host "Cleaning up temporary files..."
Remove-Item $output -Force -ErrorAction SilentlyContinue
Write-Host "Cleanup complete!"

Write-Host "=================================================="
Write-Host "Process completed!"
Write-Host "=================================================="

# Show current directory contents
Write-Host ""
Write-Host "Current directory contents:"
Get-ChildItem -Path .