# Android Review checklist

This document defines review checklist only.
No orchestration logic.

---

## 🔴 CRITICAL — Production Blockers

### Crash

- NullPointerException / !!
- Fragment binding used after onDestroyView
- Fragment transaction after state saved
- Unchecked Intent/Bundle parameters
- Unsafe cast `as`
- ConcurrentModificationException
- UI updated from background thread
- Blocking I/O on main thread

### Memory Leak

- Non-static inner class
- Handler without removeCallbacks
- BroadcastReceiver not unregistered
- Fragment binding not cleared
- GlobalScope usage
- Singleton holding Activity/Context
- Observer not removed
- Adapter holding Fragment reference

### Security

- Hardcoded credentials or API keys
- Logging sensitive data
- Exported component without permission
- Implicit intent without validation
- Unsafe WebView configuration

---

## 🟠 HIGH — Structural Decay

### Complexity

- Method > 80 lines
- Cyclomatic complexity > 12
- Nesting > 4
- Class > 500 lines or > 15 methods
- File > 1000 lines

### Responsibility & Cohesion

- Multi-responsibility class
- Low cohesion
- Excessive cross-class field access

### Modeling

- Duplicated logic (≥2 places)
- Parameter list > 5
- Data clumps ≥3
- Primitive obsession
- Type-based switch replacing polymorphism
- Temporary field (<30% usage)

### Robustness

- I/O without explicit error handling
- Swallowed exception
- try-catch used as control flow
- Network without timeout/retry
- Public API returning nullable instead of result type

---

## 🟡 MEDIUM — Maintainability

### Architecture Discipline

- Business logic in UI layer
- Deep call chain (>3)
- Missing sealed state modeling
- Magic numbers

### Immutability

- Exposed mutable state
- Public var instead of val

### Accessibility

- Missing contentDescription
- Touch target <48dp

---

## 🔵 PR Context Rules

Apply only when reviewing diffs:

- Shotgun surgery (>5 files for one concern)
- Divergent change
- Commented-out code
- Debug artifacts





Comprehensive security and quality review:

1. Determine changed files:

- --taget==auto: git diff --name-only HEAD
- --taget==commit: git show --name-only --pretty=format:"" <commit_id>
- --taget==pr: gh pr diff <pr_number> --name-only

2. For each detected file, apply pattern-based analysis:


**CRITICAL — Production Blockers**

Crash

* NullPointerException
* Fragment view/binding after `onDestroyView`
* Fragment transaction after state saved
* Unchecked Intent/Bundle params
* Forced cast `as`
* ConcurrentModificationException
* Background thread updating UI
* Main thread blocking I/O

Memory Leak

* Non-static inner class
* Handler without removeCallbacks
* BroadcastReceiver not unregistered
* Fragment binding not cleared
* GlobalScope usage
* Singleton holding Activity/Context
* Observer/Receiver registered but not removed
* Adapter holding Fragment reference

Security

* Hardcoded credentials, API keys, tokens
* Logging sensitive data
* Exported component without permission
* Implicit intent without validation
* Unsafe WebView configuration

**HIGH — Structural Decay**

Complexity

* Long Method : > 80 lines
* High Cyclomatic Complexity : > 12
* Deep Nesting : > 4 levels
* Large File : > 1000 lines
* Large Class : > 500 lines or > 15 methods
* Duplicate logic across modules
  Responsibility & Cohesion
* Multi-responsibility class (God object)
* Low cohesion (disjoint field usage)
* Excessive cross-class field access

Modeling

* Duplicated logic (≥2 places)
* Large parameter list (>5)
* Data clumps (≥3 occurrences)
* Primitive obsession
* Type-based switch replacing polymorphism
* Temporary field (<30% method usage)

Robustness

* I/O without explicit error handling
* Swallowed exception
* `try-catch` as control flow
* Network call without timeout/retry
* Public API returning nullable instead of result type

**MEDIUM — Maintainability & Best Practices**

Architecture Discipline

* Business logic in UI layer
* Deep call chain (>3)
* Missing sealed types for state modeling
* Magic numbers without constants

Immutability

* Exposed mutable state
* Public `var` instead of `val`

Accessibility

* Missing contentDescription
* Touch target <48dp

**MEDIUM — PR CONTEXT RULES (Diff-Aware)**

Only apply when reviewing a change set:

* Shotgun surgery (>5 files changed for one concern)
* Divergent change (class modified for unrelated reasons)
* Commented-out code blocks
* Debug artifacts left in change
