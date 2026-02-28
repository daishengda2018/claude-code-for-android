---
name: android-code-review
description: Android PR & commit review — lifecycle, coroutine, architecture & security focused
type: command

skill:
  name: android-code-review
  type: orchestration-layer
  description: Android-aware review with smart scope detection and severity-based pattern loading

parameters:
  - name: target
    type: string
    required: false
    default: "auto"
    description: "auto|commit:<commit_id>|file:<path>|pr:<pr_number>"
    note: "auto: uncommit → last commit"
    shorthand: "android-code-review pr:123 / file:xxx / commit:xxx"

  - name: output-format
    type: string
    required: false
    default: "markdown"
    description: "markdown|json"

  - name: severity
    type: string
    required: false
    default: "high"
    description: "critical|high|medium|all"
    note: "Controls pattern loading scope (token optimization)"
---
Comprehensive security and quality review:

1. Detect scope:

- auto → git diff --name-only HEAD
- commit:`<id>` → git show --name-only --pretty=format:"" `<id>`
- pr:`<number>` → gh pr diff `<number>` --name-only
- file:`<path>` → review specific file

2. Load:

- Agent: Android Code Reviewer
- Skill: Android Code Review

3. For each file:

- Apply checklist in skill
- Apply PR-context rules if reviewing PR

4. Generate report with:

* Severity: CRITICAL, HIGH, MEDIUM, LOW
* File location and line numbers
* Issue description
* Suggested fix
* 
5. Block commit if CRITICAL or HIGH issues found

Never approve code with security vulnerabilities!
