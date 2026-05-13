# compress-images.ps1
# Bible Explorer Kids - image compression for Moses Deadly Escape Interactive
#
# Compresses every PNG under assets/images in-place using pngquant (lossy,
# ~70% smaller, visually identical at 88-95% quality). Skips files smaller
# than 60 KB - those are already lean.
#
# REQUIREMENTS
#   pngquant.exe must be (1) in this folder, (2) in tools\, or (3) on PATH.
#   See SETUP_FIRST_TIME.md for install steps.
#
# USAGE (from this folder, in PowerShell):
#     .\compress-images.ps1
#
# DRY-RUN (see what would change without writing):
#     .\compress-images.ps1 -DryRun

param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$ImageDir   = Join-Path $PSScriptRoot 'assets\images'
$BackupDir  = Join-Path $PSScriptRoot 'assets\images-original-backup'
$MinSizeKB  = 60
$Quality    = '80-92'

if (-not (Test-Path $ImageDir)) {
    Write-Host "ERROR: $ImageDir not found." -ForegroundColor Red
    exit 1
}

# Locate pngquant - check (1) local folder, (2) tools subfolder, (3) PATH.
$pngquantExe = $null
$localExe = Join-Path $PSScriptRoot 'pngquant.exe'
$toolsExe = Join-Path $PSScriptRoot 'tools\pngquant.exe'
if (Test-Path $localExe) {
    $pngquantExe = $localExe
} elseif (Test-Path $toolsExe) {
    $pngquantExe = $toolsExe
} else {
    try {
        $cmd = Get-Command pngquant -ErrorAction Stop
        $pngquantExe = $cmd.Source
    } catch {
        Write-Host "ERROR: pngquant.exe not found." -ForegroundColor Red
        Write-Host ""
        Write-Host "Install steps (no admin needed):" -ForegroundColor Yellow
        Write-Host "  1. Open https://pngquant.org/" -ForegroundColor White
        Write-Host "  2. Download the Windows zip" -ForegroundColor White
        Write-Host "  3. Extract pngquant.exe into THIS folder:" -ForegroundColor White
        Write-Host "       $PSScriptRoot" -ForegroundColor Cyan
        Write-Host "  4. Re-run .\compress-images.ps1" -ForegroundColor White
        exit 1
    }
}
Write-Host "Using pngquant: $pngquantExe" -ForegroundColor Cyan

# One-time backup
if (-not (Test-Path $BackupDir)) {
    Write-Host "Creating backup at $BackupDir ..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
    Copy-Item -Path "$ImageDir\*" -Destination $BackupDir -Recurse -Force
    Write-Host "Backup complete." -ForegroundColor Green
} else {
    Write-Host "Backup folder already exists - skipping backup step." -ForegroundColor Yellow
}

$files = Get-ChildItem -Path $ImageDir -Filter '*.png' -File
$totalBefore = 0
$totalAfter  = 0
$skipped     = 0
$compressed  = 0

foreach ($f in $files) {
    $sizeKB = [int]($f.Length / 1KB)
    $totalBefore += $f.Length
    if ($sizeKB -lt $MinSizeKB) {
        $skipped++
        $totalAfter += $f.Length
        continue
    }
    if ($DryRun) {
        Write-Host ("DRY-RUN  " + $sizeKB + " KB  " + $f.Name)
        $totalAfter += $f.Length
        $compressed++
        continue
    }
    & $pngquantExe --force --skip-if-larger --quality=$Quality --strip --output $f.FullName -- $f.FullName 2>$null
    if (Test-Path $f.FullName) {
        $newSize = (Get-Item $f.FullName).Length
        $totalAfter += $newSize
        $newKB   = [int]($newSize / 1KB)
        $savedKB = $sizeKB - $newKB
        $pct = 0
        if ($f.Length -gt 0) {
            $pct = [int](100 - ($newSize * 100 / $f.Length))
        }
        Write-Host ("  " + $sizeKB + " KB -> " + $newKB + " KB  (-" + $pct + "%)  " + $f.Name)
        $compressed++
    }
}

$beforeMB = [math]::Round($totalBefore / 1MB, 1)
$afterMB  = [math]::Round($totalAfter  / 1MB, 1)
$savedMB  = [math]::Round(($totalBefore - $totalAfter) / 1MB, 1)
$pctTotal = 0
if ($totalBefore -gt 0) {
    $pctTotal = [int](100 - ($totalAfter * 100 / $totalBefore))
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ("BEFORE   " + $beforeMB + " MB total") -ForegroundColor White
Write-Host ("AFTER    " + $afterMB  + " MB total") -ForegroundColor White
Write-Host ("SAVED    " + $savedMB  + " MB  (" + $pctTotal + " percent)") -ForegroundColor Green
Write-Host ("Files    " + $compressed + " compressed, " + $skipped + " skipped (under " + $MinSizeKB + " KB)") -ForegroundColor White
Write-Host "================================================================" -ForegroundColor Cyan

if (-not $DryRun) {
    Write-Host ""
    Write-Host "Backup of originals lives in:" -ForegroundColor Yellow
    Write-Host "  $BackupDir" -ForegroundColor Yellow
    Write-Host "If any sprite looks bad, copy from there back to assets/images." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "NEXT STEP - git add + commit + push:" -ForegroundColor Cyan
    Write-Host "  git add assets/images" -ForegroundColor White
    Write-Host "  git commit -m 'compress images for faster mobile load'" -ForegroundColor White
    Write-Host "  git push origin main" -ForegroundColor White
}
