# Claude Code for Android

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blue.svg)](https://claude.ai/claude-code)
[![Version](https://img.shields.io/github/v/release/daishengda2018/claude-code-for-android)](https://github.com/daishengda2018/claude-code-for-android/releases)

> Automated Android code review for Kotlin/Java code — security, quality, and performance checks based on Google's official Android best practices.

**Key Features**: Zero configuration • 90% confidence threshold • ~55% token optimization • Compatible with all Claude providers

---

## 🚀 Quick Start

### Installation (Marketplace)

```bash
# Step 1: Add marketplace
/plugin marketplace add daishengda2018/claude-code-for-android

# Step 2: Install plugin
/plugin install claude-code-for-android@claude-code-for-android

# Step 3: Verify installation
/plugin
```

### First Review

```bash
# Smart auto-detection (zero configuration)
/android-code-review
```

The plugin automatically detects what to review:

1. **Staged changes** → `git diff --staged`
2. **Unstaged changes** → `git diff`
3. **Last commit** → `git log -1 --patch`

---

## ✨ What's New in V3.x

### V3.0.4 (Latest)

- ✅ **Removed hardcoded model** — Compatible with all Claude providers (Haiku, Sonnet, Opus)
- ✅ No model restrictions — Works with your default or specified model

### V3.0.3

- 🎯 **Confidence threshold raised to 90%** — Fewer false positives
- ⚡ **Additional 22% token optimization** — Faster reviews

### V3.0.2

- 🗑️ **XML file filtering** — 100% noise reduction for layout files
- 🔍 **Async context detection** — 80% fewer false positives for concurrent modifications

### V3.0.0 — Major Refactor

- 🏗️ **Plugin discovery fix** — Resolves "command not found" issue
- 📝 **Proper marketplace integration** — Added plugin manifests
- 🚀 **Enhanced command interface** — Improved execution flow

**⚠️ Migration Note**: V2.x users should restart Claude Code after upgrading to V3.x. See [Migration Guide](#-v2x--v3x-migration) for details.

---

## 📖 Usage

### Basic Review

```bash
# Auto-detection (recommended)
/android-code-review

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

### Pull Request Review

#### Review Specific PR

```bash
# Review a PR by number
/android-code-review --target pr:123

# High-severity only (faster)
/android-code-review --target pr:123 --severity high

# Export as JSON for archiving
/android-code-review --target pr:123 --output-format json > pr-123-review.json
```

#### Review Local Changes (Default)

The command automatically detects what to review when no target is specified:

```bash
# Auto-detection: staged → unstaged → last commit
/android-code-review

# Explicit staged changes
/android-code-review --target staged

# Explicit unstaged changes
/android-code-review --target unstaged

# Review last commit
/android-code-review --target commit:HEAD
```

**Note**: The default behavior reviews **local git changes**, not pull requests. Use `--target pr:<number>` for PR review.

#### CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Android Code Review

on:
  pull_request:
    branches: [main]

jobs:
  code-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run Android Code Review
        run: |
          android-code-review --target ${{ github.sha }} \
                              --severity high \
                              --output-format json > review.json

      - name: Check Results
        run: |
          CRITICAL=$(jq '.summary.by_severity.CRITICAL' review.json)
          if [ "$CRITICAL" -gt 0 ]; then
            echo "❌ CRITICAL issues detected. PR blocked."
            exit 1
          fi
```

#### PR Context Modes

| Mode             | Description                       | Use Case                    |
| ---------------- | --------------------------------- | --------------------------- |
| `full`         | Full PR metadata + diff + commits | Comprehensive review        |
| `diff-only`    | Code changes only                 | Faster review for large PRs |
| `commits-only` | Commit messages only              | Quick commit history check  |

---

## 🛡️ Detection Coverage

| Category                   | Checks                                                                                  |
| -------------------------- | --------------------------------------------------------------------------------------- |
| **Security**         | Hardcoded secrets, insecure storage, Intent hijacking, WebView flaws, cleartext traffic |
| **Code Quality**     | Memory leaks, error handling, large functions, deep nesting, dead code                  |
| **Android Patterns** | Lifecycle violations, ViewModel misuse, deprecated APIs, permissions                    |
| **Jetpack/Kotlin**   | Coroutine misconfiguration, Room issues, Hilt errors, Compose anti-patterns             |
| **Performance**      | ANR risks, layout inefficiencies, bitmap mismanagement, startup bottlenecks             |
| **Best Practices**   | Naming conventions, documentation, accessibility, resource management                   |

---

## ⚡ Token Optimization

### Cumulative Performance

| Version          | Optimization                      | Token Savings  | Measurement                 |
| ---------------- | --------------------------------- | -------------- | --------------------------- |
| **V2.1.1** | Pattern-based detection           | 38-39%         | vs V2.0, all severities     |
| **V3.0.2** | XML filtering, async detection    | ~15%           | vs V3.0.1, default settings |
| **V3.0.3** | Confidence threshold 90%          | 22%            | vs V3.0.2, default settings |
| **V3.0.4** | Model-agnostic design             | 0%             | No change                   |
| **Total**  | **Cumulative optimization** | **~55%** | vs V2.0, default settings   |

### Token Cost by Severity (V3.0.4)

| Severity     | Patterns Loaded                   | Token Cost | Use Case             |
| ------------ | --------------------------------- | ---------- | -------------------- |
| `critical` | Security only                     | ~1,500     | Fast security scan   |
| `high`     | Security + Quality + Architecture | ~6,950     | Default review       |
| `medium`   | Above + Performance               | ~8,100     | Comprehensive review |
| `all`      | All patterns                      | ~8,900     | Complete analysis    |

---

## 🏗️ Plugin Architecture (V3.x)

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

---

## 🔄 V2.x → V3.x Migration

### Breaking Changes

| Change               | V2.x                              | V3.x                        |
| -------------------- | --------------------------------- | --------------------------- |
| Directory name       | `agent/`                        | `agents/`                 |
| Plugin discovery     | Unstable (missing `name` field) | Fixed                       |
| Marketplace support  | No                                | Yes (`plugin.json` added) |
| Confidence threshold | 80%                               | 90%                         |

### Required Actions

1. **Restart Claude Code** after upgrading
2. **No code changes needed** — Command interface is backward compatible
3. **Verify plugin loading** with `/plugin` command

### What's Improved

- ✅ **Plugin discovery fixed** — No more "command not found" errors
- ✅ **Better false positive filtering** — 90% confidence threshold
- ✅ **Marketplace integration** — Proper plugin manifests
- ✅ **Token optimization** — ~55% cumulative reduction

For detailed migration guide, see [MIGRATION.md](docs/MIGRATION.md).

---

## 🔧 Manual Installation

```bash
# Clone repository
git clone https://github.com/daishengda2018/claude-code-for-android.git
cd claude-code-for-android

# Copy plugin files to ~/.claude/
cp -r commands/* ~/.claude/commands/
cp -r agents/* ~/.claude/agents/
cp -r skills/* ~/.claude/skills/

# (Optional) Copy marketplace metadata
mkdir -p ~/.claude/.claude-plugin/
cp -r .claude-plugin/* ~/.claude/.claude-plugin/

# Restart Claude Code
```

**Note**: Manual installation requires restarting Claude Code to load the plugin.

---

## 📊 Example Output

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

---

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

- [Contributing Standards](CONTRIBUTING_STANDARDS.md) - Coding and documentation standards
- [Development Guide](DEVELOPMENT.md) - Plugin development guide
- [Changelog](CHANGELOG.md) - Version history

---

## 📚 Documentation

### For Users

- 📖 [User Guide](docs/guides/USER_GUIDE.md) - Complete usage guide with test suite
- 🔄 [Migration Guide](docs/MIGRATION.md) - V2.x → V3.x migration details

### For Contributors

- 🔧 [Development Guide](DEVELOPMENT.md) - Plugin development guide
- 🎨 [Architecture](docs/ARCHITECTURE.md) - V3.x architecture deep dive
- 📊 [Token Optimization](docs/TOKEN-OPTIMIZATION.md) - Performance optimization details

### Reference

- [All Documentation](docs/) - Browse all docs
- [Test Suite](test-cases/) - Verification test cases

---

## 📋 Version History

### V3.x Series

| Version          | Date       | Highlights                                                |
| ---------------- | ---------- | --------------------------------------------------------- |
| **v3.0.4** | 2026-02-28 | Removed hardcoded model, all providers compatible         |
| **v3.0.3** | 2026-02-28 | Confidence → 90%, 22% token optimization                 |
| **v3.0.2** | 2025-02-28 | XML filtering, async detection, confidence → 85%         |
| **v3.0.1** | 2026-02-28 | Fixed plugin manifest format                              |
| **v3.0.0** | 2026-02-28 | Major refactor: plugin discovery, marketplace integration |

### Historical Versions

| Version          | Date       | Highlights                                                     |
| ---------------- | ---------- | -------------------------------------------------------------- |
| **v2.1.1** | 2026-02-28 | Smart auto-detection, pattern-based detection (38-39% savings) |
| **v2.1.0** | 2026-02-28 | Pattern-based detection, simplified architecture               |
| **v2.0.0** | 2026-02-27 | Progressive rule loading                                       |
| **v1.0.0** | 2026-02-26 | Initial monolithic agent                                       |

See [CHANGELOG.md](CHANGELOG.md) for complete version history.

---

## 🧪 Test Suite Status

| Component          | Status      | Coverage                      |
| ------------------ | ----------- | ----------------------------- |
| Security (SEC-001) | ✅ Verified | Hardcoded secrets, API keys   |
| Memory (QUAL-002)  | ✅ Verified | Handler leaks                 |
| Memory (QUAL-003)  | ✅ Verified | ViewModel coroutine leaks     |
| Memory (QUAL-004)  | ✅ Verified | CoroutineScope leaks          |
| Quality (NPE)      | ✅ Verified | Force unwrap, unsafe nullable |

**Overall**: 100% detection accuracy on verified test cases | 0% false positive rate

---

## 📄 License

Apache-2.0 © [daishengda2018](https://github.com/daishengda2018)

---

## 🔗 Repository

https://github.com/daishengda2018/claude-code-for-android

---

## 👏 Acknowledgments

This plugin enforces compliance with:

- Google's [Android App Quality Guidelines](https://developer.android.com/quality-guidelines)
- [Android Security Best Practices](https://developer.android.com/topic/security/best-practices)
- [Kotlin Style Guide for Android](https://developer.android.com/kotlin/style-guide)
- Jetpack Compose [Performance &amp; Best Practices](https://developer.android.com/jetpack/compose/performance)
