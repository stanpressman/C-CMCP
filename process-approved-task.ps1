# Process Approved Task from Claude
# Run this script to have Cursor AI process the next approved task

param(
    [string]$TaskFile = ""
)

$approvedDir  = Join-Path $PSScriptRoot "approved"
$completedDir = Join-Path $PSScriptRoot "completed"
$responseDir  = Join-Path $PSScriptRoot "cursor-responses"

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
$instructions = @"
INSTRUCTIONS FOR CURSOR AI:
1. Read the Task File: $TaskFile
2. Implement the requirements
3. Write a summary to: $responseFile
4. After completion, leave the task in: $approvedDir 

Complete, endpoint-to-endpoint, production-ready, UI installed (if requested) and connected implementation. No TODOs, no placeholders, no 'implement later' comments. Full error handling, logging, and validation (if needed or requested). If you can't fit it all, tell me and I'll split the prompt, but whatever you deliver must be 100% functional from the user's viewpoint.

Do not change the status in the Task File.  Do not move the Task File.
"@
Write-Host $instructions
Set-Clipboard -value $instructions


# Mark task as processing
$processingContent = $taskContent -replace "STATUS:\s*APPROVED", "STATUS: PROCESSING"
$processingContent | Set-Content $TaskFile

Write-Host "Task marked as PROCESSING. Ready for Cursor AI to handle." -ForegroundColor Green
