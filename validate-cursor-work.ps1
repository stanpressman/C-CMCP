# Validate Cursor Work - Version 2
# Simplified API call handling

param(
    [string]$TaskFile = "",
    [string]$ApiKey = $env:ANTHROPIC_API_KEY
)

$approvedDir = "approved"
$responseDir = "cursor-responses"
$validationDir = "validation-reports"

# Create validation directory if it doesn't exist
if (-not (Test-Path $validationDir)) {
    New-Item -ItemType Directory -Path $validationDir | Out-Null
}

# Check for API key
if ([string]::IsNullOrEmpty($ApiKey)) {
    Write-Host "ERROR: ANTHROPIC_API_KEY not found" -ForegroundColor Red
    exit 1
}

# Find task file
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

# Get file paths
$taskName = [System.IO.Path]::GetFileNameWithoutExtension((Split-Path $TaskFile -Leaf))
$responseFile = Join-Path $responseDir "response-$taskName.md"
$validationFile = Join-Path $validationDir "validation-$taskName.md"

# Check files exist
if (-not (Test-Path $responseFile)) {
    Write-Host "ERROR: Response file not found: $responseFile" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== STARTING VALIDATION ===" -ForegroundColor Green

# Read files
$taskContent = Get-Content $TaskFile -Raw
$responseContent = Get-Content $responseFile -Raw

# Read modified files
$modifiedFilesContent = ""
if ($responseContent -match '## Files Modified\s+([\s\S]*?)(?=##|$)') {
    $filesSection = $Matches[1]
    $fileMatches = [regex]::Matches($filesSection, '`([^`]+)`')
    foreach ($match in $fileMatches) {
        $filePath = $match.Groups[1].Value
        if (Test-Path $filePath) {
            $fileContent = Get-Content $filePath -Raw
            $modifiedFilesContent += "`n## File: $filePath`n``````n$fileContent`n```````n"
        }
    }
}

# Build prompt - using here-string carefully
$prompt = @"
You are validating a coding task. Review the original task, the implementation response, and the actual code files.

ORIGINAL TASK:
$taskContent

CURSOR'S RESPONSE:
$responseContent

MODIFIED FILES:
$modifiedFilesContent

Provide a validation report with:
1. Overall Status: PASS, FAIL, or ADVISORY
2. Check each MUST/SHOULD/COULD requirement
3. List any critical issues (blocking)
4. List any advisory issues (non-blocking)

Format your response as a structured markdown report.
"@

Write-Host "Calling API Claude..." -ForegroundColor Cyan

# Build request using hashtable (safer than here-string for JSON)
$requestBody = @{
    model = "claude-sonnet-4-20250514"
    max_tokens = 4000
    messages = @(
        @{
            role = "user"
            content = $prompt
        }
    )
}

# Convert to JSON with proper escaping
$jsonBody = $requestBody | ConvertTo-Json -Depth 5 -Compress

# Make API call
$headers = @{
    "x-api-key" = $ApiKey
    "anthropic-version" = "2023-06-01"
    "content-type" = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri "https://api.anthropic.com/v1/messages" -Method Post -Headers $headers -Body $jsonBody
    
    $validationReport = $response.content[0].text
    
    # Save report
    $validationReport | Set-Content $validationFile -Encoding UTF8
    
    Write-Host ""
    Write-Host "=== VALIDATION COMPLETE ===" -ForegroundColor Green
    Write-Host ""
    Write-Host $validationReport
    Write-Host ""
    Write-Host "Report saved to: $validationFile" -ForegroundColor Cyan
    
    # Check status
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
