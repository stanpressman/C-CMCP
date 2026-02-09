# Repo Rules (Example)

<!-- This file defines the repo-specific constraints that validation should use.
     It prevents hallucinated rules and focuses validation on actual standards. -->

## Style / Linting
- Formatter: [prettier/eslint/black/etc]
- Lint config path: [path]
- Enforce formatting in validation: [yes/no]

## Design Patterns / Architecture
- Preferred patterns: [e.g., "Service layer for business logic"]
- Forbidden patterns: [e.g., "No direct DB access in controllers"]

## Dependencies
- Allowed: [list or "any in package.json"]
- Disallowed: [list]
- New deps require approval: [yes/no]

## Security Requirements
- Secrets handling: [e.g., "never log tokens"]
- Authz rules: [e.g., "must use RBAC checks in handlers"]

## Testing Requirements
- Required tests: [unit/integration/e2e]
- Must update snapshots: [yes/no]
- Minimum coverage: [if applicable]

## Validation Notes
- Priority: [must/should/could rules]
- Exceptions: [any known exceptions]
