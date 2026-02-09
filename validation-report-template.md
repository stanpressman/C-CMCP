# Validation Report

<!-- Metadata for traceability -->
## Task
- Task ID: [TASK-...]
- Task file: [path/to/task.md]
- Response file: [cursor-responses/response-*.md]
- Validator: API Claude
- Date: [YYYY-MM-DD]

<!-- Hybrid result: critical vs advisory -->
## Overall Result
- Status: [PASS / FAIL / ADVISORY]
- Critical issues: [count]
- Advisory issues: [count]

<!-- Requirement-by-requirement checklist -->
## Requirements Validation

### MUST
- [ ] [Req M1: ...] — [PASS/FAIL/PARTIAL]
  - Evidence: [file/section reference or snippet]
  - If FAIL: [why it failed + what correct behavior is]
  - Suggested fix: [short direction]

### SHOULD
- [ ] [Req S1: ...] — [PASS/FAIL/PARTIAL]
  - Evidence: [...]
  - If FAIL: [why + correct behavior]
  - Suggested fix: [...]

### COULD
- [ ] [Req C1: ...] — [PASS/FAIL/PARTIAL]
  - Evidence: [...]
  - If FAIL: [why + correct behavior]
  - Suggested fix: [...]

<!-- Targeted review comments for fast remediation -->
## Targeted Findings (by file/section)
- `path/to/file.ext` — [issue summary]
  - Location: [function / section / anchor]
  - Problem: [what is wrong]
  - Why: [expected vs actual]
  - Suggested fix: [what to change]

<!-- Optional diff snippets for precision -->
## Optional Diff Suggestions
```
- [old line]
+ [new line]
```

<!-- Separate critical vs advisory per hybrid policy -->
## Severity Summary
**Critical (blocking):** [list of critical items]

**Advisory (non-blocking):** [list of advisory items]

<!-- Space for the implementer to dispute incorrect findings -->
## Dispute / Clarification (for Cursor AI)
[If validator is wrong or spec is ambiguous, explain here]

<!-- Validator's confidence or uncertainty -->
## Validator Confidence
[High / Medium / Low] — [brief rationale]
