# Process Approved Task from Claude
# Run this script to have Cursor AI process the next approved task

param(
    [string]$TaskFile = ""
)

$approvedDir = "approved"
$completedDir = "completed"
$responseDir = "cursor-responses"

if (-not (Test-Path $approvedDir)) {
    Write-Host "No approved directory found. Run monitor script first." -ForegroundColor Red
    exit
}

# If no file specified, get the oldest approved task
if ([string]::IsNullOrEmpty($TaskFile)) {
    $tasks = Get-ChildItem -Path $approvedDir -Filter "*.md" | Sort-Object LastWriteTime
    if ($tasks.Count -eq 0) {
        Write-Host "No approved tasks found." -ForegroundColor Yellow
        exit
    }
    $TaskFile = $tasks[0].FullName
    Write-Host "Processing: $($tasks[0].Name)" -ForegroundColor Cyan
}

if (-not (Test-Path $TaskFile)) {
    Write-Host "Task file not found: $TaskFile" -ForegroundColor Red
    exit
}

# Read the task
$taskContent = Get-Content $TaskFile -Raw

# Create a response file for Cursor AI
$taskName = [System.IO.Path]::GetFileNameWithoutExtension($TaskFile)
$responseFile = Join-Path $responseDir "response-$taskName.md"

Write-Host "`n=== TASK FOR CURSOR AI ===" -ForegroundColor Green
Write-Host $taskContent
Write-Host "`n=== END TASK ===" -ForegroundColor Green
Write-Host ""
Write-Host "Response will be written to: $responseFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "INSTRUCTIONS FOR CURSOR AI:" -ForegroundColor Yellow
Write-Host "1. Read the task file: $TaskFile" -ForegroundColor White
Write-Host "2. Implement the requirements" -ForegroundColor White
Write-Host "3. Write a summary to: $responseFile" -ForegroundColor White
Write-Host "4. After completion, move task to: $completedDir" -ForegroundColor White
Write-Host ""

# Mark task as processing
$processingContent = $taskContent -replace "STATUS:\s*APPROVED", "STATUS: PROCESSING"
$processingContent | Set-Content $TaskFile

Write-Host "Task marked as PROCESSING. Ready for Cursor AI to handle." -ForegroundColor Green
