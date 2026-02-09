# Claude → Cursor Bridge Monitor
# Watches for new task files from Claude and displays them for approval

$requestDir = "claude-requests"
$responseDir = "cursor-responses"
$approvedDir = "approved"
$completedDir = "completed"

# Create directories if they don't exist
@($requestDir, $responseDir, $approvedDir, $completedDir) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ | Out-Null
    }
}

Write-Host "Monitoring $requestDir for new Claude requests..." -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

# Track processed files
$processedFiles = @{}

while ($true) {
    $files = Get-ChildItem -Path $requestDir -Filter "*.md" | Sort-Object LastWriteTime
    
    foreach ($file in $files) {
        $fileKey = $file.FullName
        
        if (-not $processedFiles.ContainsKey($fileKey)) {
            $content = Get-Content $file.FullName -Raw
            
            # Check if it's a valid task file
            if ($content -match "STATUS:\s*PENDING") {
                Write-Host "`n=== NEW TASK FROM CLAUDE ===" -ForegroundColor Green
                Write-Host "File: $($file.Name)" -ForegroundColor White
                Write-Host "Time: $($file.LastWriteTime)" -ForegroundColor Gray
                Write-Host ""
                Write-Host $content -ForegroundColor Yellow
                Write-Host ""
                
                $response = Read-Host "Approve this task? (y/n/skip)"
                
                if ($response -eq "y" -or $response -eq "Y") {
                    # Mark as approved
                    $newContent = $content -replace "STATUS:\s*PENDING", "STATUS: APPROVED"
                    $newContent | Set-Content $file.FullName
                    
                    # Move to approved folder
                    $approvedPath = Join-Path $approvedDir $file.Name
                    Move-Item $file.FullName $approvedPath -Force
                    
                    Write-Host "Task approved and moved to $approvedDir" -ForegroundColor Green
                    Write-Host "Notify Cursor AI to process: $approvedPath" -ForegroundColor Cyan
                }
                elseif ($response -eq "skip") {
                    $processedFiles[$fileKey] = $true
                    Write-Host "Skipped. Will not show again." -ForegroundColor Gray
                }
                else {
                    Write-Host "Task not approved." -ForegroundColor Red
                }
                
                $processedFiles[$fileKey] = $true
            }
        }
    }
    
    Start-Sleep -Seconds 5
}
