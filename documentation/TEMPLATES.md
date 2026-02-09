# C-CMCP Templates Guide

Detailed guide to using the task, response, and validation templates effectively.

## Overview

C-CMCP uses three main templates that create a structured communication protocol between Claude.ai, Cursor AI, and API Claude.

**The Templates:**
1. `task-file-template.md` - Used by Claude.ai to create tasks
2. `cursor-response-template.md` - Used by Cursor to document implementation
3. `validation-report-template.md` - Used by API Claude for QC reports

## Task File Template

### Purpose
Creates a structured specification that both humans and AI can understand and validate against.

### Key Sections

#### Metadata Header
```markdown
---
STATUS: PENDING
PRIORITY: HIGH|MEDIUM|LOW
TASK_TYPE: CODE|REVIEW|FIX|FEATURE|REFACTOR
TASK_ID: TASK-2026-02-09-001
TIMESTAMP: 2026-02-09 14:30:00
---
```

**STATUS Values:**
- `PENDING` - New task waiting for approval
- `APPROVED` - Approved, ready for implementation
- `PROCESSING` - Currently being worked on
- `COMPLETED` - Finished and accepted

**PRIORITY Values:**
- `HIGH` - Blocking work, needs immediate attention
- `MEDIUM` - Important but not urgent
- `LOW` - Nice to have, can wait

**TASK_TYPE Values:**
- `CODE` - Writing new code
- `REVIEW` - Code review or audit
- `FIX` - Bug fix
- `FEATURE` - New feature implementation
- `REFACTOR` - Code cleanup/restructuring

#### Requirements Section

**The Must/Should/Could Framework:**

```markdown
### MUST (Critical - Blocking)
- **M1:** Button must be visible in header
  - Acceptance: Button appears in header, clearly labeled
  - Test: Page loads → button is visible and clickable

### SHOULD (Important - Advisory)
- **S1:** Button should have smooth hover animation
  - Acceptance: Hover triggers smooth color transition
  - Test: Mouse over button → color changes within 200ms

### COULD (Nice-to-have - Optional)
- **C1:** Button could show tooltip on hover
  - Acceptance: Tooltip appears explaining button function
```

**Why This Structure?**

- **MUST** = Validation FAILS if not met (blocking)
- **SHOULD** = Validation passes but notes missing (advisory)
- **COULD** = Bonus if implemented, ignored if not

**Writing Good Requirements:**

✅ **Good:**
```markdown
- **M1:** Search input filters user list in real-time
  - Acceptance: Typing updates visible users within 300ms
  - Test: Type "John" → only users with "John" in name show
```

❌ **Bad:**
```markdown
- **M1:** Add search functionality
  - Acceptance: It works
  - Test: Try searching
```

**Why?**
- Good: Specific, testable, measurable
- Bad: Vague, subjective, unclear

#### Files to Modify/Create

```markdown
## Files to Modify/Create
- `path/to/file1.html` — Add search input to header
- `path/to/file2.js` — Implement filter logic
- `path/to/styles.css` — Style the search input
```

**Best Practices:**
- Use relative paths from project root
- Explain WHAT changes in each file
- List in logical order (HTML → JS → CSS)
- Include new files that need creation

#### Expected Behavior

```markdown
## Expected Behavior
- When user loads page, search input is visible but empty
- When user types "abc", only items containing "abc" show
- When user clears search, all items reappear
- Search is case-insensitive
- No results shows "No items found" message
```

**Tips:**
- Write from user perspective
- Be specific about states and transitions
- Include edge cases
- Mention error states

#### Validation Criteria

```markdown
## Validation Criteria

**Automatic checks:**
- [ ] All listed files modified/created
- [ ] No syntax errors
- [ ] No obvious security issues
- [ ] Code follows repo style rules

**Functional checks:**
- [ ] Search input exists in DOM
- [ ] Typing triggers filter function
- [ ] Filter logic is case-insensitive
- [ ] Clear button resets filter
```

**Purpose:** Tells API Claude exactly what to check during validation.

### Complete Task Example

See `task-file-template.md` for the full template with example task.

## Cursor Response Template

### Purpose
Documents what Cursor actually implemented and provides context for validation.

