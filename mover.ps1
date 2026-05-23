# Move processed files to /completed and group by base task name

$base      = $PSScriptRoot
$completed = Join-Path $base "completed"

if (-not (Test-Path $completed)) {
    New-Item -ItemType Directory -Path $completed | Out-Null
}

$sources = @("approved", "cursor-responses", "validation-reports")
$moved   = 0

# Phase 1: Move all files into /completed
foreach ($folder in $sources) {
    $src = Join-Path $base $folder
    if (-not (Test-Path $src)) { continue }

    Get-ChildItem -Path $src -File | ForEach-Object {
        Move-Item $_.FullName -Destination $completed -Force
        Write-Host "Moved: $($_.Name)  [$folder]" -ForegroundColor Cyan
        $moved++
    }
}

Write-Host "`n$moved file(s) archived to /completed." -ForegroundColor Green

# Phase 2: Group files into subfolders by base task name
$prefixes = @("response-", "validation-", "task-")

Get-ChildItem -Path $completed -File | ForEach-Object {
    $name     = $_.BaseName
    $baseName = $name

    foreach ($prefix in $prefixes) {
        if ($name.StartsWith($prefix)) {
            $baseName = $name.Substring($prefix.Length)
            break
        }
    }

    $subFolder = Join-Path $completed $baseName
    if (-not (Test-Path $subFolder)) {
        New-Item -ItemType Directory -Path $subFolder | Out-Null
        Write-Host "Created folder: $baseName" -ForegroundColor Yellow
    }

    Move-Item $_.FullName -Destination $subFolder -Force
    Write-Host "  -> $($_.Name)" -ForegroundColor Cyan
}

Write-Host "`nGrouping complete." -ForegroundColor Green
