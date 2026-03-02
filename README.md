# Claude Code for Android

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blue.svg)](https://claude.ai/claude-code)
[![Version](https://img.shields.io/github/v/release/daishengda2018/claude-code-for-android)](https://github.com/daishengda2018/claude-code-for-android/releases)

> Automated Android code review for Kotlin/Java code — security, quality, and performance checks based on Google's official Android best practices.

**Key Features**: Zero configuration • 90% confidence threshold • ~55% token optimization • Compatible with all Claude providers

---

# Quick Start

## Installation (Marketplace)

```bash
# Step 1: Add marketplace
/plugin marketplace add daishengda2018/claude-code-for-android

# Step 2: Install plugin
/plugin install claude-code-for-android@claude-code-for-android

# Step 3: Verify installation
/plugin
```

## Manual Installation

```bash
# Clone repository
git clone https://github.com/daishengda2018/claude-code-for-android.git
cd claude-code-for-android

# Copy plugin files to ~/.claude/
cp -r commands/* ~/.claude/commands/
cp -r agents/* ~/.claude/agents/
cp -r skills/* ~/.claude/skills/

# Restart Claude Code
```

**Note**: Manual installation requires restarting Claude Code to load the plugin.

---

# Usage

## Review Local Changes (Default)

```bash
# Smart auto-detection (zero configuration)
/android-code-review
```

The plugin automatically detects what to review:

1. **Staged changes** → `git diff --staged`
2. **Unstaged changes** → `git diff`
3. **Last commit** → `git log -1 --patch`

In case you only want to review the stated files:

```bash
# Explicit staged changes
/android-code-review --target staged
```

### Review Specific File

```bash
/android-code-review --target file:app/src/main/java/com/example/MyFragment.kt
```

### Severity Filtering

```bash
# Security-only (fastest)
/android-code-review --severity critical

# High-severity (default)
/android-code-review --severity high

# All checks
/android-code-review --severity all
```

### JSON Output (CI/CD)

```bash
android-code-review --output-format json > review.json
```

## Pull Request Review

### Review Specific PR

```bash
# Review a PR by number
/android-code-review --target pr:123

# High-severity only (faster)
/android-code-review --target pr:123 --severity high

# Export as JSON for archiving
/android-code-review --target pr:123 --output-format json > pr-123-review.json
```

**Note**: The default behavior reviews **local git changes**, not pull requests. Use `--target pr:<number>` for PR review.

---

## Detection Coverage

| Category                   | Checks                                                                                  |
| -------------------------- | --------------------------------------------------------------------------------------- |
| **Security**         | Hardcoded secrets, insecure storage, Intent hijacking, WebView flaws, cleartext traffic |
| **Code Quality**     | Memory leaks, error handling, large functions, deep nesting, dead code                  |
| **Android Patterns** | Lifecycle violations, ViewModel misuse, deprecated APIs, permissions                    |
| **Jetpack/Kotlin**   | Coroutine misconfiguration, Room issues, Hilt errors, Compose anti-patterns             |
| **Performance**      | ANR risks, layout inefficiencies, bitmap mismanagement, startup bottlenecks             |
| **Best Practices**   | Naming conventions, documentation, accessibility, resource management                   |

---

### Token Cost by Severity (V3.0.6)

| Severity     | Patterns Loaded                   | Token Cost | Use Case             |
| ------------ | --------------------------------- | ---------- | -------------------- |
| `critical` | Security only                     | ~1,500     | Fast security scan   |
| `high`     | Security + Quality + Architecture | ~6,950     | Default review       |
| `medium`   | Above + Performance               | ~8,100     | Comprehensive review |
| `all`      | All patterns                      | ~8,900     | Complete analysis    |

---

## Plugin Architecture

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
├── .claude-plugin/                    # Marketplace metadata
│   ├── plugin.json                    # Plugin manifest
│   └── marketplace.json               # Marketplace description
└── [other files]
```

### Execution Flow

```
User runs: /android-code-review --target file:xxx.kt
    ↓
Command (android-code-review.md)
    - Collects files (staged/unstaged/commit/file)
    - Filters out XML files
    ↓
Skill (SKILL.md)
    - Loads detection rules based on severity
    - Invokes agent with context
    ↓
Agent (android-code-reviewer.md)
    - Analyzes code
    - Applies detection rules
    - Filters by confidence (>90%)
    ↓
Output: Structured review findings
```

### Key Components

| Component         | Role          | Description                                          |
| ----------------- | ------------- | ---------------------------------------------------- |
| **Command** | Entry point   | File collection, filtering, user interface           |
| **Skill**   | Orchestration | Rule selection, severity filtering, agent invocation |
| **Agent**   | Execution     | Code analysis, pattern matching, confidence scoring  |

For detailed architecture documentation, see [ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Example Output

```
# Android Code Review Results
## Target: staged changes

### 🔴 CRITICAL (1 issue)

[SEC-001] Hardcoded API key in source
File: app/src/main/java/com/example/ApiClient.kt:15
Issue: API key "sk_abc123" exposed in source code. This will be committed to git history and visible in APK decompilation.
Fix: Move the API key to gradle.properties, generate BuildConfig, and reference BuildConfig.API_KEY.

### 🟠 HIGH (1 issue)

[QUAL-002] Memory leak in Activity
File: app/src/main/java/com/example/LeakyActivity.kt:22
Issue: Activity Context referenced in static Handler → leaks when Activity is destroyed.
Fix: Use Application Context and clean up Handler in onDestroy().

## Review Summary

| Severity | Count | Status |
|----------|-------|--------|
| CRITICAL | 1     | fail   |
| HIGH     | 1     | warn   |
| MEDIUM   | 0     | info   |
| LOW      | 2     | note   |

**Verdict**: BLOCKED — 1 CRITICAL issue must be fixed before merge.
```

## Changelog

| Version          | Date       | Highlights                                                        |
| ---------------- | ---------- | ----------------------------------------------------------------- |
| **v3.0.6** | 2026-03-02 | Simplified documentation — removed v2.x references                 |
| **v3.0.5** | 2026-03-02 | Simplified architecture — removed redundant plugin-manifest.json |
| **v3.0.4** | 2026-02-28 | Removed hardcoded model, all providers compatible                 |
| **v3.0.3** | 2026-02-28 | Confidence → 90%, 22% token optimization                         |
| **v3.0.2** | 2026-02-28 | XML filtering, async detection, confidence → 85%                 |
| **v3.0.1** | 2026-02-28 | Fixed plugin manifest format                                      |
| **v3.0.0** | 2026-02-28 | Major refactor: plugin discovery, marketplace integration         |

See [CHANGELOG.md](CHANGELOG.md) for complete version history.

## License

Apache-2.0 © [daishengda2018](https://github.com/daishengda2018)

---

## Acknowledgments

This plugin enforces compliance with:

- Google's [Android App Quality Guidelines](https://developer.android.com/quality-guidelines)
- [Android Security Best Practices](https://developer.android.com/topic/security/best-practices)
- [Kotlin Style Guide for Android](https://developer.android.com/kotlin/style-guide)
- Jetpack Compose [Performance &amp; Best Practices](https://developer.android.com/jetpack/compose/performance)
