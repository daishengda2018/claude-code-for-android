# Android Code Review Plugin Validation and Enhancement Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Validate all code review scenarios through TDD, fix detected issues, and enhance plugin functionality.

**Architecture:** Create test cases for each review scenario → Execute /android-code-review command → Verify detection → Fix issues iteratively → Document results.

**Tech Stack:** Kotlin test files, android-code-reviewer agent, /android-code-review command, test-android/ Gradle project, Git workflow

---

## Phase 1: Single File Review Validation

### Task 1.1: Create Test Case for Security Issues

**Files:**
- Create: `test-cases/004-hardcoded-api-key.kt`
- Reference: `skills/android-code-review/references/sec-001-to-010-security.md`

**Step 1: Write test case with hardcoded API key**

```kotlin
// Test Case 004: Single File - Hardcoded API Key
// Expected Detection: CRITICAL (SEC-001)
package com.test.security

class ApiKeyHandler {
    // CRITICAL: Hardcoded API key in production code
    private const val API_KEY = "AIzaSyDaShEngDa2018_TEST_KEY_DO_NOT_USE"

    fun makeRequest(): String {
        return "Calling API with key: $API_KEY"
    }
}
```

**Step 2: Run review on single file**

Run: `/android-code-review --target file:test-cases/004-hardcoded-api-key.kt --severity critical`
Expected: Detection of SEC-001 (Hardcoded Secrets) with CRITICAL severity

**Step 3: Verify detection output**

Check for:
- ✅ SEC-001 rule triggered
- ✅ Severity: CRITICAL
- ✅ Suggestion: Use BuildConfig or EncryptedSharedPreferences
- ✅ Confidence score > 0.8

**Step 4: If detection fails, fix agent**

Modify: `agents/android-code-reviewer.md`
Add SEC-001 pattern to Security Checklist if missing

**Step 5: Commit test case**

```bash
git add test-cases/004-hardcoded-api-key.kt
git commit -m "test: add single file review test for hardcoded API key"
```

---

### Task 1.2: Create Test Case for Memory Leaks

**Files:**
- Create: `test-cases/005-handler-leak.kt`
- Reference: `skills/android-code-review/references/qual-001-to-010-quality.md`

**Step 1: Write test case with Handler leak**

```kotlin
// Test Case 005: Single File - Handler Memory Leak
// Expected Detection: HIGH (QUAL-002)
package com.test.quality

import android.os.Handler

class LeakyHandler {
    // HIGH: Non-static Handler holds implicit reference to Activity
    private val handler = Handler()

    fun postDelayed() {
        handler.postDelayed({
            // Do something
        }, 5000)
    }
}
```

**Step 2: Run review on single file**

Run: `/android-code-review --target file:test-cases/005-handler-leak.kt --severity high`
Expected: Detection of QUAL-002 (Memory Leak) with HIGH severity

**Step 3: Verify detection output**

Check for:
- ✅ QUAL-002 rule triggered
- ✅ Severity: HIGH
- ✅ Suggestion: Use static inner class + WeakReference
- ✅ Confidence score > 0.8

**Step 4: Commit test case**

```bash
git add test-cases/005-handler-leak.kt
git commit -m "test: add single file review test for Handler leak"
```

---

## Phase 2: Multiple Files Review Validation

### Task 2.1: Create Multiple Related Test Files

**Files:**
- Create: `test-cases/006-viewmodel-leak.kt`
- Create: `test-cases/007-coroutine-scope-leak.kt`
- Reference: `skills/android-code-review/references/qual-001-to-010-quality.md`

**Step 1: Write ViewModel leak test**

```kotlin
// Test Case 006: Multiple Files - ViewModel Leak
// Expected Detection: HIGH (QUAL-003)
package com.test.quality

import androidx.lifecycle.ViewModel

class LeakyViewModel : ViewModel() {
    // HIGH: Launching coroutine without viewModelScope
    private val scope = CoroutineScope(Dispatchers.Main)

    fun loadData() {
        scope.launch {
            // Work that may leak
        }
    }
}
```

