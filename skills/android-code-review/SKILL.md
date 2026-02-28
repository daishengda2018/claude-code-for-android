---
name: android-code-review
type: knowledge-module
description: Full Android production review rule set (always applied)
---
# Android Code Review

Always apply checklist below: 

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

**PR CONTEXT RULES (Diff-Aware) — MEDIUM**

Only apply when reviewing a change set:

* Shotgun surgery (>5 files changed for one concern)
* Divergent change (class modified for unrelated reasons)
* Commented-out code blocks
* Debug artifacts left in change
