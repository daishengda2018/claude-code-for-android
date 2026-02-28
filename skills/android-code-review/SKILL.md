---
name: android-code-review
description: Android code review rules — severity-based pattern loading and agent orchestration
---
# Android Code Review Skill

This skill provides Android code review patterns and orchestrates the agent based on severity level.

## When This Skill is Invoked

You will receive:
- **Files to review** (provided by Command)
- **Severity threshold** (critical | high | medium | all)

## Severity-Based Pattern Loading

Load detection rules based on severity:

### critical (~1,500 tokens)
Only Security patterns that cause production blockers:

**CRITICAL — Production Blockers**

* NullPointerException
* Fragment view/binding after `onDestroyView`
* Fragment transaction after state saved
* Unchecked Intent/Bundle params
* Forced cast `as`
* ConcurrentModificationException
* Background thread updating UI
* Main thread blocking I/O
* Non-static inner class
* Handler without removeCallbacks
* BroadcastReceiver not unregistered
* Fragment binding not cleared
* GlobalScope usage
* Singleton holding Activity/Context
* Observer/Receiver registered but not removed
* Adapter holding Fragment reference
* Hardcoded credentials, API keys, tokens
* Logging sensitive data
* Exported component without permission
* Implicit intent without validation
* Unsafe WebView configuration

### high (~6,900 tokens)
Security + Quality + Architecture + Jetpack:

**All CRITICAL patterns plus:**

**HIGH — Structural Decay**

* Long Method : > 80 lines
* High Cyclomatic Complexity : > 12
* Deep Nesting : > 4 levels
* Large File : > 1000 lines
* Large Class : > 500 lines or > 15 methods
* Multi-responsibility class (God object)
* Low cohesion (disjoint field usage)
* Excessive cross-class field access
* Duplicated logic (≥2 places)
* Large parameter list (>5)
* Data clumps (≥3 occurrences)
* Primitive obsession
* Type-based switch replacing polymorphism
* Temporary field (<30% method usage)
* I/O without explicit error handling
* Swallowed exception
* `try-catch` as control flow
* Network call without timeout/retry
* Public API returning nullable instead of result type

### medium (~8,100 tokens)
Above + Performance + Practices:

**All HIGH patterns plus:**

**MEDIUM — Maintainability & Best Practices**

* Business logic in UI layer
* Deep call chain (>3)
* Missing sealed types for state modeling
* Magic numbers without constants
* Exposed mutable state
* Public `var` instead of `val`
* Missing contentDescription
* Touch target <48dp

### all (~8,900 tokens)
All patterns including PR Context:

**All MEDIUM patterns plus:**

**PR CONTEXT RULES (Diff-Aware)**

Only apply when reviewing a change set:

* Shotgun surgery (>5 files changed for one concern)
* Divergent change (class modified for unrelated reasons)
* Debug artifacts left in change

## Agent Orchestration

After loading appropriate patterns, invoke `android-code-reviewer` agent with:

1. **Files to review** (from Command)
2. **Detection rules** (loaded based on severity)
3. **Context**: What to focus on based on severity level

The agent will:
- Read and analyze the provided files
- Apply the loaded detection rules
- Filter findings by confidence (>80%)
- Output structured findings in the required format

## Output Format

Present agent results in this structure:

```markdown
## Android Code Review Results

### 🔴 CRITICAL (N issues)
[Findings...]

### 🟠 HIGH (N issues)
[Findings...]

### 🟡 MEDIUM (N issues)
[Findings...]

## Review Summary

| Severity | Count | Status |
|----------|-------|--------|
| CRITICAL | N     | fail/warn/pass |
| HIGH     | N     | fail/warn/pass |
| MEDIUM   | N     | fail/warn/pass |

**Verdict**: [APPROVED/WARNING/BLOCKED]
```
