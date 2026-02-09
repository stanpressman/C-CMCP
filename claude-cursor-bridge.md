# Claude.ai → Cursor AI Bridge Workflow

## Overview
This workflow allows Claude.ai to send prompts directly to Cursor AI, with you as the approval layer.

## Setup Options

### Option 1: File-Based Workflow (Recommended)

#### Step 1: Create Shared Directories
Create these folders in your project:
- `claude-requests/` - Claude writes prompts here
- `cursor-responses/` - I write responses here
- `approved/` - Approved prompts move here
- `completed/` - Completed tasks move here

#### Step 2: Claude.ai Instructions
Give Claude this prompt:

```
When you're ready to send a task to Cursor AI, write it to a file in this format:

File: claude-requests/task-[timestamp].md

Format:
---
STATUS: PENDING
PRIORITY: HIGH|MEDIUM|LOW
TASK_TYPE: CODE|REVIEW|FIX|FEATURE
---

## Task Description
[Your task description]

## Context
[Any relevant context, file paths, requirements]

## Expected Output
[What you expect Cursor to produce]

## Files to Modify/Create
- file1.html
- file2.css
- etc.

---
END_TASK
```

#### Step 3: Monitoring Script
Create a script that watches for new files and notifies you.

### Option 2: Clipboard Bridge (Simpler)

Use a clipboard monitoring tool that:
1. Claude copies formatted prompts to clipboard
2. Script detects clipboard changes
3. Creates a file in `claude-requests/`
4. You review and approve
5. I process the approved file

### Option 3: Shared Google Doc/Notion

1. Claude writes to a shared document
2. Script polls the document via API
3. Creates local files for me to process
4. You approve before processing

## Recommended Implementation

Let me create a simple monitoring script for you.
