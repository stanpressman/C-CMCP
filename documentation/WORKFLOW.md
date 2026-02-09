# C-CMCP Workflow Guide

Complete walkthrough of the development workflow from task creation to completion.

## Overview

The C-CMCP workflow has 7 distinct stages with human approval gates at critical points.

```
[1] Claude.ai creates task
    ↓
[2] You review and approve task
    ↓
[3] Task marked for processing
    ↓
[4] Cursor implements code
    ↓
[5] API Claude validates work
    ↓
[6] You review validation + test manually
    ↓
[7] Accept or reject implementation
```

## Stage 1: Task Creation (Claude.ai)

### Your Role
Ask Claude.ai to create a task for a feature or fix you need.

### Example Request
```
"Create a task for Cursor to add a dark mode toggle to the dashboard. 
Use the task-file-template format."
```

### What Claude.ai Does
1. Creates a structured task file using task-file-template.md
2. Defines MUST/SHOULD/COULD requirements with acceptance criteria
3. Specifies files to modify
4. Lists validation criteria
5. Provides testing instructions

### What You Do
1. Review the task file Claude created (as an artifact)
2. Download it to `C-CMCP\claude-requests\`
3. Name it: `task-YYYYMMDD-HHMMSS.md` (or keep Claude's naming)

### Quality Check
- Are requirements clear and specific?
- Are MUST requirements truly critical?
- Are acceptance criteria testable?
- Are file paths correct?

## Stage 2: Task Approval (You + Monitor Script)

### Start the Monitor
```powershell
cd C:\Projects\YourProject\C-CMCP
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\monitor-claude-requests.ps1
```

### What Happens
1. Script detects new task file in `claude-requests\`
2. Displays full task for your review
3. Prompts: "Approve this task? (y/n/skip)"

### Your Decision
- **Type 'y'** - Approve task, moves to `approved\`, STATUS changes to APPROVED
- **Type 'n'** - Reject task, stays in `claude-requests\`
- **Type 'skip'** - Ignore for now, won't show again this session

### Example Output
```
=== NEW TASK FROM CLAUDE ===
File: task-20260209-143000.md
Time: 2/9/2026 2:30:00 PM

[Full task content displayed]

Approve this task? (y/n/skip): y
Task approved and moved to approved/
Notify Cursor AI to process: approved\task-20260209-143000.md
```

### Tips
- Read the MUST requirements carefully - these are blocking
- Verify file paths exist in your project
- Check that validation criteria are reasonable
- Make sure you understand what's being asked

## Stage 3: Task Processing (Process Script)

### Run Process Script
```powershell
.\process-approved-task.ps1
```

### What Happens
1. Script finds oldest approved task (or you can specify which one)
2. Displays task content
3. Changes STATUS from APPROVED → PROCESSING
4. Shows you where Cursor should write response

### Example Output
```
Processing: task-20260209-143000.md

=== TASK FOR CURSOR AI ===
[Full task content]
=== END TASK ===

Response will be written to: cursor-responses\response-task-20260209-143000.md

INSTRUCTIONS FOR CURSOR AI:
1. Read the task file: C:\c-cmcp\approved\task-20260209-143000.md
2. Implement the requirements
3. Write a summary to: cursor-responses\response-task-20260209-143000.md
4. After completion, move task to: completed

Task marked as PROCESSING. Ready for Cursor AI to handle.
```

### What You Do
Now tell Cursor to implement the task.

## Stage 4: Implementation (Cursor AI)

### Your Prompt to Cursor
```
Read the task file in approved\task-20260209-143000.md and implement all requirements.
Use the cursor-response-template.md format for your response.
```

### What Cursor Does
1. Reads the task file
2. Implements code changes
3. Creates response file in `cursor-responses\`
4. Documents what was changed and why

### Cursor's Response File
Cursor fills out the cursor-response-template with:
- Task metadata
- Summary of changes
- MUST/SHOULD/COULD requirement status (self-assessed)
- Files modified
- Any deviations from spec
- Known limitations
- Manual tests performed (or not)
- Implementation choices made

### What You See
Cursor will show you code changes in its interface. **Don't click "Accept" yet** - wait for validation.

### Tips
- Let Cursor work without interrupting
- Review the code changes Cursor proposes
- Check that Cursor wrote a response file
- Verify Cursor didn't skip requirements

## Stage 5: Validation (API Claude)

### Run Validation Script
```powershell
.\validate-cursor-work-v3.ps1
```

### What Happens
1. Script finds task with STATUS: PROCESSING
2. Reads original task file
3. Reads Cursor's response file
4. Calls Anthropic API with both documents
5. API Claude validates against requirements
6. Generates structured validation report
7. Saves report to `validation-reports\`

### Example Output
```
=== STARTING VALIDATION ===
Calling API Claude...

=== VALIDATION COMPLETE ===
# Validation Report
## Overall Status: PASS ✓

### MUST Requirements
- M1: Dark mode toggle in header — PASS
- M2: Theme switching works — PASS
- M3: Preference persists — PASS

### SHOULD Requirements
- S1: Smooth transitions — PASS
- S2: All sections support dark mode — PASS

