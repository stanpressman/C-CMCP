# C-CMCP Setup Guide

Complete installation and configuration instructions.

## System Requirements

### Required
- **Operating System:** Windows 10/11
- **PowerShell:** Version 5.1 or later (built into Windows)
- **Anthropic API Key:** For validation (get from console.anthropic.com)
- **Cursor AI:** Installed and configured
- **Claude.ai Access:** For task creation

### Optional
- **Git:** For version control
- **Code Editor:** For viewing/editing task files (Notepad works fine)

## Installation

### Step 1: Get C-CMCP

Download or copy the complete C-CMCP folder structure.

### Step 2: Choose Project Location

Decide where to place C-CMCP:

**Option A: Inside Each Project** (Recommended)
```
C:\Projects\MyApp\
├── C-CMCP\           ← Place here
├── src\
├── tests\
└── README.md
```

**Option B: Shared Location**
```
C:\DevTools\C-CMCP\   ← Place here
```
Then symlink or copy into each project when needed.

### Step 3: Verify Directory Structure

After copying, verify you have:
```
C-CMCP\
├── approved\
├── claude-requests\
├── completed\
├── cursor-responses\
├── validation-reports\
├── monitor-claude-requests.ps1
├── process-approved-task.ps1
├── validate-cursor-work-v3.ps1
├── task-file-template.md
├── cursor-response-template.md
├── validation-report-template.md
├── repo-rules-example.md
├── README.md
├── WORKFLOW.md
├── SETUP.md
├── TEMPLATES.md
└── TROUBLESHOOTING.md
```

If any directories are missing, create them manually or run the monitor script once (it auto-creates them).

## Configuration

### Step 1: Get Anthropic API Key

1. Go to https://console.anthropic.com
2. Sign in or create account
3. Navigate to API Keys
4. Click "Create Key"
5. Name it (e.g., "C-CMCP-Validation")
6. Copy the key (starts with `sk-ant-api03-`)

**Important:** Store this key securely. You cannot retrieve it again after closing the dialog.

### Step 2: Set Environment Variable

**Option A: User Variable (Recommended)**

1. Press `Win + R`
2. Type `sysdm.cpl` and press Enter
3. Click "Advanced" tab
4. Click "Environment Variables"
5. In "User variables" section, click "New"
6. Variable name: `ANTHROPIC_API_KEY`
7. Variable value: `sk-ant-api03-...` (paste your key)
8. Click OK on all dialogs

**Option B: System Variable** (If you have admin rights)

Same process but use "System variables" section instead.

**Option C: Session Only** (Temporary)

In PowerShell:
```powershell
$env:ANTHROPIC_API_KEY = "sk-ant-api03-..."
```

This only lasts for the current PowerShell session.

### Step 3: Verify API Key

**Close and reopen PowerShell**, then test:

```powershell
# Check if variable is set
$env:ANTHROPIC_API_KEY

# Should display: sk-ant-api03-...
```

If it shows nothing, the environment variable isn't set correctly.

**Test API Connection:**
```powershell
cd C:\Path\To\Your\Project\C-CMCP

$headers = @{
    "x-api-key" = $env:ANTHROPIC_API_KEY
    "anthropic-version" = "2023-06-01"
    "content-type" = "application/json"
}

$body = @{
    model = "claude-sonnet-4-20250514"
    max_tokens = 50
    messages = @(@{role = "user"; content = "Hello"})
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://api.anthropic.com/v1/messages" -Method Post -Headers $headers -Body $body
```

If you get a response with "Hello" message, your API key works.

### Step 4: PowerShell Execution Policy

Windows blocks PowerShell scripts by default. You need to allow them.

**Option A: Per-Session** (Safest, Recommended for Testing)
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

Run this each time you open PowerShell. Only affects current session.

**Option B: Permanent for Current User**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Allows scripts you write and downloaded scripts that are signed.

**Option C: Permanent for All Users** (Requires Admin)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

### Step 5: Test the Scripts

**Test Monitor Script:**
```powershell
cd C:\Path\To\Your\Project\C-CMCP
.\monitor-claude-requests.ps1
```

Should display:
```
Monitoring claude-requests for new Claude requests...
Press Ctrl+C to stop
```