### Key Sections

#### Requirements Status

```markdown
## Requirements Status

### MUST
- [x] M1: Search input visible in header — PASS — Added to nav-bar div
- [x] M2: Real-time filtering works — PASS — Implemented with debounce
- [ ] M3: Clear button resets filter — FAIL — Not implemented yet

### SHOULD
- [x] S1: Debounced input — PASS — 300ms debounce added
- [x] S2: "No results" message — PASS — Shows when filter empty

### COULD
- [ ] C1: Advanced search operators — SKIP — Not in scope
```

**Why Self-Assessment?**
- Forces Cursor to check requirements before claiming done
- Gives validator starting point
- Highlights known gaps

#### Deviations From Spec

```markdown
## Deviations From Spec (if any)
- Used `querySelector` instead of `getElementById` — Modern approach, better flexibility
- Added debounce to search (not in spec) — Prevents performance issues on large lists
```

**Purpose:** 
- Explains why implementation differs from task
- Provides rationale for decisions
- Flags potential concerns

**If No Deviations:**
```markdown
## Deviations From Spec (if any)
None
```

#### Known Limitations / Edge Cases

```markdown
## Known Limitations / Edge Cases
- Search doesn't work with special regex characters (e.g., "[", "*")
- Filter slows down with >10,000 items (needs virtualization)
- No handling for multiple simultaneous searches
```

**Why This Matters:**
- Sets expectations about edge cases
- Identifies future work needed
- Helps validator know what NOT to test

#### Notable Implementation Choices

```markdown
## Notable Implementation Choices
- Used Array.filter() instead of manual loop — More readable, slight performance hit acceptable
- Stored filtered results in state — Enables undo/redo functionality later
- Added aria-label for accessibility — Not in requirements but good practice
```

**Purpose:**
- Documents design decisions
- Explains tradeoffs made
- Highlights extra work done

### Tips for Cursor

When telling Cursor to implement:
```
"Implement the task in approved/task-*.md and fill out a response using 
cursor-response-template.md. Be honest about what you completed and what 
you didn't. Document any deviations and why you made them."
```

## Validation Report Template

### Purpose
Structured QC report from API Claude that evaluates implementation against requirements.

### Key Sections

#### Overall Result

```markdown
## Overall Result
- Status: PASS / FAIL / ADVISORY
- Critical issues: 0
- Advisory issues: 2
```

**Status Meanings:**
- **PASS** - All MUST requirements met, safe to accept
- **FAIL** - One or more MUST requirements failed, needs remediation
- **ADVISORY** - MUST requirements met, but SHOULD/COULD have issues

#### Requirements Validation

```markdown
### MUST
- [ ] M1: Search input in header — PASS
  - Evidence: nav-bar contains input element with id="search"
  - No issues found

- [ ] M2: Real-time filtering — FAIL
  - Evidence: Function exists but no event listener attached
  - Problem: Input has no oninput handler
  - Suggested fix: Add addEventListener('input', filterFunction)
```

**Why Detailed Evidence?**
- You can verify validator's claims
- Pinpoints exact problem location
- Provides actionable fix suggestions

#### Targeted Findings

```markdown
## Targeted Findings (by file/section)
- `search.js` — Missing event listener
  - Location: Line 45-60 (filter function definition)
  - Problem: Function defined but never called
  - Why: Input element has no event handler attached
  - Suggested fix: Add document.querySelector('#search').addEventListener('input', debounce(filterFunction, 300))
```

**Format:**
1. File/section reference
2. Precise location
3. What's wrong
4. Why it's wrong
5. How to fix it

#### Severity Summary

```markdown
## Severity Summary

**Critical (blocking):**
- M2: Real-time filtering not functional (no event listener)

**Advisory (non-blocking):**
- S2: "No results" message missing accessibility label
- Code formatting inconsistent (tabs vs spaces)
```

**Why Separate?**
- Clear what MUST be fixed (critical)
- Clear what COULD be improved (advisory)
- You decide if advisory items matter

### Using Validation Reports

**If PASS:**
1. Read advisory notes
2. Test manually
3. Decide if advisory items worth fixing
4. Accept if satisfied

