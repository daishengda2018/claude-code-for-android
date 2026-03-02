# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Claude Code plugin** for automated Android code review (Kotlin/Java). It provides:

- `/android-code-review` command - User-facing command for reviewing code
- `android-code-review` skill - Pattern-based detection orchestration
- `android-code-reviewer` agent - Code analysis and confidence scoring

**Current Version**: v3.0.4

**Plugin Architecture (V3.x):**

```
User runs: /android-code-review --target file:app/src/main/java/...
       ↓
Command (android-code-review.md)
       - Collects files (staged/unstaged/commit/file/pr)
       - Filters XML files
       ↓
Skill (SKILL.md)
       - Loads detection rules based on severity
       - Invokes agent with context
       ↓
Agent (android-code-reviewer.md)
       - Reads and analyzes code
       - Applies detection rules
       - Filters by confidence (>90%)
       ↓
Output: Structured review findings
```

## Critical Constraints

### Plugin Isolation (CRITICAL)

**⚠️ IMPORTANT:** The `test-android/.claude/` directory **must not exist** or be **empty**.

Claude Code loads plugins in this priority order:

1. Project-level: `test-android/.claude/` (if exists) ← Overrides your development version!
2. Git root: `.claude/` ← Your development version
3. User-level: `~/.claude/` (marketplace-installed)

**Always verify isolation before testing:**

```bash
./scripts/verify-isolation.sh
```

### Version Consistency (Before Release)

**⚠️ MANDATORY**: All version files must have consistent version numbers before release:

```bash
grep -h '"version"' .claude/plugin-manifest.json .claude-plugin/plugin.json .claude-plugin/marketplace.json
```

All three files should display the same version number (e.g., `"3.0.4"`).

See [RELEASE_CHECKLIST.md](./docs/RELEASE_CHECKLIST.md) for complete release procedure.

## Development Workflow

### Quick Start

1. **Write Test Case**

   ```kotlin
   // test-cases/004-my-test.kt
   // Expected Detection: HIGH
   class BadExample {
       private val leak = Handler()  // Missing cleanup
   }
   ```
2. **Run AI Review**

   ```
   /android-code-review --target file:test-cases/004-my-test.kt
   ```
3. **Modify Detection Rules**

   - Edit `skills/android-code-review/SKILL.md` to add/modify detection patterns
   - **⚠️ Restart Claude Code after changes**
4. **Verify in Real Project**

   ```bash
   cd test-android/
   # Write buggy code in app/src/main/java/com/test/bugs/
   /android-code-review --target file:app/src/main/java/com/test/bugs/...
   cd ../
   ./scripts/verify-build.sh  # Verify code compiles
   ```

## Testing System

### Tier 1: Standalone Files (Quick Verification)

- **Location:** `test-cases/*.kt`
- **Purpose:** Fast verification of single detection rules
- **Usage:** `/android-code-review --target file:test-cases/<file>.kt`

### Tier 2: Real Android Project (Deep Testing)

- **Location:** `test-android/`
- **Purpose:** Test in real project environment with actual Gradle build
- **Build Verification:**
  ```bash
  ./scripts/verify-build.sh
  ```

  - Exit code `0` = Build SUCCESS (plugin may have false positive)
  - Exit code `1` = Build FAILED (plugin detection is correct)

### Tier 3: Batch Regression Testing

- **Method:** Manually run review on all test cases
  ```bash
  for file in test-cases/*.kt; do
      /android-code-review --target file:$file
  done
  ```

## Architecture Details

### V3.x Key Components

| Component         | Location                                | Responsibility                                       |
| ----------------- | --------------------------------------- | ---------------------------------------------------- |
| **Command** | `commands/android-code-review.md`     | File collection, XML filtering, user interface       |
| **Skill**   | `skills/android-code-review/SKILL.md` | Rule selection, severity filtering, agent invocation |
| **Agent**   | `agents/android-code-reviewer.md`     | Code analysis, pattern matching, confidence scoring  |

### V3.x vs V2.x Changes

