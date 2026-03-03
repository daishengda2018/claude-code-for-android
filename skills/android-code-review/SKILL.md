---
name: android-code-review
description: Android code review expert. CRITICAL: Use this skill whenever the user mentions Android code, Kotlin files, Java classes, Activity, Fragment, ViewModel, Service, BroadcastReceiver, or any Android component. Trigger on phrases like "review android", "check this Kotlin", "android memory leak", "thread safety", "lifecycle issue", "CalledFromWrongThreadException", "out of memory", "app crashing", "security issue", "hardcoded secrets", or requesting code review for .kt/.java files. Analyzes memory leaks, thread safety, lifecycle problems, security vulnerabilities, null safety, coroutine issues, handler leaks, and architectural anti-patterns. Provides structured findings with severity (CRITICAL/HIGH/MEDIUM), file:line locations, code examples showing ❌ wrong vs ✅ correct patterns, impact analysis, and specific fix recommendations. Supports severity-based filtering for token efficiency. Confidence threshold: 90%+. Always use when reviewing Android/Kotlin/Java code.
---

# Android Code Review Skill

This skill provides detection rules and output templates for Android code review. The actual analysis is performed by the `android-code-reviewer` agent.

## Responsibility Separation

- **Skill**: Detection rules, severity filtering, output templates, confidence guidelines
- **Agent**: Code reading, pattern application, report generation
- **Command**: File collection, orchestration

## When to Use

Trigger this skill when:
- User explicitly requests Android code review: **"review android code"**, **"android review"**, **"check this Kotlin file"**
- User is working in an Android project (contains `AndroidManifest.xml`, `build.gradle` with Android plugins, standard Android source structure)
- User asks to review specific **.kt** or **.java** files
- Analyzing commits or PRs that touch Android code
- User mentions Android-specific components: **Activity**, **Fragment**, **ViewModel**, **Service**, **BroadcastReceiver**

## Detection: Android Project

An Android project is identified by:
- **Primary**: `AndroidManifest.xml` file exists
- **Secondary**: `build.gradle` or `build.gradle.kts` with Android plugins (`com.android.application`, `com.android.library`)
- **Structure**: Standard Android source directories (`app/src/main/`, `src/main/java/`)

## Severity-Based Pattern Loading

Load detection rules based on severity threshold to optimize token usage:

### critical (~1,500 tokens)
**Production blockers only - Security and crash-causing issues:**

**Memory Leaks:**
- Static references to Activity/Fragment
- Handler without removeCallbacks
- Non-static inner class holding outer reference
- Singleton holding Activity/Context
- Adapter holding Fragment reference
- Observer/Receiver registered but not removed
- Fragment binding not cleared in onDestroyView
- BroadcastReceiver not unregistered
- GlobalScope usage (lifecycle unaware)

**Thread Safety:**
- Background thread updating UI (CalledFromWrongThreadException)
- Main thread blocking I/O
- ConcurrentModificationException risks

**Lifecycle Issues:**
- Fragment view/binding access after `onDestroyView`
- Fragment transaction after state saved
- Lifecycle-aware operations without proper observation

**Null Safety:**
- Unchecked Intent/Bundle parameters
- Forced cast `as` without null check
- NullPointerException risks

**Security (CRITICAL):**
- Hardcoded credentials, API keys, tokens
- Logging sensitive data (passwords, tokens, PII)
- Exported component without permission
- Implicit intent without validation
- Unsafe WebView configuration

### high (~6,900 tokens)
**All CRITICAL patterns plus:**

**Code Quality Issues:**
- Long Method: > 80 lines
- High Cyclomatic Complexity: > 12
- Deep Nesting: > 4 levels
- Large File: > 1000 lines
- Large Class: > 500 lines or > 15 methods
- Multi-responsibility class (God object)
- Low cohesion (disjoint field usage)
- Excessive cross-class field access
- Duplicated logic (≥2 places)
- Large parameter list (>5)
- Data clumps (≥3 occurrences)
- Primitive obsession
- Type-based switch replacing polymorphism
- Temporary field (<30% method usage)

**Error Handling:**
- I/O without explicit error handling
- Swallowed exception (empty catch block)
- `try-catch` as control flow
- Network call without timeout/retry
- Public API returning nullable instead of result type

**Architecture:**
- Business logic in UI layer
- Deep call chain (>3)
- Missing sealed types for state modeling

### medium (~8,100 tokens)
**All HIGH patterns plus:**

**Best Practices:**
- Magic numbers without constants
- Exposed mutable state
- Public `var` instead of `val` (Kotlin)
- Missing contentDescription (accessibility)
- Touch target <48dp (usability)

### all (~8,900 tokens)
**All MEDIUM patterns plus:**

**PR Context Rules (Diff-Aware):**
- Shotgun surgery (>5 files changed for one concern)
- Divergent change (class modified for unrelated reasons)
- Debug artifacts left in change

---

## Confidence Guidelines

**CRITICAL: >90% confidence threshold**

Only report issues where you are **90%+ confident** that it's a genuine problem.

