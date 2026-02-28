---
description: Android PR & commit review — lifecycle, coroutine, architecture & security focused
type: command

skill: android-code-review

parameters:
  - name: target
    type: string
    required: false
    default: "auto"
    description: "auto|commit:<commit_id>|file:<path>|pr:<pr_number>"
    note: "auto: staged → unstaged → last commit"
    shorthand: "android-code-review pr:123 / file:xxx / commit:xxx"

  - name: severity
    type: string
    required: false
    default: "high"
    description: "critical|high|medium|all"
    note: "Controls pattern loading scope (token optimization)"

  - name: output-format
    type: string
    required: false
    default: "markdown"
    description: "markdown|json"
---
# Android Code Review

Comprehensive Android code review with smart scope detection and severity-based pattern loading.

## What This Command Does

1. **Auto-detect scope** — Staged changes → Unstaged changes → Last commit
2. **Gather context** — Read code files and surrounding context
3. **Apply patterns** — Severity-based detection rules (CRITICAL/HIGH/MEDIUM)
4. **Filter findings** — >80% confidence threshold to reduce noise
5. **Format output** — Structured review with severity levels and fix suggestions

## Detection Categories

**CRITICAL — Production Blockers:**

- NullPointerException risks
- Fragment lifecycle violations
- Memory leaks (Handler, BroadcastReceiver, Context)
- Security vulnerabilities (hardcoded secrets, unsafe storage)

**HIGH — Structural Decay:**

- Long methods (>80 lines)
- High complexity (>12 cyclomatic)
- Deep nesting (>4 levels)
- Duplicated logic
- Missing error handling

**MEDIUM — Maintainability:**

- Business logic in UI layer
- Mutable state exposure
- Missing accessibility

## Parameters

- `--target`: `auto` (default) | `commit:<id>` | `file:<path>` | `pr:<number>`
- `--severity`: `critical` | `high` (default) | `medium` | `all`
- `--output-format`: `markdown` (default) | `json`

## Usage

```bash
# Review staged changes
/android-code-review

# Review specific file
/android-code-review --target file:app/src/main/java/Example.kt

# Review with custom severity
/android-code-review --severity critical

# Review commit
/android-code-review --target commit:abc123
```

## Security Rule

**Never approve code with security vulnerabilities!** Block commit if CRITICAL or HIGH issues found.
