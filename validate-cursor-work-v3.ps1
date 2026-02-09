# Validate Cursor Work - Version 3
# Skip file content to avoid encoding issues

param(
    [string]$TaskFile = "",
    [string]$ApiKey = $env:ANTHROPIC_API_KEY
)

$approvedDir = "approved"
$responseDir = "cursor-responses"
$validationDir = "validation-reports"

if (-not (Test-Path $validationDir)) {
    New-Item -ItemType Directory -Path $validationDir | Out-Null
}

if ([string]::IsNullOrEmpty($ApiKey)) {
    Write-Host "ERROR: ANTHROPIC_API_KEY not found" -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrEmpty($TaskFile)) {
    $tasks = Get-ChildItem -Path $approvedDir -Filter "*.md" | Where-Object {
        $content = Get-Content $_.FullName -Raw
        $content -match "STATUS:\s*PROCESSING"
    } | Sort-Object LastWriteTime
    
    if ($tasks.Count -eq 0) {
        Write-Host "No tasks with STATUS: PROCESSING found." -ForegroundColor Yellow
        exit 0
    }
    
    $TaskFile = $tasks[0].FullName
    Write-Host "Validating: $($tasks[0].Name)" -ForegroundColor Cyan
}

$taskName = [System.IO.Path]::GetFileNameWithoutExtension((Split-Path $TaskFile -Leaf))
$responseFile = Join-Path $responseDir "response-$taskName.md"
$validationFile = Join-Path $validationDir "validation-$taskName.md"

if (-not (Test-Path $responseFile)) {
    Write-Host "ERROR: Response file not found: $responseFile" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== STARTING VALIDATION ===" -ForegroundColor Green

# Read files with UTF-8 encoding explicitly
$taskContent = Get-Content $TaskFile -Raw -Encoding UTF8
$responseContent = Get-Content $responseFile -Raw -Encoding UTF8

# Simple prompt without file contents
$prompt = "You are validating a coding task. Review the requirements and implementation response.

ORIGINAL TASK:
$taskContent

CURSOR'S RESPONSE:
$responseContent

Provide a validation report with:
1. Overall Status: PASS, FAIL, or ADVISORY
2. Check each MUST/SHOULD/COULD requirement against what Cursor reported
3. Note: You cannot see the actual code files, so validate based on Cursor's self-reported implementation

Format as markdown with clear sections."

Write-Host "Calling API Claude..." -ForegroundColor Cyan

$requestBody = @{
    model = "claude-sonnet-4-20250514"
    max_tokens = 3000
    messages = @(
        @{
            role = "user"
            content = $prompt
        }
    )
}

$jsonBody = $requestBody | ConvertTo-Json -Depth 5

$headers = @{
    "x-api-key" = $ApiKey
    "anthropic-version" = "2023-06-01"
    "content-type" = "application/json; charset=utf-8"
}

try {
    $response = Invoke-RestMethod -Uri "https://api.anthropic.com/v1/messages" -Method Post -Headers $headers -Body ([System.Text.Encoding]::UTF8.GetBytes($jsonBody))
    
    $validationReport = $response.content[0].text
    
    $validationReport | Set-Content $validationFile -Encoding UTF8
    
    Write-Host ""
    Write-Host "=== VALIDATION COMPLETE ===" -ForegroundColor Green
    Write-Host ""
    Write-Host $validationReport
    Write-Host ""
    Write-Host "Report saved to: $validationFile" -ForegroundColor Cyan
    
    if ($validationReport -match "Status:\s*(PASS|FAIL|ADVISORY)") {
        $status = $Matches[1]
        Write-Host ""
        Write-Host "Result: $status" -ForegroundColor $(if($status -eq "PASS"){"Green"}elseif($status -eq "FAIL"){"Red"}else{"Yellow"})
    }
    
} catch {
    Write-Host "ERROR calling API:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    if ($_.ErrorDetails.Message) {
        Write-Host "Details: $($_.ErrorDetails.Message)" -ForegroundColor Red
    }
    exit 1
}