### Report Criteria ✅
- Clear violations (e.g., hardcoded API key, missing null check)
- Android lifecycle mistakes (e.g., Fragment after onDestroyView)
- Thread safety issues (e.g., background thread updating UI)
- Memory leaks (e.g., non-static inner class holding Activity)

### Skip Criteria ❌
- Stylistic preferences (unless violates project conventions)
- Issues in unchanged code (unless CRITICAL security)
- Speculative concerns without evidence
- Unseen code assumptions
- Version numbers in `*.gradle` / `*.gradle.kts` files
- Build configuration constants (versionCode, versionName, minSdk, targetSdk, etc.)
- Commented-out code blocks

### Confidence Below 90%
- Mark as `"POTENTIAL ISSUE"` with confidence level
- Explain why it might be a false positive
- Suggest manual review

---

## Output Format Template

**ALWAYS use this exact structure** with emojis and severity indicators:

```markdown
📱 Android Code Review Results
═══════════════════════════════════════════════════════════

📊 Summary
  Files analyzed: X
  Issues found: Y (Critical: Z, High: A, Medium: B)

🔴 CRITICAL Issues (Z)
───────────────────────────────────────────────────────────
[1] [Category]: [Issue Title]
   File: path/to/file.kt:line
   Severity: CRITICAL
   Confidence: XX%

   Code:
   ```kotlin
   // ❌ problematic code
   ```

   Impact: [Why this is a problem]

   Recommendation:
   ```kotlin
   // ✅ fixed code
   ```

───────────────────────────────────────────────────────────

🟠 HIGH Severity Issues (A)
───────────────────────────────────────────────────────────
[Same structure as CRITICAL]

🟡 MEDIUM Severity Issues (B)
───────────────────────────────────────────────────────────
[Same structure as CRITICAL]

═══════════════════════════════════════════════════════════

✅ Top Recommendations
  1. [Priority fix 1]
  2. [Priority fix 2]
  3. [Priority fix 3]

📚 References
  - Memory leaks: https://developer.android.com/topic/performance/memory
  - Coroutines in Android: https://developer.android.com/kotlin/coroutines
  - Security best practices: https://developer.android.com/topic/security/best-practices
  - Threading restrictions: https://developer.android.com/guide/components/processes-and-threads


### Review Summary Format

Always end with:

```markdown
## Review Summary

| Severity | Count | Status |
|----------|-------|--------|
| CRITICAL | 0     | pass   |
| HIGH     | 2     | warn   |
| MEDIUM   | 3     | info   |

**Verdict**: WARNING — 2 HIGH issues should be resolved before merge.
```

**Verdict criteria**:
- **APPROVED**: No CRITICAL or HIGH issues
- **WARNING**: HIGH issues only (can merge with caution)
- **BLOCKED**: CRITICAL issues found — must fix before merge

---

## Severity Definitions

- **CRITICAL**: Will cause crashes, memory leaks, or security issues
- **HIGH**: Likely to cause bugs in production or violate Android best practices
- **MEDIUM**: Performance issues, code quality concerns, or potential bugs
- **LOW**: Minor issues or style violations (only report if explicitly requested via `severity=all`)

---

## Default Severity Handling

If severity parameter is not provided or empty, default to `"high"`:
- Ensures consistent behavior when invoked without explicit severity
- Prevents accidental loading of all patterns (~8,900 tokens)
- Balances coverage with token efficiency

---

## Kotlin-Specific Checks

- Proper use of `lateinit` vs nullable
- Extension functions don't capture state (good)
- Dataclass vs regular class choice
- Proper coroutine scope management (lifecycleScope, viewModelScope)
- Flow/SharedFlow/StateFlow usage
- Inline functions and reification
- Sealed classes for state modeling

## Java-Specific Checks

- Proper try-with-resources for streams
- Optional usage for null safety
- Stream API vs traditional loops
- Synchronization and concurrent collections
- Memory leaks with static references
- Proper hashCode/equals implementation

## Architecture Checks

- ViewModel vs Activity/Fragment for data
- Repository pattern for data sources
- Dependency injection anti-patterns
- LiveData/Flow observation lifecycle awareness
- Single responsibility principle
- Separation of concerns (UI vs business logic)

---

## When NOT to Use

- Non-Android code (even if Kotlin/Java)
- Pure business logic that happens to run on Android
- Build scripts (gradle files) unless specifically requested
- Resource files (XML layouts, strings) unless security-related
- Reviewing generic Kotlin/Java without Android context

---

## Agent Integration

When `android-code-reviewer` agent is available, invoke it with:

1. **Files to review** (file paths)
2. **Severity threshold** (from parameter)
3. **This skill's rules** (based on severity level)
4. **Output format template** (from above)

The agent will:
- Read and analyze each file
- Apply detection rules from this skill
- Filter by 90% confidence threshold
- Output findings using the template above

---

## Example Usage

**Standalone mode (Skill only):**
```
User: "What are the critical patterns for Android memory leaks?"
→ Skill provides memory leak detection rules
```

**Agent-orchestrated mode:**
```
User: "/android-code-review --target file:test.kt --severity high"
→ Command collects files
→ Skill loads HIGH detection rules
→ Agent analyzes and outputs results using skill template
```