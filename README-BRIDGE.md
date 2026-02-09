# Claude.ai ↔ Cursor AI Bridge

This workflow allows Claude.ai to send tasks directly to Cursor AI, with you as the approval layer.

## Quick Start

### 1. Setup Directories
The scripts will create these automatically, or create them manually:
```
claude-requests/    # Claude writes tasks here
approved/           # You approve tasks here
cursor-responses/   # Cursor AI writes responses here
completed/          # Completed tasks go here
```

### 2. Give Instructions to Claude.ai
Share the `claude-instructions.md` file with Claude and tell it:
> "When you have a task for Cursor AI, create a task file in the claude-requests/ directory using the template in claude-instructions.md"

### 3. Monitor for New Tasks
Run the monitor script:
```powershell
.\monitor-claude-requests.ps1
```

This will:
- Watch for new task files from Claude
- Display them for your review
- Let you approve (y), reject (n), or skip
- Move approved tasks to the `approved/` folder

### 4. Process Approved Tasks
When you're ready for Cursor AI to work on an approved task:

**Option A: Manual**
1. Tell Cursor AI: "Read and process the task in approved/task-[name].md"
2. I'll read it, implement it, and report back

**Option B: Using Script**
```powershell
.\process-approved-task.ps1
```
This will show you the task and prepare it for Cursor AI.

## Workflow Diagram

```
Claude.ai
    ↓ (writes task file)
claude-requests/task-*.md
    ↓ (you review)
monitor-claude-requests.ps1
    ↓ (you approve)
approved/task-*.md
    ↓ (you trigger)
Cursor AI (me)
    ↓ (I implement)
[Code changes made]
    ↓ (I report)
cursor-responses/response-*.md
    ↓ (task complete)
completed/task-*.md
```

## Example Workflow

1. **Claude creates task:**
   - Claude writes `claude-requests/task-20260124-143000.md`
   - Claude tells you: "I've created a task file for Cursor AI"

2. **You review:**
   - Run `.\monitor-claude-requests.ps1`
   - Review the task
   - Type `y` to approve

3. **Cursor AI processes:**
   - You tell me: "Process the approved task in approved/task-20260124-143000.md"
   - I read it, implement it, write response

4. **You review results:**
   - Check the code changes I made
   - Review `cursor-responses/response-task-20260124-143000.md`
   - Approve or request changes

## Tips

- **Claude's role:** Design, architecture, writing detailed specs
- **Your role:** Approval, review, quality control
- **My role:** Implementation, coding, file modifications

## Customization

You can modify:
- File naming patterns
- Approval workflow
- Response formats
- Directory structure

All scripts are in PowerShell but can be adapted to other languages.
