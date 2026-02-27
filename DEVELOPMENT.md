# Plugin Development Guide

This guide explains how to develop and test the `android-code-reviewer` plugin.

## Overview

This project uses a **Test-Driven Development** approach:
1. Write buggy code as test cases
2. Run plugin to detect issues
3. Optimize plugin to improve detection rate
4. Verify and release new version

## Project Structure

```
claude-code-for-android/
├── .claude/                    # Plugin source (development version)
│   ├── agents/
│   │   └── android-code-reviewer.md  # ⚠️ Edit this file
│   └── plugin-manifest.json
│
├── test-cases/                 # Test cases ✨
│   ├── 001-security-hardcoded-secrets.kt
│   ├── 002-memory-handler-leak.kt
│   └── 003-unsafe-null.kt
│
├── scripts/                    # Automation scripts
│   ├── verify-isolation.sh    # Verify plugin isolation ✨
│   ├── verify-build.sh        # Verify compilation ✨
│   ├── run-review.sh          # Run code review
│   ├── verify-plugin.sh       # Verify plugin functionality
│   ├── archive-test.sh        # Archive test cases ✨
│   └── publish-plugin.sh      # Release new version
│
├── test-android/              # Test Android project ✨
│   ├── app/src/main/java/com/test/
│   │   ├── examples/          # Correct code examples
│   │   └── bugs/              # Buggy code
│   ├── config/                # Detekt & Checkstyle configs
│   └── .claude/               # ⚠️ Must be empty!
│
└── test-cases/                # Standalone test files (quick verification)
    ├── 001-security-hardcoded-secrets.kt
    ├── 002-memory-handler-leak.kt
    └── 003-unsafe-null.kt
```

## Development Workflow

### Step 1: Write Test Case

Create a new test file in `test-cases/`:

```kotlin
// test-cases/004-my-test.kt

package com.test

// Expected Detection: HIGH
// File: test-cases/004-my-test.kt

class BadExample {
    // Intentionally buggy code
    private val leak = Handler()

    override fun onDestroy() {
        // Missing cleanup
    }
}

// Verification Checklist:
// [ ] Plugin detects Handler leak
// [ ] Plugin severity is HIGH
// [ ] Plugin suggests proper cleanup
```

### Step 2: Run Code Review

Two options:

**Option A: Use Script (Recommended)**
```bash
./scripts/run-review.sh 004-my-test
```

**Option B: Manual Execution**
In Claude Code, run:
```
/android-code-review --target file:test-cases/004-my-test.kt
```

### Step 3: Analyze Results

Check if plugin detected the issue:
- ✅ Detected → Go to Step 5
- ❌ Missed → Go to Step 4
- ⚠️ False positive → Go to Step 4

### Step 4: Improve Plugin

Edit `.claude/agents/android-code-reviewer.md`:

```markdown
## 🔍 Review Checklist

### Memory Leak Checks

Add new detection rules...
```

**Important: Restart Claude Code after modifications!**

### Step 5: Verify Improvements

Run verification script:
```bash
./scripts/verify-plugin.sh
```

Script will test all cases and confirm:
- [ ] All issues are detected
- [ ] Severity is correct
- [ ] Fix suggestions are useful

### Step 6: Real Environment Testing (Optional) ✨

Test in real Android project:

```bash
# 1. Verify isolation configuration
./scripts/verify-isolation.sh

# 2. Write/modify buggy code in test project
cd test-android/
# Edit app/src/main/java/com/test/bugs/...

# 3. Run AI Review
/android-code-review --target file:app/src/main/java/com/test/bugs/001-npe/ForceUnwrapActivity.kt

# 4. Verify compilation (Important!)
cd ../
./scripts/verify-build.sh
```

**Why verify compilation:**
- ✅ Confirm code can actually compile
- ✅ Detect plugin false positives (plugin says issue, but code compiles)
- ✅ Reduce AI token usage (script runs Gradle, not AI)

### Step 7: Release Update

When all tests pass:

```bash
./scripts/publish-plugin.sh
```

Script will automatically:
1. Update version number
2. Commit changes
3. Create git tag
4. Push to remote
5. Prompt to create GitHub release

## Plugin Isolation

### How It Works

Claude Code loads plugins in the following order:

```
1. test-android/.claude/              ← If exists, loaded first (test project)
2. (Git root)/.claude/                ← Your development version ✅
3. ~/.claude/                          ← User-installed stable version
```

**Critical Constraint:**
> ⚠️ **Important:** `test-android/.claude/` directory must **not exist** or be **empty**
>
> If test project has its own `.claude/`, it will override development version!

**Verification:**
```bash
./scripts/verify-isolation.sh
```

