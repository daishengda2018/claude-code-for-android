# Claude Code for Android

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blue.svg)](https://claude.ai/claude-code)

English | **[简体中文](README_ZH.md)**

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

### Basic Review (Staged Changes)

```bash
android-code-review --target staged
```

### Review Specific File

```bash
android-code-review --target file:app/src/main/java/com/example/MyFragment.kt
```

### Review All Uncommitted Changes

```bash
android-code-review --target all
```

### Review with Severity Filter

```bash
android-code-review --target all --severity critical
```

### Review Specific Commit

```bash
android-code-review --target commit:a1b2c3d
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

## Command Options

| Parameter | Values | Default | Description |
|-----------|--------|---------|-------------|
| `--target` | `staged`, `all`, `commit:<hash>`, `file:<path>` | `staged` | Review scope |
| `--severity` | `critical`, `high`, `medium`, `low`, `all` | `all` | Filter by severity |
| `--project-guidelines` | `<file-path>` | - | Custom guidelines file |
| `--output-format` | `markdown`, `json` | `markdown` | Output format |

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

## Plugin Structure

```
claude-code-for-android/
├── commands/
│   └── android-code-review.md     # User-invokable command
├── agents/
│   └── android-code-reviewer.md    # Review agent logic
└── .claude/
    └── plugin-manifest.json        # Claude Code marketplace manifest
```

## Compliance & Standards

This plugin enforces compliance with:

- Google's [Android App Quality Guidelines](https://developer.android.com/quality-guidelines)
- [Android Security Best Practices](https://developer.android.com/topic/security/best-practices)
- [Kotlin Style Guide for Android](https://developer.android.com/kotlin/style-guide)
- Jetpack Compose [Performance & Best Practices](https://developer.android.com/jetpack/compose/performance)

## Development Documentation

Want to contribute or understand the internal implementation? Check out:

- 📖 [Development Guide](DEVELOPMENT.md) - Plugin development guide
- 🎨 [Design Document](docs/plans/2026-02-27-android-test-project-integration-design.md) - Architecture design
- 🔄 [Development Workflow](docs/workflows/development-cycle.md) - Development cycle

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

Apache-2.0 © [daishengda2018](https://github.com/daishengda2018)

## Repository

https://github.com/daishengda2018/claude-code-for-android