| Aspect               | V2.x                              | V3.x                            |
| -------------------- | --------------------------------- | ------------------------------- |
| Directory name       | `agent/`                        | `agents/`                     |
| Plugin discovery     | Unstable (missing `name` field) | Fixed                           |
| Marketplace support  | No                                | Yes (`plugin.json` added)     |
| Confidence threshold | 80%                               | 90%                             |
| XML filtering        | No                                | Yes (100% noise reduction)      |
| Async detection      | No                                | Yes (80% fewer false positives) |
| Token optimization   | 38-39%                            | ~55% cumulative                 |

### Directory Structure

```
claude-code-for-android/
├── commands/
│   └── android-code-review.md         # User-facing command
├── agents/
│   └── android-code-reviewer.md       # Code review agent
├── skills/
│   └── android-code-review/
│       └── SKILL.md                   # Detection rules orchestration
├── .claude/                           # Development config
│   ├── plugin-manifest.json           # Project metadata
│   └── settings.json                  # Project settings
├── .claude-plugin/                    # Marketplace metadata
│   ├── plugin.json                    # Plugin manifest
│   └── marketplace.json               # Marketplace description
├── test-cases/                        # Standalone test files (Tier 1)
├── test-android/                      # Real Android project (Tier 2)
│   └── .claude/                       # ⚠️ MUST BE EMPTY for plugin isolation
└── scripts/                           # Automation tools
    ├── verify-isolation.sh
    ├── verify-build.sh
    └── publish-plugin.sh
```

## Detection System

### Severity-Based Rule Loading

| Severity     | Token Cost | Patterns Loaded                             |
| ------------ | ---------- | ------------------------------------------- |
| `critical` | ~1,500     | Security only (production blockers)         |
| `high`     | ~6,900     | Security + Quality + Architecture + Jetpack |
| `medium`   | ~8,100     | Above + Performance                         |
| `all`      | ~8,900     | All patterns including Best Practices       |

**Default**: `high` (balances coverage and token usage)

### Confidence Threshold

- **90% confidence threshold** — Only report issues with >90% confidence
- Reduces false positives from ~40% (V2.x) to ~5-10% (V3.x)
- When in doubt, skip reporting rather than create noise

### Key Optimizations (V3.x)

1. **XML File Filtering**: Automatically skips `*.xml` files (layouts, menus, drawables)
2. **Async Context Detection**: Only reports concurrent modifications when async context is detected
3. **Progressive Pattern Loading**: Loads rules based on severity threshold

## Detection Categories

- **Security**: Hardcoded secrets, insecure storage, Intent hijacking, WebView flaws
- **Code Quality**: Memory leaks, error handling, large functions, deep nesting
- **Android Patterns**: Lifecycle violations, ViewModel misuse, deprecated APIs
- **Jetpack/Kotlin**: Coroutine misconfiguration, Room issues, Hilt errors, Compose anti-patterns
- **Performance**: ANR risks, layout inefficiencies, bitmap mismanagement
- **Best Practices**: Naming conventions, documentation, accessibility

## Static Analysis Reference

The project includes reference static analysis configs from WeShare-Android:

- **Detekt** (`static-analysis-config/detekt/`): Kotlin static analysis
  - Run with: `./gradlew detekt -PcheckCodeStyle` (in test-android/)
- **Checkstyle** (`static-analysis-config/checkstyle/`): Java code style

These configs serve as reference for what the plugin should detect.

## Key Development Notes

1. **TDD Approach:** Write test cases first, then implement detection logic
2. **Confidence Threshold:** Only report issues >90% confidence (reduce noise)
3. **Restart Required:** Plugin changes require restarting Claude Code
4. **Real Project:** `test-android/` is a compilable Android project (not lightweight mock)
5. **Build Verification:** Always run `verify-build.sh` after AI suggests fixes
6. **Plugin Isolation:** `verify-isolation.sh` auto-runs before review scripts
7. **Token Efficiency:** Use appropriate severity level to minimize token usage

## Reserved Permissions

The plugin includes `python3:*` permission in `.claude/settings.json` for future features:

- **Automated test report generation** - Parse test results and generate summary reports
- **Statistical data visualization** - Create charts from code quality metrics
- **Performance metrics analysis** - Analyze token usage and performance patterns

**Current Status (v3.0.4)**: Reserved but not actively used.

## CurrentDate

Today's date is 2026-03-02.
