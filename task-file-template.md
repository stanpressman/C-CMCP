# Task File Template for Claude.ai

<!-- Use this template when creating tasks for Cursor AI -->
<!-- Task naming: claude-requests/task-YYYYMMDD-HHMMSS.md -->

---
STATUS: PENDING
PRIORITY: HIGH|MEDIUM|LOW
TASK_TYPE: CODE|REVIEW|FIX|FEATURE|REFACTOR
TASK_ID: TASK-YYYY-MM-DD-NNN
TIMESTAMP: [YYYY-MM-DD HH:MM:SS]
---

## Task Description
[Clear, concise description of what needs to be done - 2-4 sentences]

## Context
[Relevant background information, design decisions, constraints, business logic]

## Requirements

### MUST (Critical - Blocking)
These requirements are mandatory. Validation will FAIL if any MUST requirement is not met.

- **M1:** [Requirement description]
  - Acceptance: [How to verify this is complete]
  - Test: [Specific test case or condition]

- **M2:** [Requirement description]
  - Acceptance: [How to verify this is complete]
  - Test: [Specific test case or condition]

### SHOULD (Important - Advisory)
These requirements are important but not blocking. Validation will note if missing but won't fail the task.

- **S1:** [Requirement description]
  - Acceptance: [How to verify this is complete]
  - Test: [Specific test case or condition]

### COULD (Nice-to-have - Optional)
These requirements are optional enhancements. No impact on validation pass/fail.

- **C1:** [Requirement description]
  - Acceptance: [How to verify this is complete]

## Files to Modify/Create
- `path/to/file1.ext` — [what needs to change]
- `path/to/file2.ext` — [what needs to change]
- `path/to/newfile.ext` — [what needs to be created]

## Expected Behavior
[Describe what the final result should look like or do - user perspective]

Example:
- When user clicks X, Y should happen
- The function should return Z when given input A
- The UI should display B in state C

## Validation Criteria
[Specific things API Claude should check during validation]

**Automatic checks:**
- [ ] All listed files modified/created
- [ ] No syntax errors
- [ ] No obvious security issues (hardcoded secrets, etc.)
- [ ] Code follows repo style rules (if configured)

**Functional checks:**
- [ ] [Specific behavior to verify]
- [ ] [Specific output to check]
- [ ] [Specific edge case to handle]

## Testing Instructions
[What Cursor should test manually, if anything]

- [ ] Test case 1: [steps] → [expected result]
- [ ] Test case 2: [steps] → [expected result]

Or: "No manual testing required - validation will check"

## Notes
[Any additional notes, warnings, or considerations]

- Design patterns to follow
- Performance considerations
- Security concerns
- Dependencies that may need updating
- Known limitations or constraints

## Repo Rules Reference
[If repo-rules.md exists, reference relevant sections]

- Style: [reference to style rules]
- Patterns: [reference to architecture patterns]
- Security: [reference to security requirements]

---
END_TASK
---

## Example Task (Filled In)

---
STATUS: PENDING
PRIORITY: HIGH
TASK_TYPE: FEATURE
TASK_ID: TASK-2026-02-09-001
TIMESTAMP: 2026-02-09 14:30:00
---

## Task Description
Add a dark mode toggle to the password manager page. Users should be able to switch between light and dark themes with their preference persisted across sessions.

## Context
The password-manager.html page currently only has a light theme. Multiple users have requested dark mode support. The design should maintain the existing aesthetic while providing comfortable viewing in low-light conditions.

## Requirements

### MUST (Critical - Blocking)
- **M1:** Toggle button must be visible in the header
  - Acceptance: Button appears in header, clearly labeled or icon-based
  - Test: Page loads → toggle button is visible and clickable

- **M2:** Toggle must switch between light and dark themes
  - Acceptance: Clicking toggle changes page theme immediately
  - Test: Click toggle → all sections change color scheme within 300ms

- **M3:** User preference must persist across sessions
  - Acceptance: Theme choice saved to localStorage
  - Test: Set dark mode → reload page → dark mode still active

### SHOULD (Important - Advisory)
- **S1:** Smooth transition between themes
  - Acceptance: Color changes animate smoothly, no jarring flashes
  - Test: Visual inspection of theme transition

- **S2:** All page sections support dark mode
  - Acceptance: Header, hero, features, pricing, footer all have dark variants
  - Test: In dark mode, scroll through entire page checking all sections

### COULD (Nice-to-have - Optional)
- **C1:** System theme detection
  - Acceptance: If no preference set, detect OS dark mode preference
  - Test: Clear localStorage → check if system theme is respected

## Files to Modify/Create
- `password-manager.html` — Add toggle button, localStorage logic
- `css/style.css` — Add dark mode CSS variables and styles

## Expected Behavior
- When user loads page first time, light theme is default
- Toggle button in header shows current theme state (sun/moon icon)
- Clicking toggle switches theme immediately with smooth transition
- Theme preference persists across browser sessions
- All text remains readable in both themes (WCAG contrast compliance)

## Validation Criteria

**Automatic checks:**
- [ ] password-manager.html and css/style.css modified
- [ ] No syntax errors in HTML/CSS/JS
- [ ] No hardcoded credentials or API keys
- [ ] CSS follows existing formatting conventions

**Functional checks:**
- [ ] Toggle button exists and is clickable
- [ ] Theme switching works (visual inspection or DOM class check)
- [ ] localStorage key 'theme' is set on toggle
- [ ] Page respects localStorage value on reload
- [ ] All sections have appropriate dark mode styles

## Testing Instructions
- [ ] Test case 1: Fresh load → light theme default, toggle works
- [ ] Test case 2: Set dark mode → reload → dark mode persists
- [ ] Test case 3: Clear localStorage → toggle still works, sets preference
- [ ] Test case 4: Check all sections in dark mode for readability

## Notes
- Use CSS variables (--color-primary, --color-bg, etc.) for theme colors
- Ensure contrast ratios meet WCAG AA standards (4.5:1 for text)
- Toggle should use icon (moon/sun) rather than text for space efficiency
- Consider adding 'data-theme' attribute to <html> element for theme switching
- Existing JavaScript uses vanilla JS - maintain consistency

## Repo Rules Reference
- Style: Follow existing CSS formatting (2-space indent, grouped properties)
- Patterns: Use CSS custom properties for theming, not class switching
- Security: No security considerations for this task

---
END_TASK
