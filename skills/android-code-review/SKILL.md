---
name: android-code-review
description: Android code review expert. CRITICAL: Use this skill whenever the user mentions Android code, Kotlin files, Java classes, Activity, Fragment, ViewModel, Service, BroadcastReceiver, or any Android component. Trigger on phrases like "review android", "check this Kotlin", "android memory leak", "thread safety", "lifecycle issue", "CalledFromWrongThreadException", "out of memory", "app crashing", "security issue", "hardcoded secrets", or requesting code review for .kt/.java files. Analyzes memory leaks, thread safety, lifecycle problems, security vulnerabilities, null safety, coroutine issues, handler leaks, and architectural anti-patterns. Provides structured findings with severity (CRITICAL/HIGH/MEDIUM), file:line locations, code examples showing ❌ wrong vs ✅ correct patterns, impact analysis, and specific fix recommendations. Supports severity-based filtering for token efficiency. Confidence threshold: 90%+. Always use when reviewing Android/Kotlin/Java code.
---

# Android Code Review

Automated Android code review with severity-based pattern filtering and confidence scoring. Detects memory leaks, thread safety issues, lifecycle problems, security vulnerabilities, and architectural anti-patterns in Kotlin/Java Android code.

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

## Review Process

### Mode 1: Standalone Review (Direct Analysis)

Use when invoked directly without agent orchestration:

1. **Identify Input**: Determine what to review (files, commit, PR, project)
2. **Gather Context**: Read source files to analyze
3. **Load Patterns**: Based on severity threshold (default: `high`)
4. **Analyze Code**: Check loaded patterns against code
5. **Filter by Confidence**: Only report issues with 90%+ confidence
6. **Output Findings**: Use the structured format below

### Mode 2: Agent-Orchestrated Review

When `android-code-reviewer` agent is available:

1. **Load Patterns**: Based on severity threshold
2. **Invoke Agent**: Pass files + patterns + context to agent
3. **Agent Analysis**: Agent reads, analyzes, applies patterns, filters by confidence
4. **Present Results**: Output agent findings in structured format

### Default Severity Handling

If severity parameter is not provided or empty, default to `"high"`:
- Ensures consistent behavior when invoked without explicit severity
- Prevents accidental loading of all patterns (~8,900 tokens)
- Balances coverage with token efficiency

## Output Format

**ALWAYS use this exact structure** with emojis and severity indicators:

```markdown
📱 Android Code Review Results
═══════════════════════════════════════════════════════════

📊 Summary
  Files analyzed: X
  Issues found: Y (Critical: Z, High: A, Medium: B)

🔴 CRITICAL Issues (Z)
───────────────────────────────────────────────────────────
[1] Memory Leak: Static reference to Activity
   File: app/src/main/java/com/example/MyManager.kt:10
   Severity: CRITICAL
   Confidence: 95%

   Code:
   companion object {
       private var currentActivity: Activity? = null  // ❌ LEAK
   }

   Impact: This will cause memory leaks as Activity cannot be GC'd.
   When the Activity is destroyed (e.g., screen rotation), the static
   reference keeps it in memory, leading to memory leaks and OOM crashes.

   Recommendation:
   ✅ Use application context instead of Activity context
   ✅ Use WeakReference if Activity reference is necessary
   ✅ Clear reference in Activity.onDestroy()
   ✅ Consider using ViewModel for lifecycle-aware data

───────────────────────────────────────────────────────────

🟠 HIGH Severity Issues (A)
───────────────────────────────────────────────────────────
[2] Thread Safety: UI update from background thread
   File: app/src/main/java/com/example/MyFragment.kt:41
   Severity: HIGH
   Confidence: 98%

   Code:
   scope.launch {
       delay(2000)
       val result = "Data loaded"
       resultTextView?.text = result  // ❌ Wrong thread
   }

   Impact: Directly updating UI from Dispatchers.IO will crash with
   CalledFromWrongThreadException. Only the main thread can update UI.

   Recommendation:
   ✅ Use withContext(Dispatchers.Main) to switch to main thread
   ✅ Use lifecycleScope.launch (auto-cancelled on destroy)
   ✅ Use viewModelScope.launch if in ViewModel

───────────────────────────────────────────────────────────

🟡 MEDIUM Severity Issues (B)
───────────────────────────────────────────────────────────
[3] Architecture: Custom CoroutineScope instead of lifecycle-aware scope
   File: app/src/main/java/com/example/MyFragment.kt:16
   Severity: MEDIUM
   Confidence: 92%

   Code:
   private val scope = CoroutineScope(Dispatchers.IO)

   Impact: Custom scope is not lifecycle-aware and requires manual
   cancellation. This is error-prone and goes against Android best practices.

   Recommendation:
   ✅ Use lifecycleScope.launch from androidx.lifecycle:lifecycle-runtime-ktx
   ✅ For Fragment-specific scope, use viewLifecycleOwner.lifecycleScope
   ✅ For ViewModel, use viewModelScope

═══════════════════════════════════════════════════════════

✅ Top Recommendations
  1. Remove static Activity reference - use ViewModel or application context
  2. Switch to lifecycle-aware coroutine scopes (lifecycleScope)
  3. Always switch to Main thread before updating UI

📚 References
  - Memory leaks: https://developer.android.com/topic/performance/memory
  - Coroutines in Android: https://developer.android.com/kotlin/coroutines
  - Security best practices: https://developer.android.com/topic/security/best-practices
  - Threading restrictions: https://developer.android.com/guide/components/processes-and-threads
```