**Step 2: Write CoroutineScope leak test**

```kotlin
// Test Case 007: Multiple Files - CoroutineScope Leak
// Expected Detection: HIGH (QUAL-004)
package com.test.quality

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class LeakyScope {
    // HIGH: CoroutineScope not tied to lifecycle
    private val scope = CoroutineScope(Dispatchers.Main)

    fun startWork() {
        scope.launch {
            // Long-running work
        }
    }
}
```

**Step 3: Run review on multiple files**

Run: `/android-code-review --target file:test-cases/006-viewmodel-leak.kt,file:test-cases/007-coroutine-scope-leak.kt --severity high`
Expected: Detection of both QUAL-003 and QUAL-004

**Step 4: Verify batch detection**

Check for:
- ✅ Both files analyzed
- ✅ QUAL-003 detected in 006
- ✅ QUAL-004 detected in 007
- ✅ Separate confidence scores for each

**Step 5: Commit test cases**

```bash
git add test-cases/006-viewmodel-leak.kt test-cases/007-coroutine-scope-leak.kt
git commit -m "test: add multiple files review tests for lifecycle leaks"
```

---

## Phase 3: Unstaged Changes Review Validation

### Task 3.1: Create Test Scenario for Unstaged Changes

**Files:**
- Create: `test-android/app/src/main/java/com/test/bugs/008-unstaged-bug/UnsafeAsyncTask.kt`
- Test: `scripts/verify-isolation.sh`

**Step 1: Create unstaged buggy file**

```kotlin
// Test Case 008: Unstaged Changes - Unsafe AsyncTask
// Expected Detection: HIGH (ARCH-003)
package com.test.bugs.unstaged

import android.os.AsyncTask

class UnsafeAsyncTask : AsyncTask<Void, Void, String>() {
    // HIGH: AsyncTask with implicit reference to Activity
    override fun doInBackground(vararg params: Void?): String {
        return "Result"
    }
}
```

**Step 2: Verify plugin isolation**

Run: `./scripts/verify-isolation.sh`
Expected: ✅ test-android/.claude/ is empty or does not exist

**Step 3: Run review on unstaged changes**

Run: `/android-code-review --target staged`
Expected: Detection of ARCH-003 (AsyncTask Usage) in unstaged file

**Step 4: Verify staged detection**

Check for:
- ✅ Unstaged file analyzed
- ✅ ARCH-003 detected
- ✅ Suggestion: Replace with Coroutines

**Step 5: Commit and archive**

```bash
git add test-android/app/src/main/java/com/test/bugs/008-unstaged-bug/
./scripts/archive-test.sh 008-unstaged-bug
git commit -m "test: add unstaged changes review test for AsyncTask"
```

---

## Phase 4: Committed Changes Review Validation

### Task 4.1: Create Test Scenario for Committed Changes

**Files:**
- Modify: `test-android/app/src/main/java/com/test/bugs/009-committed-bug/BroadcastLeak.kt`
- Test: Git commit workflow

**Step 1: Create committed buggy file**

```kotlin
// Test Case 009: Committed Changes - Broadcast Leak
// Expected Detection: HIGH (QUAL-005)
package com.test.bugs.committed

import android.content.BroadcastReceiver
import android.content.Context

class BroadcastLeak : BroadcastReceiver() {
    // HIGH: BroadcastReceiver not unregistered
    override fun onReceive(context: Context?, intent: android.content.Intent?) {
        // Handle broadcast
    }
}
```

**Step 2: Commit the buggy file**

```bash
git add test-android/app/src/main/java/com/test/bugs/009-committed-bug/
git commit -m "test: add broadcast receiver leak test"
```

**Step 3: Run review on committed changes**