**Auto-verification:**
- `run-review.sh` verifies at start
- `verify-plugin.sh` verifies at start
- `verify-build.sh` does not verify (only checks compilation)

**Key Points:**
- ✅ Project-level plugin overrides user-level
- ✅ Changes only affect current project
- ✅ Does not affect other projects or marketplace
- ⚠️ Must restart Claude Code to load changes

### Three-Tier Testing System

#### **Tier 1: Standalone Files (Quick Verification)**
- Location: `test-cases/*.kt`
- Purpose: Quick verification of single detection rules
- Command: `./scripts/run-review.sh <test-id>`

#### **Tier 2: Real Android Project (Deep Testing) ✨**
- Location: `test-android/`
- Purpose: Test in real project environment
- Command: `cd test-android/ && /android-code-review --target file:...`
- Build verification: `./scripts/verify-build.sh`

#### **Tier 3: Batch Regression Testing**
- Location: `test-cases/*.kt` (all)
- Purpose: Verify all detection rules
- Command: `./scripts/verify-plugin.sh`

### Verify Isolation

```bash
# Check currently loaded plugin
ls -la .claude/agents/android-code-reviewer.md

# Compare with user-level version
ls -la ~/.claude/homunculus/evolved/agents/android-code-reviewer.md
```

## Test Coverage

Current test case coverage:

| Category | Test Case | Status |
|----------|-----------|--------|
| Security | 001-hardcoded-secrets | ✅ |
| Memory | 002-handler-leak | ✅ |
| Quality | 003-unsafe-null | ✅ |

Target coverage:
- [ ] Security: 10+ cases
- [ ] Memory: 8+ cases
- [ ] Performance: 5+ cases
- [ ] Architecture: 5+ cases
- [ ] Quality: 10+ cases

## FAQ

### Q: Plugin changes not taking effect?

**A:** Restart Claude Code:
```bash
# macOS
Quit Claude Code and reopen

# Or use command (if supported)
/claude restart
```

### Q: How to confirm using development version?

**A:** Check in project:
```bash
# Should point to project directory
ls -la .claude/agents/

# Not user directory
ls -la ~/.claude/homunculus/evolved/agents/
```

### Q: How to release after tests pass?

**A:** Run release script:
```bash
./scripts/publish-plugin.sh
```

### Q: Will this affect other marketplace users?

**A:** No! Reasons:
1. Development is project-level only
2. Users install specific marketplace versions
3. Only when you release new version can users get updates
4. Users can choose whether to update

## Development Best Practices

1. **Small Iterations**
   - Modify one detection rule at a time
   - Test and verify immediately
   - Commit code frequently

2. **Test-Driven**
   - Write test cases first
   - Implement detection logic second
   - Ensure all tests pass

3. **Documentation Sync**
   - Update docs when modifying plugin
   - Record new detection rules
   - Add example code

4. **Version Management**
   - Follow semantic versioning
   - Clear changelog for each version
   - Maintain CHANGELOG

## Example: Adding New Detection Rule

Let's add "AsyncTask leak" detection:

### 1. Write Test Case

```kotlin
// test-cases/004-async-task-leak.kt
class AsyncTaskLeak : Activity() {
    // Inner class holds Activity reference
    private inner class MyTask : AsyncTask<Void, Void, Void>() {
        override fun doInBackground(vararg params: Void?): Void? {
            // Long-running work
            Thread.sleep(5000)
            return null
        }
    }
}
```

### 2. Run Review

```bash
./scripts/run-review.sh 004-async-task-leak
```

### 3. Modify Plugin

Add to `.claude/agents/android-code-reviewer.md`:

```markdown
### AsyncTask Memory Leak Checks

```kotlin
// ❌ HIGH: Inner class AsyncTask
class LeakyActivity : Activity() {
    private inner class MyTask : AsyncTask<Void, Void, Void>() {
        // Implicit reference to Activity
    }
}

// ✅ CORRECT: Use static inner class or coroutines
class SafeActivity : Activity() {
    private class MyTask(val activityRef: WeakReference<Activity>) : AsyncTask<Void, Void, Void>() {
        override fun doInBackground(vararg params: Void?): Void? {
            activityRef.get()?.let { activity ->
                // Use activity safely
            }
            return null
        }
    }
}
```
```

### 4. Verify

```bash
./scripts/verify-plugin.sh
```

### 5. Release

```bash
./scripts/publish-plugin.sh
```

## Getting Help

- 📖 View test cases: `test-cases/`
- 🔧 Run tests: `scripts/run-review.sh`
- ✅ Verify functionality: `scripts/verify-plugin.sh`
- 🚀 Release updates: `scripts/publish-plugin.sh`

---

Happy coding! 🎉
