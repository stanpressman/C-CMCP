# Instructions for Claude.ai

## How to Send Tasks to Cursor AI

When you have a task ready for Cursor AI to implement, follow these steps:

### Step 1: Create Task File
Create a file in the `claude-requests/` directory with this naming pattern:
```
claude-requests/task-YYYYMMDD-HHMMSS.md
```

### Step 2: Use This Template

```markdown
---
STATUS: PENDING
PRIORITY: HIGH|MEDIUM|LOW
TASK_TYPE: CODE|REVIEW|FIX|FEATURE|REFACTOR
TIMESTAMP: [current timestamp]
---

## Task Description
[Clear, concise description of what needs to be done]

## Context
[Relevant background information, design decisions, constraints]

## Requirements
- [ ] Requirement 1
- [ ] Requirement 2
- [ ] Requirement 3

## Files to Modify/Create
- path/to/file1.html
- path/to/file2.css
- path/to/newfile.js

## Expected Output
[What the final result should look like or do]

## Notes
[Any additional notes, warnings, or considerations]

---
END_TASK
```

### Step 3: Example Task

```markdown
---
STATUS: PENDING
PRIORITY: HIGH
TASK_TYPE: FEATURE
TIMESTAMP: 2026-01-24 14:30:00
---

## Task Description
Add a dark mode toggle to the password manager page

## Context
The password-manager.html page currently only has a light theme. Users have requested dark mode support.

## Requirements
- [ ] Add dark mode toggle button in header
- [ ] Toggle should persist user preference (localStorage)
- [ ] Smooth transition between themes
- [ ] All sections should support dark mode
- [ ] Maintain existing design aesthetic

## Files to Modify/Create
- password-manager.html
- css/style.css (add dark mode styles)

## Expected Output
A working dark mode toggle that switches the entire page theme, with preference saved to localStorage.

## Notes
Use CSS variables for colors to make theme switching easier. Ensure contrast ratios meet WCAG standards.

---
END_TASK
```

### Step 4: After Creating the File
1. Save the file in `claude-requests/`
2. Inform the user: "I've created a task file for Cursor AI. Please run the monitor script to review and approve it."

### Best Practices
- Be specific and detailed
- Include file paths relative to project root
- List all requirements clearly
- Provide context about design decisions
- Include examples when helpful