## Confidence Scoring

Only report issues where you are **90%+ confident** that it's a genuine problem.

**If confidence is below 90%:**
- Mark as `"POTENTIAL ISSUE"` with confidence level
- Explain why it might be a false positive
- Suggest manual review
- Example: `"POTENTIAL ISSUE (75% confidence): May cause memory leak if not properly cleaned up"`

## Code Analysis Guidelines

**For each issue found:**
- **File:line reference** - Exact location
- **Code snippet** - Show problematic code with ❌ marker
- **Impact** - Explain why this is a problem
- **Recommendation** - Specific fix with ✅ markers for correct patterns
- **Confidence** - Report confidence level

**Use contrasting patterns:**
- ❌ for incorrect/problematic code
- ✅ for correct/recommended patterns

## Severity Definitions

- **CRITICAL**: Will cause crashes, memory leaks, or security issues
- **HIGH**: Likely to cause bugs in production or violate Android best practices
- **MEDIUM**: Performance issues, code quality concerns, or potential bugs
- **LOW**: Minor issues or style violations (only report if explicitly requested via `severity=all`)

## Special Considerations

### Kotlin-Specific Checks
- Proper use of `lateinit` vs nullable
- Extension functions don't capture state (good)
- Dataclass vs regular class choice
- Proper coroutine scope management (lifecycleScope, viewModelScope)
- Flow/SharedFlow/StateFlow usage
- Inline functions and reification
- Sealed classes for state modeling

### Java-Specific Checks
- Proper try-with-resources for streams
- Optional usage for null safety
- Stream API vs traditional loops
- Synchronization and concurrent collections
- Memory leaks with static references
- Proper hashCode/equals implementation

### Architecture Checks
- ViewModel vs Activity/Fragment for data
- Repository pattern for data sources
- Dependency injection anti-patterns
- LiveData/Flow observation lifecycle awareness
- Single responsibility principle
- Separation of concerns (UI vs business logic)

## When NOT to Use

- Non-Android code (even if Kotlin/Java)
- Pure business logic that happens to run on Android
- Build scripts (gradle files) unless specifically requested
- Resource files (XML layouts, strings) unless security-related
- Reviewing generic Kotlin/Java without Android context

## Example Workflow

**Standalone mode:**
```
User: "Review this Android code"
→ Read files
→ Load patterns based on severity (default: high)
→ Analyze code
→ Output structured findings
```

**Agent-orchestrated mode:**
```
User: "Review this Android code"
→ Load patterns based on severity
→ Invoke android-code-reviewer agent with files + patterns
→ Agent analyzes and returns findings
→ Present agent results in structured format
```