Press Ctrl+C to stop.

**Test Process Script:**
```powershell
.\process-approved-task.ps1
```

Should display:
```
No approved tasks found.
```

**Test Validation Script:**
```powershell
.\validate-cursor-work-v3.ps1
```

Should display:
```
No tasks with STATUS: PROCESSING found.
```

If all three scripts run without errors, you're set up correctly.

## Optional: Create Repo Rules

Create a `repo-rules.md` file in your C-CMCP directory with project-specific standards.

**Example:**
```markdown
# Repo Rules for MyProject

## Style / Linting
- Formatter: Prettier
- Lint config path: .eslintrc.json
- Enforce formatting in validation: yes

## Design Patterns / Architecture
- Preferred patterns: Service layer for business logic
- Forbidden patterns: No direct DB access in controllers

## Dependencies
- Allowed: Any in package.json
- Disallowed: jQuery, Moment.js (use date-fns)
- New deps require approval: yes

## Security Requirements
- Secrets handling: Never log tokens or API keys
- Authz rules: Must use RBAC checks in all handlers

## Testing Requirements
- Required tests: Unit tests for all service methods
- Must update snapshots: yes
- Minimum coverage: 80%
```

The validation script will use this if present.

## Integration with Cursor

### Configure Cursor to Know About C-CMCP

1. Open Cursor settings
2. Add C-CMCP directory to workspace
3. Consider adding a Cursor rule:

```
When implementing tasks:
1. Read task files from approved/ directory
2. Use cursor-response-template.md for responses
3. Write responses to cursor-responses/ directory
4. Document all changes and deviations
```

## Integration with Claude.ai

### Share Task Template with Claude

In Claude.ai, upload or share the `task-file-template.md` and say:

```
"Use this template whenever I ask you to create a task for Cursor. 
Fill it out completely with specific requirements, acceptance criteria, 
and validation steps."
```

Claude.ai will remember this for the session (and longer if you're using Projects or Memory features).

## Troubleshooting Setup

### "Cannot be loaded. The file is not digitally signed."

**Solution:** Set execution policy (see Step 4 above)

### "ANTHROPIC_API_KEY not found in environment variables"

**Solution:** 
1. Verify you set the environment variable correctly
2. Close and reopen PowerShell
3. Test with `$env:ANTHROPIC_API_KEY`

### "The remote server returned an error: (400) Bad Request"

**Possible causes:**
1. API key is invalid or expired - check console.anthropic.com
2. No credits on your account - add payment method
3. Request formatting issue - update to latest scripts

**Solution:** Test API key with simple request (see Step 3)

### Scripts Run But Don't Find Files

**Solution:** 
1. Make sure you're in the C-CMCP directory when running scripts
2. Check that task files are in the correct subdirectories
3. Verify task files have STATUS: PENDING/APPROVED/PROCESSING as expected

### Cursor Can't Read Task Files

**Solution:**
1. Give Cursor the full path to the task file
2. Make sure C-CMCP directory is in Cursor's workspace
3. Check file permissions (Cursor needs read access)

## Updating C-CMCP

To update to a newer version of C-CMCP:

1. **Backup your current tasks:**
   - Copy `approved/`, `cursor-responses/`, `validation-reports/`, `completed/` to safe location

2. **Update scripts:**
   - Download new script versions
   - Replace old .ps1 files with new ones

3. **Update templates:**
   - Download new template files
   - Compare with your customized versions
   - Merge changes if you've customized templates

4. **Test:**
   - Run a simple test task through the workflow
   - Verify everything still works

5. **Restore your data:**
   - Copy back your task directories if needed

## Uninstalling

To remove C-CMCP:

1. Archive or delete the C-CMCP folder
2. Remove the `ANTHROPIC_API_KEY` environment variable (optional)
3. Delete any symbolic links if you created them

Your project code is unaffected - C-CMCP doesn't modify your actual source code, only creates files in its own directory.

## Next Steps

- Read [WORKFLOW.md](WORKFLOW.md) for usage instructions
- Read [TEMPLATES.md](TEMPLATES.md) for template details
- Run the test workflow from README.md

---

**Need Help?** See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
