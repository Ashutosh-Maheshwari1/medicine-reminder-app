# MediTrack AI - GitHub Release Upload Script
# This script creates a GitHub Release and uploads the pre-built APK
# Usage: Run this script after providing your GitHub PAT below

param(
    [string]$Token = $env:GITHUB_TOKEN,
    [string]$Version = "v1.0.0",
    [string]$Owner = "Ashutosh-Maheshwari1",
    [string]$Repo = "medicine-reminder-app",
    [string]$ApkPath = "build\app\outputs\flutter-apk\app-release.apk"
)

if (-not $Token) {
    Write-Host "ERROR: No GitHub token provided." -ForegroundColor Red
    Write-Host "Set GITHUB_TOKEN env variable or pass -Token parameter" -ForegroundColor Yellow
    exit 1
}

$headers = @{
    Authorization = "Bearer $Token"
    Accept        = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

Write-Host "`n=== MediTrack AI GitHub Release Script ===" -ForegroundColor Cyan
Write-Host "Repo    : $Owner/$Repo" -ForegroundColor White
Write-Host "Version : $Version" -ForegroundColor White
Write-Host "APK     : $ApkPath" -ForegroundColor White

# ── Step 1: Create the Release ────────────────────────────────────────────────
Write-Host "`n[1/3] Creating GitHub Release..." -ForegroundColor Yellow

$releaseBody = @{
    tag_name   = $Version
    name       = "MediTrack AI $Version"
    body       = "## 📱 MediTrack AI $Version`n`n### ⬇️ Download`nDownload the APK below and install it on your Android device.`n`n> **Note:** You may need to enable *Install from unknown sources* in your Android settings.`n`n### 🆕 What's New`n- Interactive animated app logo with pulse & particle burst on tap`n- Rotating dashed ring animation around logo`n- Glassmorphism logo design with blue-cyan gradient`n- Improved splash screen with clean animations`n- Bug fixes and performance improvements`n`n### 📋 Requirements`n- Android 6.0 (API 23) or higher`n- ~65 MB storage"
    draft      = $false
    prerelease = $false
} | ConvertTo-Json

try {
    $release = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/$Owner/$Repo/releases" `
        -Method POST `
        -Headers $headers `
        -Body $releaseBody `
        -ContentType "application/json"
    Write-Host "  Release created! ID: $($release.id)" -ForegroundColor Green
    Write-Host "  URL: $($release.html_url)" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 422) {
        Write-Host "  Release $Version already exists. Fetching existing..." -ForegroundColor Yellow
        $release = Invoke-RestMethod `
            -Uri "https://api.github.com/repos/$Owner/$Repo/releases/tags/$Version" `
            -Headers $headers
        Write-Host "  Found existing release ID: $($release.id)" -ForegroundColor Cyan
    } else {
        Write-Host "  ERROR creating release: $_" -ForegroundColor Red
        exit 1
    }
}

# ── Step 2: Upload the APK ────────────────────────────────────────────────────
Write-Host "`n[2/3] Uploading APK file..." -ForegroundColor Yellow

if (-not (Test-Path $ApkPath)) {
    Write-Host "  ERROR: APK not found at $ApkPath" -ForegroundColor Red
    exit 1
}

$apkBytes = [IO.File]::ReadAllBytes((Resolve-Path $ApkPath))
$apkName  = "MediTrack-AI-$Version.apk"
$uploadUrl = $release.upload_url -replace '\{.*\}', "?name=$apkName&label=$apkName"

Write-Host "  Uploading $([math]::Round($apkBytes.Length / 1MB, 1)) MB APK..." -ForegroundColor White

try {
    $uploadResult = Invoke-RestMethod `
        -Uri $uploadUrl `
        -Method POST `
        -Headers $headers `
        -Body $apkBytes `
        -ContentType "application/vnd.android.package-archive"
    Write-Host "  APK uploaded! Download URL:" -ForegroundColor Green
    Write-Host "  $($uploadResult.browser_download_url)" -ForegroundColor Cyan
} catch {
    Write-Host "  ERROR uploading APK: $_" -ForegroundColor Red
    exit 1
}

# ── Step 3: Done ──────────────────────────────────────────────────────────────
Write-Host "`n[3/3] All done!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Release Page : $($release.html_url)" -ForegroundColor White
Write-Host "APK Download : $($uploadResult.browser_download_url)" -ForegroundColor White
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "`nThe README 'Download APK' badge now works!" -ForegroundColor Green