Run: `/android-code-review --target commit:HEAD`
Expected: Detection of QUAL-005 (BroadcastReceiver Leak)

**Step 4: Verify commit detection**

Check for:
- ✅ Latest commit analyzed
- ✅ QUAL-005 detected
- ✅ Commit context provided in output

**Step 5: Archive test case**

```bash
./scripts/archive-test.sh 009-committed-bug
```

---

## Phase 5: Multiple Commits Review Validation

### Task 5.1: Create Test Scenario for Multiple Commits

**Files:**
- Create: `test-android/app/src/main/java/com/test/bugs/010-commit-1-bug/GlobalScope.kt`
- Create: `test-android/app/src/main/java/com/test/bugs/011-commit-2-bug/RunBlocking.kt`

**Step 1: Create first buggy file and commit**

```kotlin
// Test Case 010: Multiple Commits - GlobalScope Usage
// Expected Detection: MEDIUM (JETP-005)
package com.test.bugs.commit1

import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class GlobalScopeUsage {
    // MEDIUM: Using GlobalScope in Android app
    fun startWork() {
        GlobalScope.launch {
            // Work not tied to any lifecycle
        }
    }
}
```

```bash
git add test-android/app/src/main/java/com/test/bugs/010-commit-1-bug/
git commit -m "test: add GlobalScope usage test (commit 1/2)"
```

**Step 2: Create second buggy file and commit**

```kotlin
// Test Case 011: Multiple Commits - runBlocking Blocking Main Thread
// Expected Detection: MEDIUM (JETP-006)
package com.test.bugs.commit2

import kotlinx.coroutines.runBlocking

class BlockingMain {
    // MEDIUM: runBlocking may block main thread
    fun fetchData() {
        runBlocking {
            // Blocking operation
        }
    }
}
```

```bash
git add test-android/app/src/main/java/com/test/bugs/011-commit-2-bug/
git commit -m "test: add runBlocking test (commit 2/2)"
```

**Step 3: Run review on multiple commits**

Run: `/android-code-review --target commit:HEAD~2..HEAD`
Expected: Detection of both JETP-005 and JETP-006 across commits

**Step 4: Verify multi-commit detection**

Check for:
- ✅ Both commits analyzed
- ✅ JETP-005 detected in commit 1
- ✅ JETP-006 detected in commit 2
- ✅ Summary grouped by commit

**Step 5: Archive test cases**

```bash
./scripts/archive-test.sh 010-commit-1-bug
./scripts/archive-test.sh 011-commit-2-bug
```

---

## Phase 6: Pull Request Review Validation

### Task 6.1: Create Test Scenario for PR Review

**Files:**
- Create: `test-android/app/src/main/java/com/test/bugs/012-pr-bug/WebViewRCE.kt`
- Test: Git PR workflow

**Step 1: Create feature branch with buggy code**

```bash
git checkout -b test/pr-review-validation
```

```kotlin
// Test Case 012: PR Review - WebView RCE Vulnerability
// Expected Detection: CRITICAL (SEC-008)
package com.test.bugs.pr

import android.webkit.WebView
import android.webkit.WebSettings

class WebViewVulnerable(private val webView: WebView) {
    fun loadUrl(url: String) {
        // CRITICAL: WebView allows file:// access with JavaScript enabled
        val settings = webView.settings
        settings.javaScriptEnabled = true
        settings.allowFileAccess = true
        settings.allowUniversalAccessFromFileURLs = true

        webView.loadUrl(url)
    }
}
```

**Step 2: Commit and create PR**

```bash
git add test-android/app/src/main/java/com/test/bugs/012-pr-bug/
git commit -m "feat: add WebView URL loader (SEC-008 test case)"
git push origin test/pr-review-validation
gh pr create --title "Test PR Review Validation" --body "Testing PR review functionality"
```

**Step 3: Run review on PR**

