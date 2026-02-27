# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Claude Code plugin** for automated Android code review. It provides:
- `/android-code-review` command - User-facing command for reviewing code
- `android-code-reviewer` agent - AI agent that performs the actual code analysis

**Plugin Architecture:**
```
User runs: /android-code-review --target file:app/src/main/java/...
       ↓
Command invokes: android-code-reviewer agent
       ↓
Agent analyzes: Kotlin/Java code using Read/Grep/Glob tools
       ↓
Agent outputs: Structured review findings with severity levels
```

## Critical Constraint: Plugin Isolation

**⚠️ IMPORTANT:** The `test-android/.claude/` directory **must not exist** or be **empty**.

Claude Code loads plugins in this priority order:
1. Project-level: `test-android/.claude/` (if exists)
2. Git root: `.claude/` ← Your development version
3. User-level: `~/.claude/` (marketplace-installed)

If `test-android/.claude/` contains files, it will override your development version!

**Always verify isolation before testing:**
```bash
./scripts/verify-isolation.sh
```

Scripts `run-review.sh` and `verify-plugin.sh` auto-verify isolation on startup.

## Three-Tier Testing System

### Tier 1: Standalone Files (Quick Verification)
- **Location:** `test-cases/*.kt`
- **Purpose:** Fast verification of single detection rules
- **Usage:** `/android-code-review --target file:test-cases/<file>.kt`

### Tier 2: Real Android Project (Deep Testing)
- **Location:** `test-android/`
- **Purpose:** Test in real project environment with actual Gradle build
- **Usage:**
  ```bash
  cd test-android/
  /android-code-review --target file:app/src/main/java/com/test/bugs/...
  cd ../
  ./scripts/verify-build.sh  # Verify code compiles
  ```

### Tier 3: Batch Regression Testing
- **Location:** All `test-cases/*.kt` files
- **Purpose:** Verify all detection rules still work
- **Method:** Manually run review on each test file

## Build Verification (Reduce AI Token Usage)

Use `verify-build.sh` script to run Gradle compilation without AI involvement:
```bash
./scripts/verify-build.sh
```

**Why:** Detects plugin false positives (code compiles but AI reports issues) and reduces token consumption.

**Exit codes:**
- `0` = Build SUCCESS (plugin may have false positive)
- `1` = Build FAILED (plugin detection is correct)

## Development Workflow

### 1. Write Test Case
Create file in `test-cases/` with intentional bug:
```kotlin
// test-cases/004-my-test.kt
// Expected Detection: HIGH
class BadExample {
    private val leak = Handler()  // Missing cleanup
}
```

### 2. Run AI Review
In Claude Code, run directly:
```
/android-code-review --target file:test-cases/004-my-test.kt
```

### 3. Modify Plugin Detection Rules
Edit `agents/android-code-reviewer.md` or `skills/android-code-review/SKILL.md`:
- Add new patterns to Review Checklist sections
- Update code examples
- **⚠️ Restart Claude Code after changes**

### 4. Verify in Real Project
```bash
cd test-android/
# Write buggy code in app/src/main/java/com/test/bugs/
/android-code-review --target file:app/src/main/java/com/test/bugs/...
cd ../
./scripts/verify-build.sh
```

### 5. Batch Verification
Manually run review on all test cases:
```bash
for file in test-cases/*.kt; do
    /android-code-review --target file:$file
done
```

### 6. Release
```bash
./scripts/publish-plugin.sh
```

## Static Analysis Configurations

The project includes migrated static analysis configs from WeShare-Android:

- **Detekt** (`static-analysis-config/detekt/`): Kotlin static analysis with 818-line config
  - Run with: `./gradlew detekt -PcheckCodeStyle` (in test-android/)
  - Note: `-PcheckCodeStyle` flag required due to Kotlin version isolation issues

- **Checkstyle** (`static-analysis-config/checkstyle/`): Java code style based on Effective Java

These configs serve as reference for what the plugin should detect.

## File Structure

```
claude-code-for-android/
├── .claude/                          # Plugin source (development version)
│   ├── agents/
│   │   └── android-code-reviewer.md  # ⚠️ Main plugin logic - edit this
│   └── plugin-manifest.json
│
├── commands/
│   └── android-code-review.md        # User-facing command interface
│
├── scripts/                          # Automation tools
│   ├── verify-isolation.sh           # Verify test-android/.claude/ is empty
│   ├── verify-build.sh               # Compile test-android/ project
│   ├── archive-test.sh               # Archive verified test cases
│   └── publish-plugin.sh             # Release new version
│
├── test-cases/                       # Standalone test files (Tier 1)
│   ├── 001-security-hardcoded-secrets.kt
│   ├── 002-memory-handler-leak.kt
│   └── 003-unsafe-null.kt
│
├── test-android/                     # Real Android project (Tier 2)
│   ├── app/src/main/java/com/test/
│   │   ├── examples/                 # Correct code examples
│   │   └── bugs/                     # Intentionally buggy code
│   ├── config/                       # Detekt & Checkstyle configs
│   └── .claude/                      # ⚠️ MUST BE EMPTY for plugin isolation
│
└── static-analysis-config/           # Reference static analysis configs
    ├── detekt/
    └── checkstyle/
```

## Key Development Notes

1. **TDD Approach:** Write test cases first, then implement detection logic
2. **Confidence Threshold:** Only report issues >80% confidence (reduce noise)
3. **Restart Required:** Plugin changes require restarting Claude Code
4. **Real Project:** `test-android/` is a compilable Android project (not lightweight mock)
5. **Build Verification:** Always run `verify-build.sh` after AI suggests fixes
6. **Plugin Isolation:** `verify-isolation.sh` auto-runs before review scripts

## Testing Categories

The plugin detects issues in these categories:
- **Security:** Hardcoded secrets, insecure storage, Intent hijacking, WebView flaws
- **Code Quality:** Memory leaks, error handling, large functions, deep nesting
- **Android Patterns:** Lifecycle violations, ViewModel misuse, deprecated APIs
- **Jetpack/Kotlin:** Coroutine misconfiguration, Room issues, Hilt errors, Compose anti-patterns
- **Performance:** ANR risks, layout inefficiencies, bitmap mismanagement
- **Best Practices:** Naming conventions, documentation, accessibility

## Documentation

- **DEVELOPMENT.md:** Full development guide (English)
- **DEVELOPMENT_ZH.md:** 完整开发指南（中文）
- **README.md:** User-facing documentation
- **docs/plans/2026-02-27-android-test-project-integration-design.md:** Architecture design
- **docs/workflows/development-cycle.md:** Complete development cycle workflow
