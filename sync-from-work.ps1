# sync-from-work.ps1
# Copies the latest scene1_palace.html + image assets from the work folder
# into this deploy repo. Run from THIS folder.
#
# USAGE:
#     .\sync-from-work.ps1            # syncs HTML + new images
#     .\sync-from-work.ps1 -ImagesToo # also re-copies ALL images (overwrites
#                                       any local compression — use sparingly)

param(
    [switch]$ImagesToo
)

$ErrorActionPreference = 'Stop'

$WorkFolder = "C:\Users\janer\OneDrive\Documents\Etsy main\Claude\Projects\Test project\files\Etsy moses - part 1-\Moses's deadly escape interactive"
$DeployFolder = $PSScriptRoot

if (-not (Test-Path $WorkFolder)) {
    Write-Host "ERROR: Work folder not found at $WorkFolder" -ForegroundColor Red
    exit 1
}

# 1) HTML files
$htmlFiles = @('scene1_palace.html', 'scene2_desert.html', 'index.html', 'manifest.json')
foreach ($name in $htmlFiles) {
    $src = Join-Path $WorkFolder $name
    $dst = Join-Path $DeployFolder $name
    if (Test-Path $src) {
        Copy-Item -Path $src -Destination $dst -Force
        Write-Host "Synced  $name" -ForegroundColor Green
    } else {
        Write-Host "Skipped $name (not in work folder)" -ForegroundColor Yellow
    }
}

# 2) Image assets — only NEW images by default. With -ImagesToo, mirror ALL.
$workImg   = Join-Path $WorkFolder   'assets\images'
$deployImg = Join-Path $DeployFolder 'assets\images'
if (-not (Test-Path $deployImg)) {
    New-Item -ItemType Directory -Path $deployImg -Force | Out-Null
}

if ($ImagesToo) {
    Write-Host "Copying ALL images (overwrite mode)..." -ForegroundColor Cyan
    robocopy $workImg $deployImg /MIR /NFL /NDL /NJH /NJS /NC /NS | Out-Null
    Write-Host "All images mirrored." -ForegroundColor Green
} else {
    Write-Host "Copying only NEW images (won't touch existing files)..." -ForegroundColor Cyan
    $count = 0
    Get-ChildItem -Path $workImg -Filter '*.png' -File | ForEach-Object {
        $dst = Join-Path $deployImg $_.Name
        if (-not (Test-Path $dst)) {
            Copy-Item -Path $_.FullName -Destination $dst -Force
            Write-Host "  + $($_.Name)" -ForegroundColor White
            $count++
        }
    }
    Write-Host "Synced $count new images." -ForegroundColor Green
}

# 3) AUDIO assets — same "new only" rule as images so Jane doesn't lose
#    any local audio she's hand-edited. 2026-05-17 PM40 (Jane: "i think
#    the newly added audio files are not synced on deploy folder. i saw
#    only new images being synced. but not the newly added audio").
#    Sync script was image-only; new mp3s (exit shut, power spell,
#    frozen, eat, etc.) never reached the deploy repo.
$workAud   = Join-Path $WorkFolder   'assets\audio'
$deployAud = Join-Path $DeployFolder 'assets\audio'
if (-not (Test-Path $deployAud)) {
    New-Item -ItemType Directory -Path $deployAud -Force | Out-Null
}
Write-Host "Copying only NEW audio (won't touch existing files)..." -ForegroundColor Cyan
$audCount = 0
Get-ChildItem -Path $workAud -Include '*.mp3','*.ogg','*.wav','*.m4a' -File -Recurse | ForEach-Object {
    $dst = Join-Path $deployAud $_.Name
    if (-not (Test-Path $dst)) {
        Copy-Item -Path $_.FullName -Destination $dst -Force
        Write-Host "  + $($_.Name)" -ForegroundColor White
        $audCount++
    }
}
Write-Host "Synced $audCount new audio files." -ForegroundColor Green

Write-Host ''
Write-Host 'NEXT STEPS:' -ForegroundColor Cyan
Write-Host '  1. (Optional) .\compress-images.ps1     # compress images for faster load' -ForegroundColor White
Write-Host '  2. git add -A' -ForegroundColor White
Write-Host '  3. git commit -m "sync latest scene1_palace.html"' -ForegroundColor White
Write-Host '  4. git push origin main' -ForegroundColor White
