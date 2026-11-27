# prepare_deploy.ps1
#
# Prepares build/web for manual upload (FileZilla / cPanel).
#
# Why this exists: `flutter build web` emits debug symbol files (*.symbols)
# totalling roughly 4 MB. They are never fetched at runtime -- they only
# symbolicate stack traces -- so we drop them before upload to save upload
# time and server space.
#
# Usage:
#   flutter build web --release --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false --no-tree-shake-icons --base-href /
#   powershell -File tool/prepare_deploy.ps1
#   upload the CONTENTS of build/deploy/ into the web root on the server
#
# This script never touches build/web/ -- it always works on a copy.
#
# NOTE: this file MUST stay ASCII-only. Windows PowerShell reads .ps1 as
# ANSI unless the file carries a UTF-8 BOM, which corrupts any non-ASCII
# text and breaks the parser. Keep comments and strings in English here.

$ErrorActionPreference = 'Stop'

$src = Join-Path $PSScriptRoot '..\build\web'
$dst = Join-Path $PSScriptRoot '..\build\deploy'

if (-not (Test-Path $src)) {
    Write-Error "Not found: $src - run 'flutter build web --release --dart-define=BROWSER_IMAGE_DECODING_ENABLED=false --no-tree-shake-icons --base-href /' first"
    exit 1
}

if (-not (Test-Path (Join-Path $src 'main.dart.js'))) {
    Write-Error "$src looks incomplete (no main.dart.js) - rebuild first"
    exit 1
}

Write-Host "Copying $src -> $dst"
if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
Copy-Item $src $dst -Recurse

$beforeSize = (Get-ChildItem $dst -Recurse -File | Measure-Object -Property Length -Sum).Sum

# Debug symbols are never fetched at runtime.
$symbols = Get-ChildItem $dst -Recurse -File -Filter '*.symbols'
$symbolsSize = ($symbols | Measure-Object -Property Length -Sum).Sum
if ($symbols.Count -gt 0) {
    Write-Host ("Dropping {0} *.symbols files (-{1} MB)" -f $symbols.Count, [math]::Round($symbolsSize / 1MB, 2))
    $symbols | Remove-Item -Force
}

# Service worker is disabled (see web/index.html + web/.htaccess); Flutter no
# longer generates this file. If an old copy is on the server, delete it there
# too -- browsers that already registered it will keep trying to fetch it.
$sw = Join-Path $dst 'flutter_service_worker.js'
if (Test-Path $sw) {
    Write-Host 'Dropping flutter_service_worker.js (service worker is disabled)'
    Remove-Item $sw -Force
}

# version.json is only used together with the service worker.
$versionJson = Join-Path $dst 'version.json'
if (Test-Path $versionJson) {
    Write-Host 'Dropping version.json (only used with the service worker)'
    Remove-Item $versionJson -Force
}

# Remove empty directories left behind by pruned assets. Repeat until stable:
# removing an inner directory can make its parent empty too.
$removedDirs = 0
do {
    $empty = @(Get-ChildItem $dst -Recurse -Directory | Where-Object {
        @(Get-ChildItem $_.FullName -Recurse -File -Force).Count -eq 0
    })
    foreach ($d in $empty) {
        Remove-Item $d.FullName -Recurse -Force
        $removedDirs++
    }
} while ($empty.Count -gt 0)

if ($removedDirs -gt 0) {
    Write-Host "Removed $removedDirs empty directories"
}

$afterSize = (Get-ChildItem $dst -Recurse -File | Measure-Object -Property Length -Sum).Sum

Write-Host ''
Write-Host '===== Summary ====='
Write-Host ("Before : {0} MB" -f [math]::Round($beforeSize / 1MB, 2))
Write-Host ("After  : {0} MB" -f [math]::Round($afterSize / 1MB, 2))
Write-Host ("Saved  : {0} MB" -f [math]::Round(($beforeSize - $afterSize) / 1MB, 2))
Write-Host ''
Write-Host ("Ready to upload: " + (Resolve-Path $dst).Path)
Write-Host 'Upload the CONTENTS of that folder into the web root on the server.'
Write-Host ''
Write-Host 'Reminder: if flutter_service_worker.js still exists on the server, delete it there.'
