# Android Test Project Integration Design

**Date:** 2026-02-27
**Author:** Brainstorming session with user
**Status:** ✅ Approved

## Overview

Design a development workflow that integrates a real Android project for testing the `android-code-reviewer` plugin, with proper isolation from the user-installed version.

## Goals

1. **Real Environment Testing**: Test plugin in actual Android project structure
2. **Plugin Isolation**: Development version isolated from user-installed version
3. **Automated Verification**: Automatic checks for proper configuration
4. **Efficient Workflow**: Mix of quick file-based tests and real project tests
5. **Stress Testing**: Validate plugin performance with large codebases

---

## Architecture

### Project Structure

```
claude-code-for-android/              ← Git repository root
├── .claude/                          ← Plugin development area
│   ├── agents/
│   │   └── android-code-reviewer.md  ← Modify this file
│   └── plugin-manifest.json
│
├── test-android/                     ← Real Android test project
│   ├── app/
│   │   └── src/main/java/
│   │       ├── examples/             ← Example: correct code
│   │       └── bugs/                 ← Test: buggy code
│   ├── stress/                       ← Stress testing (100+ issues)
│   └── .claude/                      ← ⚠️ Must be empty or not exist
│
├── test-cases/                       ← Standalone .kt test files
│   ├── 001-security-*.kt
│   └── ...
│
├── scripts/
│   ├── verify-isolation.sh           ← NEW: Check isolation
│   ├── run-review.sh                 ← Enhanced: Auto-verify
│   ├── verify-plugin.sh              ← Enhanced: Auto-verify
│   └── publish-plugin.sh
│
└── docs/
    ├── workflows/
    │   └── development-cycle.md      ← NEW: Workflow docs
    └── plans/
        └── 2026-02-27-*.md           ← This document
```

### Plugin Isolation Mechanism

```
Claude Code Plugin Loading Priority:
┌────────────────────────────────────────┐
│ 1. test-android/.claude/               │ ← Must be empty/not exist
│ 2. (Git root)/.claude/                 │ ← Loads your development version ✅
│ 3. ~/.claude/                          │ ← User-installed stable version
└────────────────────────────────────────┘
```

**Critical Constraint:**
> ⚠️ `test-android/.claude/` directory must **not exist** or be **empty**
>
> If it exists and contains files, it will override the development plugin.

---

## Development Workflow

### Complete Development Cycle

```
┌─────────────────────────────────────────────────────┐
│ Phase 1: Quick Verification (Standalone files)     │
├─────────────────────────────────────────────────────┤
│ 1. Write/modify test case in test-cases/           │
│ 2. Run: ./scripts/verify-plugin.sh                 │
│ 3. Batch verify all detection rules               │
│ 4. If failed, modify .claude/agents/ and repeat    │
└─────────────────────────────────────────────────────┘
                    ↓ All pass
┌─────────────────────────────────────────────────────┐
│ Phase 2: Real Environment Test (Android project)   │
├─────────────────────────────────────────────────────┤
│ 1. cd test-android/                                 │
│ 2. Write buggy code in app/src/main/java/bugs/     │
│ 3. Run: /android-code-review --target file:...    │
│ 4. Verify detection accuracy and fix suggestions   │
│ 5. Test complex scenarios (multi-file, cross-module)│
└─────────────────────────────────────────────────────┘
                    ↓ Satisfied
┌─────────────────────────────────────────────────────┐
│ Phase 3: Stress Testing (Large codebase)           │
├─────────────────────────────────────────────────────┤
│ 1. cd test-android/stress/003-large-batch/         │
│ 2. Run: /android-code-review --target all          │
│ 3. Verify:                                          │
│    - Performance: < 30s for 50+ files              │
│    - Accuracy: False positive < 5%                 │
│    - Priority: Issues sorted by severity           │
└─────────────────────────────────────────────────────┘
                    ↓ All good
┌─────────────────────────────────────────────────────┐
│ Phase 4: Release (Automated)                        │
├─────────────────────────────────────────────────────┤
│ 1. Return to root directory                        │
│ 2. Run: ./scripts/publish-plugin.sh                │
│ 3. Auto: Update version, commit, tag, push         │
│ 4. Create GitHub Release                           │
└─────────────────────────────────────────────────────┘
```

### Daily Iteration Workflow (Most Common)

