# Claude Code for Android

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blue.svg)](https://claude.ai/claude-code)

English | [简体中文](docs/translations/README_ZH.md)

Automated Android code review for Kotlin/Java code — quality, security, and performance checks based on Google's official Android best practices.

## Features

- 🔍 **Automated Code Review** — Proactively reviews Android code changes
- 🛡️ **Security Scanning** — Detects hardcoded secrets, insecure storage, WebView vulnerabilities
- ⚡ **Performance Analysis** — Identifies ANR risks, memory leaks, layout inefficiencies
- 📱 **Android Best Practices** — Enforces Jetpack, Kotlin, and lifecycle patterns
- 🎯 **Confidence-Based Filtering** — Only reports real issues (>80% confidence), zero noise

## Installation

### Via Marketplace (Recommended)

```bash
# Step 1: Add marketplace
/plugin marketplace add daishengda2018/claude-code-for-android

# Step 2: Install plugin
/plugin install claude-code-for-android@claude-code-for-android

# Step 3: Verify installation
/plugin
```

### Manual Installation

```bash
git clone https://github.com/daishengda2018/claude-code-for-android.git
cd claude-code-for-android
cp -r commands/* ~/.claude/commands/
cp -r agents/* ~/.claude/agents/
```

## Usage

### 🚀 Smart Auto-Detection (v3.0.0+)

**Zero configuration needed** — just run:

```bash
/android-code-review
```

The plugin automatically detects what to review:
1. **Staged changes** → `git diff --staged`
2. **Unstaged changes** → `git diff`
3. **Last commit** → `git log -1 --patch`

### Basic Review

```bash
# Review with auto-detection (recommended)
/android-code-review

# Equivalent to manual:
/android-code-review --target staged
```

### Review Specific File

```bash
/android-code-review --target file:app/src/main/java/com/example/MyFragment.kt
```

### Review All Uncommitted Changes

```bash
/android-code-review --target all
```

### Review with Severity Filter

```bash
# Security-only review (fastest)
/android-code-review --severity critical

# High-severity review (default)
/android-code-review --severity high

# All checks
/android-code-review --severity all
```

### Review Specific Commit

```bash
android-code-review --target commit:a1b2c3d
```

### JSON Output (for CI/CD)

```bash
android-code-review --output-format json > review.json
```

## What Gets Reviewed

| Category | Checks |
|----------|--------|
| **Security** | Hardcoded secrets, insecure storage, Intent hijacking, WebView flaws, cleartext traffic |
| **Code Quality** | Memory leaks, error handling, large functions, deep nesting, dead code |
| **Android Patterns** | Lifecycle violations, ViewModel misuse, deprecated APIs, permission handling |
| **Jetpack/Kotlin** | Coroutine misconfiguration, Room issues, Hilt errors, Compose anti-patterns |
| **Performance** | ANR risks, layout inefficiencies, bitmap mismanagement, startup bottlenecks |
| **Best Practices** | Naming conventions, documentation, accessibility, resource management |

## Pull Request Review

### Local PR Review

```bash
# Review a PR before merging
android-code-review --target pr:123

# High-severity only (faster)
android-code-review --target pr:123 --severity high

# Export as JSON for archiving
android-code-review --target pr:123 --output-format json > pr-123-review.json
```

### CI/CD Integration

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

### PR Context Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| `full` | Full PR metadata + diff + commits | Comprehensive review |
| `diff-only` | Code changes only | Faster review for large PRs |
| `commits-only` | Commit messages only | Quick commit history check |

## Command Options

| Parameter | Values | Default | Description |
|-----------|--------|---------|-------------|
| `--target` | `auto`, `staged`, `all`, `commit:<hash>`, `file:<path>` | `auto` | Review scope (auto = smart detection) |
| `--severity` | `critical`, `high`, `medium`, `low`, `all` | `high` | Filter by severity |
| `--output-format` | `markdown`, `json` | `markdown` | Output format |

**Token efficiency** (v3.0.0):
- Auto-detection reduces command overhead by 60%
- Progressive pattern loading by severity
- Average savings: 38-39% vs v2.0

## Example Output

```
# Android Code Review Results
## Target: staged changes

[CRITICAL] Hardcoded API key in source
File: app/src/main/java/com/example/ApiClient.kt:15
Issue: API key "sk_abc123" exposed in source code. This will be committed to git history and visible in APK decompilation.
Fix: Move the API key to gradle.properties, generate BuildConfig, and reference BuildConfig.API_KEY.

[HIGH] Memory leak in Activity
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

Verdict: BLOCK — 1 CRITICAL issue must be fixed before merge.
```

## Plugin Structure (v3.0.0)

```
claude-code-for-android/
├── commands/
│   └── android-code-review.md         # User-invokable command
├── skills/
│   └── android-code-review/
│       ├── SKILL.md                   # Review orchestration
│       ├── patterns/                  # Detection patterns (v2.1)
│       │   ├── security-patterns.md
│       │   ├── quality-patterns.md
│       │   ├── architecture-patterns.md
│       │   ├── jetpack-patterns.md
│       │   ├── performance-patterns.md
│       │   └── practices-patterns.md
│       └── references/                # Detailed reference docs
└── .claude/
    └── plugin-manifest.json           # Marketplace manifest
```

## Compliance & Standards

This plugin enforces compliance with:

- Google's [Android App Quality Guidelines](https://developer.android.com/quality-guidelines)
- [Android Security Best Practices](https://developer.android.com/topic/security/best-practices)
- [Kotlin Style Guide for Android](https://developer.android.com/kotlin/style-guide)
- Jetpack Compose [Performance & Best Practices](https://developer.android.com/jetpack/compose/performance)

## Documentation

**Quick Start**: [User Guide](docs/guides/USER_GUIDE.md)

### For Users

- 📖 [User Guide](docs/guides/USER_GUIDE.md) - Complete usage guide with test suite
- 📋 [All Documentation](docs/) - Browse all docs

### For Contributors

- 🔧 [Contributing](CONTRIBUTING.md) - Contribution guidelines
- 📖 [Development Guide](DEVELOPMENT.md) - Plugin development guide
- 🔄 [Development Workflow](docs/guides/development/development-cycle.md) - Development cycle
- 📊 [Contributing Standards](CONTRIBUTING_STANDARDS.md) - Coding standards

### Architecture & Reference

- 🎨 [Plugin Structure](docs/PLUGIN_STRUCTURE.md) - Internal structure
- 📖 [Detection Patterns](skills/android-code-review/patterns/) - Active detection rules

## Version History

### v3.0.0 (2026-02-28)
- 🐛 **Fixed plugin discovery** — Added `name` field to command frontmatter
- ✨ **Enhanced documentation** — Restructured command file with clear execution flow
- ⚙️ **Plugin manifest** — Added `.claude/plugin-manifest.json` for proper loading
- 📝 **Migration note** — Requires Claude Code restart after upgrade

### v2.1.1 (2026-02-28)
- ✨ **Smart auto-detection** — Zero-config review (staged → unstaged → last commit)
- ⚡ **60% command token reduction** — Simplified interface
- 📉 **38-39% average token savings** — Pattern-based detection
- 🗑️ **Removed deprecated agents/** — Simplified architecture

### v2.1.0 (2026-02-28)
- 🎯 Pattern-based detection (replaces code examples)
- 🏗️ Simplified architecture (2 layers vs 3)
- 📊 Progressive pattern loading by severity

### v2.0.0 (2026-02-27)
- Progressive rule loading and token budget management

### v1.0.0 (2026-02-26)
- Initial monolithic agent

## Test Suite Status

| Component | Status | Coverage |
|-----------|--------|----------|
| Security (SEC-001) | ✅ Verified | Hardcoded secrets, API keys |
| Memory (QUAL-002) | ✅ Verified | Handler leaks |
| Memory (QUAL-003) | ✅ Verified | ViewModel coroutine leaks |
| Memory (QUAL-004) | ✅ Verified | CoroutineScope leaks |
| Quality (NPE) | ✅ Verified | Force unwrap, unsafe nullable |

**Overall:** 100% detection accuracy on 9 test cases | 0% false positive rate

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

- [Contributing Standards](CONTRIBUTING_STANDARDS.md) - Coding and documentation standards
- [Code of Conduct](CODE_OF_CONDUCT.md) - Community guidelines
- [Changelog](CHANGELOG.md) - Version history

## License

Apache-2.0 © [daishengda2018](https://github.com/daishengda2018)

## Repository

https://github.com/daishengda2018/claude-code-for-android
