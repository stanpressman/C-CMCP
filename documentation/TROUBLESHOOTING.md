# C-CMCP Troubleshooting Guide

Solutions to common issues encountered when using C-CMCP.

## Quick Diagnostic Checklist

Before diving into specific issues, run through this checklist:

- [ ] PowerShell execution policy set (Bypass or RemoteSigned)
- [ ] ANTHROPIC_API_KEY environment variable set correctly
- [ ] PowerShell restarted after setting environment variable
- [ ] Running scripts from C-CMCP directory
- [ ] Task files in correct subdirectories
- [ ] Task files have correct STATUS values
- [ ] API key has credits available

If all checked, proceed to specific issues below.

## PowerShell Script Errors

### Error: "Cannot be loaded. The file is not digitally signed"

**Full Error:**
```
File C:\c-cmcp\monitor-claude-requests.ps1 cannot be loaded. The file 
is not digitally signed. You cannot run this script on the current system.
```

**Cause:** Windows execution policy blocks unsigned PowerShell scripts.

**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

Then run the script again. This only affects the current PowerShell session.

**Permanent Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Error: "The string is missing the terminator"

**Full Error:**
```
The string is missing the terminator: ".
Missing closing '}' in statement block or type definition.
```

**Cause:** File encoding issues, often from downloading files in browser.

**Solution:**
1. Delete the problematic .ps1 file
2. Re-download from source
3. OR open in Notepad, copy all content, create new .ps1 file, paste, save

**Prevention:**
- Download files directly, don't copy/paste in browser
- Use UTF-8 encoding when creating files
- Use PowerShell ISE or VS Code for editing scripts

### Error: "Execution Policy Change"

**Full Error:**
```
Execution Policy Change
Do you want to change the execution policy?
[Y] Yes  [A] Yes to All  [N] No  [L] No to All
```

**Solution:** Type `A` (Yes to All)

This applies the policy change without prompting again.

## API Key Issues

### Error: "ANTHROPIC_API_KEY not found in environment variables"

**Cause:** Environment variable not set or PowerShell hasn't loaded it.

**Solution:**

1. **Verify it's set:**
   ```powershell
   $env:ANTHROPIC_API_KEY
   ```
   
   Should display your key starting with `sk-ant-api03-`

2. **If blank, set it:**
   - Open Environment Variables (Win+R → `sysdm.cpl` → Advanced → Environment Variables)
   - Add User variable: `ANTHROPIC_API_KEY` = your key
   - Click OK on all dialogs
   - **Close and reopen PowerShell**

3. **Test again:**
   ```powershell
   $env:ANTHROPIC_API_KEY
   ```

### Error: "(400) Bad Request" from API

**Full Error:**
```
The remote server returned an error: (400) Bad Request.
{"type":"error","error":{"type":"invalid_request_error"...}}
```

**Possible Causes:**

**1. Invalid API Key**
```powershell
# Test your key
$env:ANTHROPIC_API_KEY
```

Should start with `sk-ant-api03-`. If different format, key is wrong.

**Solution:** Get new key from console.anthropic.com

**2. No Credits**
- Check console.anthropic.com → Billing
- Add payment method if needed
- API requires active billing

**3. UTF-8 Encoding Issue**

**Error Detail:**
```
"str is not valid UTF-8: surrogates not allowed"
```

**Cause:** File being read contains invalid UTF-8 characters (often from Cursor generating HTML with special characters).

**Solution:** Use `validate-cursor-work-v3.ps1` which skips reading file contents.

**4. Model Name Wrong**

**Error Detail:**
```
"model": "..." is not available
```

**Solution:** Update script to use current model:
```powershell
model = "claude-sonnet-4-20250514"
```

Check console.anthropic.com for current model names.

### Error: "Rate Limit Exceeded"

**Error:**
```
(429) Too Many Requests
```

**Cause:** API rate limits (rare for validation use case).

**Solution:**
- Wait 60 seconds and try again
- Check console.anthropic.com for rate limit info
- Consider upgrading API tier if validating many tasks

## Task File Issues

### "No tasks with STATUS: PENDING found"

**Cause:** 
- No task files in `claude-requests/` directory
- Task files have wrong STATUS
- Task files don't have STATUS line

**Solution:**

1. **Check files exist:**
   ```powershell
   Get-ChildItem claude-requests\*.md
   ```

2. **Check STATUS:**
   Open task file in Notepad, look for:
   ```markdown
   ---
   STATUS: PENDING
   ---
   ```

3. **Fix STATUS if wrong:**
   Change to `PENDING` and save.

### "No tasks with STATUS: PROCESSING found"

**Cause:** Task not marked as PROCESSING by process script.