```
Developing a new detection rule:

1. Write test case
   └─ test-cases/004-new-rule.kt

2. Run quick verification
   └─ ./scripts/run-review.sh 004-new-rule

3. Modify Plugin
   └─ Edit .claude/agents/android-code-reviewer.md

4. Restart Claude Code
   └─ Required step! Changes take effect after restart

5. Re-verify
   └─ ./scripts/run-review.sh 004-new-rule

6. Real environment test (optional, for complex rules)
   └─ cd test-android/ && write bug code & test

7. Publish when done
   └─ ./scripts/publish-plugin.sh
```

---

## Testing Strategy

### Three-Tier Testing System

#### **Tier 1: Standalone Files (Quick Verification)**

**Location:** `test-cases/`

**Purpose:**
- ✅ Quick verification of single detection rules
- ✅ Batch regression testing
- ✅ Fast iteration

**Format:**
```kotlin
// test-cases/004-async-task-leak.kt

// Expected Detection: HIGH
// Category: Memory
// Description: AsyncTask with inner class holding Activity reference

package com.test.memory

class AsyncTaskLeak : Activity() {
    // BUG: Inner class holds implicit reference
    private inner class MyTask : AsyncTask<Void, Void, Void>() {
        override fun doInBackground(vararg params: Void?): Void? {
            Thread.sleep(5000)
            return null
        }
    }
}

// Verification Checklist:
// [ ] Plugin detects inner class AsyncTask
// [ ] Plugin severity is HIGH
// [ ] Plugin suggests static inner class or coroutines
```

**Usage:**
```bash
./scripts/run-review.sh 004
```

---

#### **Tier 2: Real Android Project (Deep Testing)**

**Location:** `test-android/bugs/`

**Purpose:**
- ✅ Test with real Android project context (R files, BuildConfig)
- ✅ Test cross-file references
- ✅ Validate complex scenarios (multi-Activity, Fragment)

**Structure:**
```
test-android/
└── app/src/main/java/com/test/
    ├── examples/           ← Correct examples
    │   ├── SafeActivity.kt
    │   └── ProperViewModel.kt
    │
    └── bugs/               ← Buggy code
        ├── 001/
        │   └── HandlerLeakActivity.kt
        ├── 002/
        │   └── HardcodedSecretsFragment.kt
        └── README.md       ← Description of each issue
```

**Usage:**
```bash
cd test-android/
/android-code-review --target file:app/src/main/java/com/test/bugs/001/HandlerLeakActivity.kt
```

---

#### **Tier 3: Stress Testing (Performance & Accuracy)**

**Location:** `test-android/stress/`

**Purpose:**
- ✅ Performance testing (50+ files)
- ✅ Noise control validation (false positive rate)
- ✅ Priority sorting verification
- ✅ Confidence filtering check

**Structure:**
```
test-android/stress/
├── 001-small-batch/     ← 10 files, 20 issues
├── 002-medium-batch/    ← 30 files, 50 issues
├── 003-large-batch/     ← 50 files, 100 issues
└── README.md
```

**Acceptance Criteria:**
- Performance: < 30s for 50+ files
- Accuracy: False positive rate < 5%
- Completeness: No missed critical issues
- Readability: Clear report, easy to understand

**Usage:**
```bash
cd test-android/stress/003-large-batch/
/android-code-review --target all
```

---

## Scripts & Automation

### New Scripts

#### **verify-isolation.sh**

Verifies plugin isolation configuration.

```bash
#!/bin/bash
# Returns 0=pass, 1=fail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_PROJECT="$PROJECT_ROOT/test-android"

QUIET=${1:-""}

if [ -d "$TEST_PROJECT/.claude" ] && [ "$(ls -A $TEST_PROJECT/.claude 2>/dev/null)" ]; then
    if [ -z "$QUIET" ]; then
        echo "❌ Isolation check FAILED"
        echo "   test-android/.claude/ exists and contains files"
        echo "Remove with: rm -rf $TEST_PROJECT/.claude"
    fi
    exit 1
fi

if [ -z "$QUIET" ]; then
    echo "✓ Plugin isolation OK"
fi
exit 0
```

**Features:**
- `--quiet` mode for script integration
- Clear error messages
- Standard exit codes

---

### Enhanced Scripts

#### **run-review.sh** (Enhanced)

Auto-verify isolation before running:

