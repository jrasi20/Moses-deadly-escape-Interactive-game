# compress-images.ps1
# Bible Explorer Kids — image compression for Moses Deadly Escape Interactive
#
# Compresses every PNG under assets/images in-place using pngquant (lossy,
# ~70% smaller, visually identical at 88-95% quality). Skips files smaller
# than 60 KB — those are already lean.
#
# REQUIREMENTS
#   pngquant must be on PATH. Install ONE of these in PowerShell (admin):
#     winget install pngquant
#         -- OR --
#     choco install pngquant
#
# USAGE (from this folder, in PowerShell):
#     .\compress-images.ps1
#
# DRY-RUN (see what would change without writing):
#     .\compress-images.ps1 -DryRun
#
# After it completes, eyeball a few sprites — if any look bad, restore from
# the backup folder it creates (assets/images-original-backup/) before commit.

param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$ImageDir   = Join-Path $PSScriptRoot 'assets\images'
$BackupDir  = Join-Path $PSScriptRoot 'assets\images-original-backup'
$MinSizeKB  = 60      # skip files smaller than this (already lean)
$Quality    = '80-92' # pngquant quality range; 80 lower bound, 92 upper

if (-not (Test-Path $ImageDir)) {
    Write-Host "ERROR: $ImageDir not found." -ForegroundColor Red
    exit 1
}

# Verify pngquant is installed
try { $null = Get-Command pngquant -ErrorAction Stop }
catch {
    Write-Host "ERROR: pngquant not found on PATH." -ForegroundColor Red
    Write-Host "Install it first:  winget install pngquant" -ForegroundColor Yellow
    exit 1
}

# Make backup folder (one-time). If it already exists, skip — we never want
# to overwrite the original backup with already-compressed files.
if (-not (Test-Path $BackupDir)) {
    Write-Host "Creating backup at $BackupDir ..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
    Copy-Item -Path "$ImageDir\*" -Destination $BackupDir -Recurse -Force
    Write-Host "Backup complete." -ForegroundColor Green
} else {
    Write-Host "Backup folder already exists — skipping backup step." -ForegroundColor Yellow
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
        Write-Host ("DRY-RUN  {0,8} KB  {1}" -f $sizeKB, $f.Name)
        $totalAfter += $f.Length
        $compressed++
        continue
    }
    # pngquant --force overwrites the original; --skip-if-larger keeps the
    # original if compression would make it bigger (rare but happens on
    # already-optimal PNGs).
    & pngquant --force --skip-if-larger --quality=$Quality --strip --output $f.FullName -- $f.FullName 2>$null
    if (Test-Path $f.FullName) {
        $newSize = (Get-Item $f.FullName).Length
        $totalAfter += $newSize
        $savedKB    = [int](($f.Length - $newSize) / 1KB)
        $pct        = if ($f.Length -gt 0) { [int](100 - ($newSize * 100 / $f.Length)) } else { 0 }
        Write-Host ("  {0,8} KB -> {1,8} KB  (-{2,3}%)  {3}" -f $sizeKB, [int]($newSize/1KB), $pct, $f.Name)
        $compressed++
    }
}

$beforeMB = [math]::Round($totalBefore / 1MB, 1)
$afterMB  = [math]::Round($totalAfter  / 1MB, 1)
$savedMB  = [math]::Round(($totalBefore - $totalAfter) / 1MB, 1)
$pctTotal = if ($totalBefore -gt 0) { [int](100 - ($totalAfter * 100 / $totalBefore)) } else { 0 }

Write-Host ''
Write-Host '================================================================' -ForegroundColor Cyan
Write-Host ("BEFORE   {0,8} MB total" -f $beforeMB) -ForegroundColor White
Write-Host ("AFTER    {0,8} MB total" -f $afterMB)  -ForegroundColor White
Write-Host ("SAVED    {0,8} MB  ({1}%)" -f $savedMB, $pctTotal) -ForegroundColor Green
Write-Host ("Files    {0} compressed, {1} skipped (under {2} KB)" -f $compressed, $skipped, $MinSizeKB) -ForegroundColor White
Write-Host '================================================================' -ForegroundColor Cyan

if (-not $DryRun) {
    Write-Host ''
    Write-Host 'Backup of originals lives in:' -ForegroundColor Yellow
    Write-Host "  $BackupDir" -ForegroundColor Yellow
    Write-Host 'If any sprite looks bad, copy from there back to assets/images.' -ForegroundColor Yellow
    Write-Host ''
    Write-Host 'NEXT STEP — git add + commit + push:' -ForegroundColor Cyan
    Write-Host '  git add assets/images' -ForegroundColor White
    Write-Host '  git commit -m "compress images for faster mobile load"' -ForegroundColor White
    Write-Host '  git push origin main' -ForegroundColor White
}