**Solution:**

1. **Run process script first:**
   ```powershell
   .\process-approved-task.ps1
   ```

2. **Manually fix if needed:**
   - Open task in `approved/` directory
   - Change `STATUS: APPROVED` to `STATUS: PROCESSING`
   - Save and run validation again

### "Response file not found"

**Full Error:**
```
ERROR: Response file not found: cursor-responses\response-task-*.md
```

**Cause:** Cursor didn't write a response file.

**Solution:**

1. **Check if Cursor finished:**
   - Look in `cursor-responses/` for the file
   - If missing, Cursor didn't complete the task

2. **Remind Cursor:**
   ```
   "After implementing, write a response file to cursor-responses/response-task-*.md 
   using the cursor-response-template.md format"
   ```

3. **Check file name matches:**
   - Task file: `task-20260209-143000.md`
   - Response should be: `response-task-20260209-143000.md`
   - Names must match exactly

## Cursor Integration Issues

### Cursor Can't Read Task Files

**Symptom:** Cursor says it can't find or access the task file.

**Solution:**

1. **Give full path:**
   ```
   "Read the task in C:\c-cmcp\approved\task-20260209-143000.md"
   ```

2. **Check Cursor workspace:**
   - Ensure C-CMCP directory is in Cursor's workspace
   - Or cd into C-CMCP in Cursor's terminal

3. **Check file permissions:**
   - Ensure file isn't locked or read-only

### Cursor Doesn't Follow Template

**Symptom:** Cursor's response file doesn't match template structure.

**Solution:**

1. **Be explicit:**
   ```
   "Fill out the response using the exact format in cursor-response-template.md. 
   Include all sections: Requirements Status, Files Modified, Deviations, etc."
   ```

2. **Show Cursor the template:**
   Upload `cursor-response-template.md` to Cursor's context.

3. **Review and correct:**
   If Cursor's response is incomplete, manually fill in missing sections.

### Cursor Moves Task to Completed Too Early

**Symptom:** Task goes to `completed/` before validation runs.

**Solution:**

1. **Move it back:**
   - Move task from `completed/` to `approved/`
   - Ensure STATUS is `PROCESSING`
   - Run validation

2. **Clarify workflow to Cursor:**
   ```
   "After implementation, write response file but DO NOT move task to completed. 
   Leave it in approved/ with STATUS: PROCESSING for validation."
   ```

## Validation Issues

### Validation Passes But Manual Test Fails

**Cause:** Validator can only see task file and response file, not actual code in v3.

**Solution:**

**This is expected behavior with validate-cursor-work-v3.ps1.** 

The v3 script validates based on Cursor's self-reported implementation, not actual code files (to avoid UTF-8 encoding issues).

**Your job:** Manual testing is required. Validation is a pre-filter, not a replacement for testing.

**If you want code-level validation:**
- Use `validate-cursor-work-v2.ps1` 
- Ensure files are UTF-8 encoded
- Accept encoding errors may occur

### Validation Fails But Code Looks Correct

**Cause:** Validator misunderstood requirements or hallucinated issues.

**Solution:**

1. **Check validator's evidence:**
   - Does the evidence actually show a problem?
   - Is the validator interpreting requirements correctly?

2. **Manually verify:**
   - Test the actual functionality
   - If it works, validator is wrong

3. **Accept anyway:**
   - Validation is advisory, not law
   - You are the final decision maker
   - Document why you're accepting despite validation failure

4. **Improve task next time:**
   - Unclear requirements lead to validation errors
   - Add more specific acceptance criteria

### Validation Takes Too Long / Hangs

**Symptom:** Script runs but no response for >60 seconds.

**Possible Causes:**

1. **Network issue** - Check internet connection
2. **API outage** - Check status.anthropic.com
3. **Very large task** - API processing complex validation

**Solution:**

1. **Wait 2 minutes** - Some validations take time
2. **Check API status** - Visit status.anthropic.com
3. **Try again** - Press Ctrl+C, run script again
4. **Reduce task size** - Break into smaller tasks

## File System Issues

### "Access Denied" Errors

**Cause:** File permissions or antivirus blocking.

**Solution:**

1. **Run PowerShell as Administrator:**
   - Right-click PowerShell → Run as Administrator
   - Navigate to C-CMCP directory
   - Run scripts

2. **Check antivirus:**
   - Some antivirus blocks PowerShell scripts
   - Add C-CMCP directory to exclusions

3. **Check file locks:**
   - Close any programs that might have files open
   - Close Cursor if it has files open
   - Try again

### Directories Not Created Automatically

**Symptom:** Scripts fail because directories don't exist.