**If FAIL:**
1. Read critical issues
2. Decide: Let Cursor fix OR fix yourself OR clarify requirements
3. Don't accept until fixed

**If ADVISORY:**
1. Read the issues
2. Test manually
3. Judge if issues affect your use case
4. Accept or request improvements

## Template Customization

### When to Customize

**Good Reasons:**
- Your project has specific conventions (e.g., different requirement labels)
- Your industry has compliance needs (e.g., HIPAA, SOC2)
- Your team has different approval workflows

**Bad Reasons:**
- "I don't like MUST/SHOULD/COULD" (consider why this framework works)
- "Too much detail" (detail prevents ambiguity)
- "Takes too long" (upfront time saves debugging time)

### How to Customize

1. **Copy the template** you want to modify
2. **Make changes** to structure or sections
3. **Update the other templates** to match (e.g., if you change requirement labels in tasks, update response and validation templates)
4. **Test with a simple task** to ensure templates still work together
5. **Document your changes** in a CUSTOMIZATION.md file

### Example Customization

**Original:**
```markdown
### MUST (Critical - Blocking)
### SHOULD (Important - Advisory)
### COULD (Nice-to-have - Optional)
```

**Customized for Agile:**
```markdown
### P0 (Sprint Blocker)
### P1 (Sprint Goal)
### P2 (Nice to Have)
### P3 (Backlog)
```

**Just update all three templates** to use the new labels.

## Common Mistakes

### Task Files

❌ **Vague requirements:**
```markdown
- M1: Make it work
```

✅ **Specific requirements:**
```markdown
- M1: Search input filters list on keypress
  - Acceptance: Each keystroke updates visible items within 300ms
  - Test: Type "test" → only items containing "test" display
```

❌ **Missing acceptance criteria:**
```markdown
- M1: Add dark mode toggle
```

✅ **With acceptance criteria:**
```markdown
- M1: Add dark mode toggle
  - Acceptance: Button in header, toggles between light/dark themes
  - Test: Click button → page theme changes immediately
```

### Response Files

❌ **Claiming PASS without verification:**
```markdown
- [x] M1: Everything works — PASS — Implemented
```

✅ **Honest self-assessment:**
```markdown
- [x] M1: Search filters on keypress — PASS — Event listener on input
- [ ] M2: Debounced to 300ms — PARTIAL — Implemented at 500ms (300ms felt too fast)
```

❌ **No deviation documentation:**
```markdown
## Deviations From Spec
None
[But actually changed implementation approach]
```

✅ **Documented deviations:**
```markdown
## Deviations From Spec
- Used fetch() instead of XMLHttpRequest (spec said "AJAX")
  - Reason: fetch() is modern standard, better error handling
  - Impact: Same functionality, cleaner code
```

### Validation Reports

API Claude generates these, but watch for:

❌ **Vague failures:**
```markdown
- M1: Doesn't work — FAIL
```

If you see this, the validation prompt needs improvement.

✅ **Specific failures:**
```markdown
- M1: Search filtering not functional — FAIL
  - Evidence: Input exists but no event listener found in source
  - Problem: No oninput or onchange handler attached to input#search
  - Fix: Add addEventListener('input', filterUsers) to initialization
```

## Best Practices

### For Task Creation (Claude.ai)

1. **Be specific** - "Button in top-right" not "Button somewhere"
2. **Include test cases** - Real examples of expected behavior
3. **Separate concerns** - One task per feature/fix
4. **Label priority correctly** - Don't make everything MUST

### For Implementation (Cursor)

1. **Read the whole task** before coding
2. **Fill out response template honestly** - Don't claim PASS if uncertain
3. **Document deviations** - Explain why you did it differently
4. **Test before responding** - Verify your own work first

### For Validation Review (You)

1. **Read validation report first** - Saves manual testing time if it failed
2. **Don't skip manual testing** - Validation catches logic, not UX
3. **Check validator's evidence** - Ensure it's not hallucinating
4. **Use dispute section** - If validator is wrong, document why

## Next Steps

- Practice with the test task in README.md
- Review WORKFLOW.md for complete process
- See TROUBLESHOOTING.md if templates aren't working

---

**Remember:** Templates are communication tools. Use them to be clear, not to be bureaucratic.