```bash
#!/bin/bash
set -e  # Abort on any error

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Auto-verify isolation
if ! bash "$PROJECT_ROOT/scripts/verify-isolation.sh" --quiet; then
    echo ""
    echo "❌ Cannot proceed: Plugin isolation check failed"
    echo "   Run './scripts/verify-isolation.sh' for details"
    exit 1
fi

# Rest of script...
```

#### **verify-plugin.sh** (Enhanced)

Same integration as `run-review.sh`.

---

### Call Flow

```
User runs:
  ./scripts/run-review.sh 001
    ↓
Script auto:
  verify-isolation.sh --quiet
    ↓ fail
  ❌ Abort, show error
    ↓ success
  ✓ Continue to test
```

---

## Archive Management

### Archival Strategy

**When to archive:**
- ✅ Test case verified (plugin detects correctly)
- ✅ Covered by new version
- ✅ No longer needed for daily regression

**Archive location:**
```
bugs-archive/
├── 2026-02/           ← By month
│   ├── handler-leak-v1/
│   └── hardcoded-secrets-v1/
└── 2026-03/
    └── ...
```

**Archive script:**
```bash
#!/bin/bash
# scripts/archive-test.sh

TEST_ID=$1
BUGS_DIR="test-android/bugs"
ARCHIVE_DIR="test-android/bugs-archive/$(date +%Y-%m)"

mkdir -p "$ARCHIVE_DIR"

if [ -d "$BUGS_DIR/$TEST_ID" ]; then
    mv "$BUGS_DIR/$TEST_ID" "$ARCHIVE_DIR/"
    echo "✓ Archived $TEST_ID to $ARCHIVE_DIR/"
fi
```

---

## Error Handling

### Common Error Scenarios

#### **1. Plugin Isolation Failed**

**Error:**
```bash
❌ test-android/.claude/ exists and contains files
```

**Solution:**
```bash
rm -rf test-android/.claude/
```

#### **2. Test File Not Found**

**Error:**
```bash
❌ Test case not found: 999
Available: 001, 002, 003
```

#### **3. Plugin Changes Not Effective**

**Cause:** Claude Code cached plugin

**Solution:**
```bash
⚠️ Important: Restart Claude Code after modifying plugin
macOS: Cmd+Q to fully quit, then reopen
```

#### **4. Version Conflict**

**Error:**
```bash
❌ Tag v1.0.1 already exists
Suggested: 1.0.2
```

#### **5. Git Working Directory Dirty**

**Error:**
```bash
❌ Working directory is not clean
Uncommitted changes:
  M .claude/agents/android-code-reviewer.md
```

---

## Documentation Updates

### Files to Update

1. **DEVELOPMENT.md** - Add Android test project section
2. **test-android/README.md** - Test project usage guide
3. **scripts/README.md** - Script documentation
4. **test-android/stress/README.md** - Stress testing guide

### Key Documentation Points

- ⚠️ Emphasize `test-android/.claude/` must be empty
- 🔄 Clear workflow diagrams
- 📊 Performance benchmarks
- 🛠️ Troubleshooting guide

---

## Data Flow

```
Test Case Creation
  ↓
Environment Verification (auto)
  ↓
Run Code Review (in Claude Code)
  ↓
Analyze Results
  ├─ ✅ Detected → Record pass
  ├─ ❌ Missed → Improve plugin
  └─ ⚠️ False positive → Adjust rules
  ↓
Modify Plugin (if needed)
  ↓
Restart Claude Code
  ↓
Re-verify (loop back)
  ↓
Publish (when all tests pass)
```

---

## Implementation Checklist

- [ ] Create `scripts/verify-isolation.sh`
- [ ] Enhance `scripts/run-review.sh` with auto-verify
- [ ] Enhance `scripts/verify-plugin.sh` with auto-verify
- [ ] Create `test-android/` project structure
- [ ] Create `test-android/stress/` directories
- [ ] Update `DEVELOPMENT.md`
- [ ] Create `test-android/README.md`
- [ ] Create `test-android/stress/README.md`
- [ ] Create `scripts/README.md`
- [ ] Create `scripts/archive-test.sh`
- [ ] Create `docs/workflows/development-cycle.md`

---

## Success Criteria

- ✅ Plugin isolation works correctly
- ✅ All scripts auto-verify isolation
- ✅ Three-tier testing system functional
- ✅ Stress testing validates performance
- ✅ Archive management organized
- ✅ Documentation clear and complete
- ✅ Error handling comprehensive

---

**Next Steps:** Ready to set up for implementation?