Validation report saved to: validation-reports\validation-task-20260209-143000.md
Result: PASS
```

### Validation Results

**PASS** - All MUST requirements met
- No critical issues
- May have minor advisory notes
- Safe to accept implementation

**FAIL** - One or more MUST requirements failed
- Critical issues found
- Implementation is incomplete or incorrect
- Do NOT accept - needs remediation

**ADVISORY** - MUST requirements met, but SHOULD/COULD have issues
- Core functionality works
- Non-critical improvements suggested
- Your call whether to accept as-is or request improvements

### Cost
Each validation call costs approximately $0.01-0.03 depending on task complexity.

## Stage 6: Manual Review (You)

### Your Checklist
1. **Read the validation report**
   - What passed/failed?
   - Are there security concerns?
   - Are there performance issues?

2. **Test the implementation manually**
   - Does it actually work?
   - Does it match your expectations?
   - Are there edge cases that break it?

3. **Review the code changes**
   - Is the code quality acceptable?
   - Does it follow project conventions?
   - Is it maintainable?

### Decision Matrix

| Validation | Manual Test | Code Quality | Decision |
|------------|-------------|--------------|----------|
| PASS | Works | Good | ✓ Accept |
| PASS | Works | Poor | Request cleanup |
| PASS | Broken | Any | Reject - validation missed something |
| FAIL | Any | Any | Reject - needs fixes |
| ADVISORY | Works | Good | Accept or request improvements |

## Stage 7: Final Decision (You)

### Option A: Accept Implementation
1. In Cursor, click "Accept" or "Keep" for all changes
2. Move task file from `approved\` to `completed\`
3. Optionally update STATUS to COMPLETED in the task file
4. Commit changes to version control

### Option B: Request Remediation
1. In Cursor, reject the changes
2. Create a new task file with specific fixes needed:
   ```
   "Fix issues found in validation report for task-20260209-143000:
   - M2 requirement failed: Theme toggle doesn't persist to localStorage
   - Add the missing localStorage.setItem call"
   ```
3. Run through workflow again

### Option C: Manual Fix
1. Make the corrections yourself
2. Update the task file STATUS to COMPLETED
3. Move to `completed\`
4. Document what you changed and why

## Remediation Loop

If validation fails, you have options:

### Approach 1: Iterative Refinement
1. Keep task in `approved\` with STATUS: PROCESSING
2. Tell Cursor: "The validation failed. Review the validation report at `validation-reports\validation-task-*.md` and fix the issues"
3. Cursor makes corrections
4. Run validation again
5. Repeat up to 2-3 times max

### Approach 2: New Task
1. Reject current implementation completely
2. Create new task file with clarified requirements
3. Start workflow from beginning

### Approach 3: Escalate to Manual
1. Accept partial work that's correct
2. Fix the failures yourself
3. Document what you did

### Rule: Maximum 2-3 Remediation Loops
After 3 failed validation attempts, either:
- Fix it yourself (faster)
- Rethink the requirements (maybe they're unclear)
- Break it into smaller tasks

## Complete Example Walkthrough

### Scenario: Add Search Functionality

**Stage 1: Task Creation**
```
You: "Create a task to add a search box to the user list page that filters 
      users by name as you type. Use the task template."

Claude.ai creates task with:
- M1: Search input visible in header
- M2: Typing filters the user list in real-time
- M3: Clearing search shows all users again
- S1: Debounce input to avoid excessive filtering
- S2: Show "No results" message when nothing matches
```

**Stage 2: Approval**
```
Download task-20260209-150000.md to claude-requests\
Run monitor-claude-requests.ps1
Review task, type 'y' to approve
Task moves to approved\
```

**Stage 3: Processing**
```
Run process-approved-task.ps1
Task STATUS → PROCESSING
```

**Stage 4: Implementation**
```
You to Cursor: "Implement approved\task-20260209-150000.md"
Cursor modifies user-list.html, adds search input, adds filter logic
Cursor writes response-task-20260209-150000.md documenting changes
```

**Stage 5: Validation**
```
Run validate-cursor-work-v3.ps1
API Claude reviews and reports: PASS ✓
All requirements met, no critical issues
```

**Stage 6: Manual Review**
```
Open user-list.html in browser
Type in search box → users filter correctly
Clear search → all users show again
Check debouncing → works (no lag)
Check "no results" message → appears when needed
Code looks clean and readable
```

**Stage 7: Acceptance**
```
In Cursor, accept all changes
Move task-20260209-150000.md to completed\
Commit to git
Done!
```

## Tips for Success

### Writing Good Tasks
- Be specific about expected behavior
- Include concrete test cases
- Separate critical (MUST) from nice-to-have (COULD)
- Reference existing code patterns when relevant

### Working with Cursor
- Give Cursor the task file path explicitly
- Ask Cursor to use the response template
- Don't interrupt mid-implementation
- Review code before validation runs

### Validation Best Practices
- Run validation before manual testing (saves time if it fails)
- Read the full validation report, not just PASS/FAIL
- Pay attention to security and performance notes
- Don't skip manual testing even if validation passes

### When to Skip C-CMCP
- Trivial changes (typo fixes, comment updates)
- Exploratory coding (spike work, proof of concept)
- Emergency hotfixes (fix now, validate later)
- You're the only developer and very familiar with the code

### When C-CMCP Adds Value
- Implementing complex features
- Working on unfamiliar parts of codebase
- Multiple developers need consistent quality
- Compliance or audit requirements
- Training/learning structured development

## Next Steps

- See [SETUP.md](SETUP.md) for detailed installation
- See [TEMPLATES.md](TEMPLATES.md) for template usage guide
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues

---

**Remember:** C-CMCP is a tool, not a religion. Use it when it adds value, skip it when it doesn't.