Run: `/android-code-review --target pr:test/pr-review-validation --severity critical`
Expected: Detection of SEC-008 (WebView RCE) with CRITICAL severity

**Step 4: Verify PR detection**

Check for:
- ✅ PR changes analyzed
- ✅ SEC-008 detected
- ✅ Security-specific warnings emphasized
- ✅ PR-friendly output format

**Step 5: Merge and archive**

```bash
gh pr merge test/pr-review-validation --squash
git checkout main
git pull
./scripts/archive-test.sh 012-pr-bug
```

---

## Phase 7: Issue Fixes and Enhancement

### Task 7.1: Document All Test Results

**Files:**
- Create: `docs/test-results/2026-02-27-validation-results.md`

**Step 1: Compile test results**

Create comprehensive report with:
```markdown
# Android Code Review Plugin Validation Results

## Test Summary
- Total Tests: 12 test cases
- Scenarios Covered: 6/6 (100%)
- Detection Rate: X/Y (Z%)

## Phase 1: Single File Review
- [✅/❌] SEC-001: Hardcoded Secrets
- [✅/❌] QUAL-002: Handler Memory Leak

## Phase 2: Multiple Files Review
- [✅/❌] QUAL-003: ViewModel Leak
- [✅/❌] QUAL-004: CoroutineScope Leak

[... all phases ...]
```

**Step 2: Commit results**

```bash
git add docs/test-results/2026-02-27-validation-results.md
git commit -m "docs: add validation test results"
```

---

### Task 7.2: Fix Detection Issues

**Files:**
- Modify: `agents/android-code-reviewer.md`
- Modify: `skills/android-code-review/references/*.md`

**Step 1: Review failed detections**

Identify which rules failed to trigger and why

**Step 2: Update rule patterns**

Add missing patterns to relevant reference files:
```markdown
## SEC-008: WebView RCE Vulnerability

### Detection Pattern
- `settings.allowFileAccess = true` + `settings.javaScriptEnabled = true`
- `settings.setAllowFileAccessFromFileURLs(true)`
- `settings.setAllowUniversalAccessFromFileURLs(true)`

### Fix
```kotlin
settings.allowFileAccess = false
settings.javaScriptEnabled = false
```
```

**Step 3: Test fixes**

Re-run failed test cases to verify fixes

**Step 4: Commit fixes**

```bash
git add agents/android-code-reviewer.md skills/android-code-review/references/
git commit -m "fix: enhance detection patterns for failed test cases"
```

---

### Task 7.3: Create Automated Test Suite

**Files:**
- Create: `scripts/batch-validation.sh`

**Step 1: Create batch test script**

```bash
#!/bin/bash
# Automated validation script for all test scenarios

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🧪 Running Android Code Review Plugin Validation"
echo "================================================"

# Phase 1: Single File Review
echo ""
echo "Phase 1: Single File Review"
/android-code-review --target file:test-cases/004-hardcoded-api-key.kt --severity critical
/android-code-review --target file:test-cases/005-handler-leak.kt --severity high

# Phase 2: Multiple Files Review
echo ""
echo "Phase 2: Multiple Files Review"
/android-code-review --target file:test-cases/006-viewmodel-leak.kt,file:test-cases/007-coroutine-scope-leak.kt --severity high

[... all phases ...]

echo ""
echo "✅ Validation complete!"
```

**Step 2: Make script executable**

```bash
chmod +x scripts/batch-validation.sh
```

**Step 3: Run full validation**

```bash
./scripts/batch-validation.sh | tee docs/test-results/2026-02-27-automated-validation.log
```

**Step 4: Commit automation**

```bash
git add scripts/batch-validation.sh
git commit -m "feat: add automated validation test suite"
```

---

### Task 7.4: Create Documentation

**Files:**
- Create: `docs/workflows/code-review-testing-guide.md`

**Step 1: Write comprehensive testing guide**

