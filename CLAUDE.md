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

**Verify isolation manually:**

```bash
# Check if test-android/.claude exists
ls test-android/.claude/ 2>/dev/null && echo "❌ Isolation broken!" || echo "✅ Isolation OK"
```

**Remove if exists:**

```bash
rm -rf test-android/.claude
```

### Version Consistency (Before Release)

**⚠️ MANDATORY**: All version files must have consistent version numbers before release:

```bash
grep -h '"version"' .claude/plugin-manifest.json .claude-plugin/plugin.json .claude-plugin/marketplace.json
```

All three files should display the same version number (e.g., `"3.0.4"`).

See [RELEASE_CHECKLIST.md](docs/RELEASE_CHECKLIST.md) for complete release procedure.

## Release Process

### Quick Release Steps

1. **Update version numbers:**
   ```bash
   # Update all three files with same version
   .claude/plugin-manifest.json
   .claude-plugin/plugin.json
   .claude-plugin/marketplace.json
   ```

2. **Update CHANGELOG.md** with version changes

3. **Commit changes:**
   ```bash
   git add .
   git commit -m "chore: release v3.0.5"
   ```

4. **Create and push tag:**
   ```bash
   git tag -a v3.0.5 -m "Release v3.0.5"
   git push origin main
   git push origin v3.0.5
   ```

5. **Create GitHub Release:**
   ```bash
   gh release create v3.0.5 --notes-file CHANGELOG.md
   ```

**Detailed checklist:** See [RELEASE_CHECKLIST.md](docs/RELEASE_CHECKLIST.md)

## Development Workflow

## Development Workflow

### Common Commands

**Run Android Code Review:**

```bash
# Auto-detection (staged → unstaged → last commit)
/android-code-review

# Review specific file
/android-code-review --target file:test-cases/001-security-hardcoded-secrets.kt

# Review with severity filter
/android-code-review --severity critical  # Security only (fastest)
/android-code-review --severity high      # Default (security + quality + architecture)
/android-code-review --severity medium    # + Performance
/android-code-review --severity all       # All patterns

# Review PR
/android-code-review --target pr:123
```

### Quick Start

1. **Write Test Case**

   ```kotlin
   // test-cases/012-new-test.kt
   // Expected Detection: HIGH
   class BadExample {
       private val leak = Handler()  // Missing cleanup
   }
   ```

2. **Run AI Review**

   ```bash
   /android-code-review --target file:test-cases/012-new-test.kt
   ```

3. **Modify Detection Rules**

   - Edit `skills/android-code-review/SKILL.md` to add/modify detection patterns
   - **⚠️ Restart Claude Code after changes**

4. **Verify Detection Works**

   - Confirm issue is detected with expected severity
   - Test with `test-cases/` (Tier 1) or `test-android/` (Tier 2)

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
  cd test-android/
  ./gradlew assembleDebug
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
└── docs/                              # Documentation
    ├── ARCHITECTURE.md                # V3.x architecture details
    ├── RELEASE_CHECKLIST.md           # Release checklist
    └── PLUGIN_STRUCTURE.md            # Plugin structure guide
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
5. **Build Verification:** Always verify code compiles after AI suggests fixes
6. **Plugin Isolation:** Ensure `test-android/.claude/` doesn't exist before testing
7. **Token Efficiency:** Use appropriate severity level to minimize token usage
8. **Version Consistency:** Before release, ensure all version files match (plugin-manifest.json, plugin.json, marketplace.json)

## Reserved Permissions

The plugin includes `python3:*` permission in `.claude/settings.json` for future features:

- **Automated test report generation** - Parse test results and generate summary reports
- **Statistical data visualization** - Create charts from code quality metrics
- **Performance metrics analysis** - Analyze token usage and performance patterns

**Current Status (v3.0.4)**: Reserved but not actively used.

## CurrentDate

Today's date is 2026-03-02.
