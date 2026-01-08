# Script to pull all debug import samples from Android emulator to local directory
# Usage: .\pull_debug_imports.ps1

$ADB_PATH = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$APP_ID = "com.example.cipher_app"
$REMOTE_DIR = "files/debug_imports"
$LOCAL_DIR = ".\debug_imports_local"

# Create local directory if it doesn't exist
if (!(Test-Path $LOCAL_DIR)) {
    New-Item -ItemType Directory -Path $LOCAL_DIR | Out-Null
}

# Get list of files from emulator
$fileList = & $ADB_PATH shell "run-as $APP_ID ls $REMOTE_DIR 2>&1"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error accessing remote directory"
    exit 1
}

# Filter and pull each .txt file
$files = $fileList -split "`n" | Where-Object { $_ -match "\.txt$" }

if ($files.Count -eq 0) {
    Write-Host "No import files found"
    exit 0
}

$successCount = 0

foreach ($file in $files) {
    $filename = $file.Trim()
    if ([string]::IsNullOrWhiteSpace($filename)) { continue }
    
    $localPath = Join-Path $LOCAL_DIR $filename
    
    try {
        # Pull file using cat and redirect to local file
        & $ADB_PATH shell "run-as $APP_ID cat $REMOTE_DIR/$filename" | `
            Out-File -FilePath $localPath -Encoding UTF8 -ErrorAction Stop
        
        # Remove the file in the emulator after successful pull
        & $ADB_PATH shell "run-as $APP_ID rm $REMOTE_DIR/$filename"
        $successCount++
    }
    catch {
        Write-Host "Error pulling: $filename"
    }
}

Write-Host "Pulled $successCount file(s) to $LOCAL_DIR"