```markdown
# Code Review Plugin Testing Guide

## Overview
This guide explains how to test the Android Code Review Plugin using TDD methodology.

## Prerequisites
- Claude Code installed with plugin
- test-android/ Gradle project configured
- Git repository initialized

## Test Scenarios

### 1. Single File Review
Purpose: Test basic detection on individual files

Steps:
1. Create test file in test-cases/
2. Run: `/android-code-review --target file:test-cases/XXX.kt`
3. Verify detection output

[... all scenarios ...]
```

**Step 2: Commit documentation**

```bash
git add docs/workflows/code-review-testing-guide.md
git commit -m "docs: add code review testing guide"
```

---

## Phase 8: Enhanced Features

### Task 8.1: Implement Auto-Fix Suggestions

**Files:**
- Modify: `agents/android-code-reviewer.md`
- Modify: `commands/android-code-review.md`

**Step 1: Add auto-fix capability to agent**

Update agent to provide fix suggestions:
```markdown
## Auto-Fix Suggestions

For each detected issue, provide:
1. **Problem**: Clear explanation
2. **Solution**: Correct code example
3. **Refactoring Command**: If applicable, exact Edit tool command

Example:
### QUAL-002: Handler Memory Leak
**Problem**: Non-static Handler holds implicit reference to Activity
**Solution**: Use static inner class with WeakReference
```kotlin
private static class MyHandler(private val activity: WeakReference<Activity>) : Handler() {
    override fun handleMessage(msg: Message) {
        activity.get()?.let {
            // Safe to use activity
        }
    }
}
```
**Refactoring**: Provide step-by-step instructions
```

**Step 2: Test auto-fix on test case 005**

Run: `/android-code-review --target file:test-cases/005-handler-leak.kt --fix-suggestions`
Expected: Detailed fix instructions included

**Step 3: Commit enhancement**

```bash
git add agents/android-code-reviewer.md commands/android-code-review.md
git commit -m "feat: add auto-fix suggestions to review output"
```

---

### Task 8.2: Create CI Integration

**Files:**
- Create: `.github/workflows/android-review.yml`

**Step 1: Create GitHub Actions workflow**

```yaml
name: Android Code Review

on:
  pull_request:
    paths:
      - '**.kt'
      - '**.java'

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Claude Code
        run: |
          curl -fsSL https://claude.ai/code/install.sh | sh
      - name: Run Android Code Review
        run: |
          claude-code plugin install daishengda2018/claude-code-for-android
          claude-code android-code-review --target pr:${{ github.event.number }} --output-format json
      - name: Upload Results
        uses: actions/upload-artifact@v3
        with:
          name: review-results
          path: review-results.json
```

**Step 2: Test CI workflow**

```bash
git add .github/workflows/android-review.yml
git commit -m "feat: add CI workflow for automated PR reviews"
git push
```

**Step 3: Verify on test PR**

Create test PR and check Actions tab

---

## Success Criteria

**Phase 1-6 (Testing):**
- ✅ All 6 review scenarios tested
- ✅ Detection rate > 90%
- ✅ All test cases documented

**Phase 7 (Fixes):**
- ✅ All failed detections fixed
- ✅ Automated test suite working
- ✅ Comprehensive documentation

**Phase 8 (Enhancement):**
- ✅ Auto-fix suggestions implemented
- ✅ CI integration working
- ✅ Complete testing workflow

---

## Notes

- **TDD Methodology**: Write test case first, run review, verify, then fix if needed
- **Isolation**: Always verify test-android/.claude/ is empty before testing
- **Build Verification**: Run `./scripts/verify-build.sh` after code changes to reduce false positives
- **Progressive Loading**: Use `--severity` flag to test different rule sets efficiently
- **Token Efficiency**: Start with `--severity critical`, expand as needed

---

## Handoff to Execution

**Plan complete and saved to `docs/plans/2026-02-27-android-plugin-validation-plan.md`.**

**Two execution options:**

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration
**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?**