**Solution:**

**Manually create them:**
```powershell
cd C:\path\to\C-CMCP
New-Item -ItemType Directory -Path "claude-requests"
New-Item -ItemType Directory -Path "approved"
New-Item -ItemType Directory -Path "cursor-responses"
New-Item -ItemType Directory -Path "validation-reports"
New-Item -ItemType Directory -Path "completed"
```

**Or run monitor script once:**
```powershell
.\monitor-claude-requests.ps1
```
Press Ctrl+C after it starts - directories will be created.

## Workflow Issues

### Lost Track of Task Status

**Symptom:** Don't know if task is approved, processing, or completed.

**Solution:**

1. **Check directory location:**
   - `claude-requests/` = PENDING
   - `approved/` = APPROVED or PROCESSING
   - `completed/` = COMPLETED

2. **Open task file and check STATUS line:**
   ```markdown
   STATUS: PROCESSING
   ```

3. **Check for response file:**
   - If `cursor-responses/response-task-*.md` exists, implementation is done
   - If validation report exists, validation is done

### Multiple Tasks Piling Up

**Symptom:** Too many tasks in different stages, losing track.

**Solution:**

1. **One task at a time:**
   - Complete full workflow for one task before starting another
   - Move completed tasks out of the way

2. **Use task naming:**
   - Name tasks descriptively: `task-20260209-add-search.md`
   - Easier to identify what each task is

3. **Clean up completed:**
   - Archive or delete old completed tasks periodically
   - Keep completed/ directory organized

### Accidentally Deleted Important File

**Solution:**

1. **Check Windows Recycle Bin** - Recover if possible

2. **Regenerate from source:**
   - Task files: Ask Claude.ai to recreate
   - Response files: Ask Cursor to recreate
   - Validation reports: Re-run validation script

3. **Use version control:**
   - Commit C-CMCP directory to git
   - Can recover deleted files from history

## Performance Issues

### Scripts Run Slowly

**Cause:** 
- Large number of files in directories
- Antivirus scanning every file access
- Network latency to API

**Solution:**

1. **Archive old tasks:**
   - Move old completed tasks out of C-CMCP
   - Keep directories lean

2. **Exclude from antivirus:**
   - Add C-CMCP to antivirus exclusions

3. **API latency:**
   - Normal - API calls take 2-10 seconds
   - Can't be sped up significantly

### Monitor Script Uses Too Much CPU

**Symptom:** monitor-claude-requests.ps1 consuming resources.

**Cause:** Script polls every 5 seconds in infinite loop.

**Solution:**

1. **Stop when not needed:**
   - Press Ctrl+C to stop monitoring
   - Only run when actively working on tasks

2. **Increase poll interval:**
   Edit script, change line:
   ```powershell
   Start-Sleep -Seconds 5
   ```
   To:
   ```powershell
   Start-Sleep -Seconds 30
   ```

## Getting Help

If your issue isn't covered here:

1. **Check script output carefully** - Error messages are usually specific
2. **Review WORKFLOW.md** - Ensure you're following the process correctly
3. **Review SETUP.md** - Verify configuration is correct
4. **Test with simple task** - Use the back-to-top button test from README
5. **Check Anthropic documentation** - For API-specific issues
6. **Ask Claude.ai** - Describe the error and workflow step

## Common User Mistakes

### Mistake 1: Not Restarting PowerShell

After setting environment variables, you MUST close and reopen PowerShell. Old sessions don't see new variables.

### Mistake 2: Wrong Directory

Scripts use relative paths. You must run them from C-CMCP directory:
```powershell
cd C:\path\to\C-CMCP
.\script-name.ps1
```

NOT:
```powershell
cd C:\somewhere\else
C:\path\to\C-CMCP\script-name.ps1  # Won't work correctly
```

### Mistake 3: Accepting Before Validation

Don't click "Accept" in Cursor until AFTER validation passes. Validation can catch issues before you commit broken code.

### Mistake 4: Ignoring Validation Failures

FAIL means critical requirements weren't met. Don't ignore - either fix or clarify requirements.

### Mistake 5: Skipping Manual Testing

Validation is automated checking. Manual testing is still required to verify actual functionality.

## Prevention Tips

**To avoid issues:**

1. ✅ Follow workflow in order (don't skip steps)
2. ✅ Read validation reports completely
3. ✅ Test manually even if validation passes
4. ✅ Keep API key secure and funded
5. ✅ Write clear, testable requirements
6. ✅ Document deviations and limitations
7. ✅ One task at a time until comfortable
8. ✅ Use version control on C-CMCP directory

---

**Still stuck?** Review the successful test run in README.md and compare your process.
