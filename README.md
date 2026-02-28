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

### Review Pull Request

```bash
# Review PR by number
android-code-review --target pr:123

# Review PR with severity filter
android-code-review --target pr:123 --severity high

# Review PR with JSON output (for CI/CD)
android-code-review --target pr:123 --output-format json
```

### Advanced Usage

```bash
# Fast review with light mode (30% token reduction)
android-code-review --target all --mode light

# Security-focused review (84% token reduction)
android-code-review --target staged --severity critical

# Review with project-specific guidelines
android-code-review --target staged --project-guidelines ./ANDROID.md

# PR review with minimal context (faster)
android-code-review --target pr:123 --pr-context diff-only
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
| `--target` | `staged`, `all`, `commit:<hash>`, `file:<path>`, `pr:<number\|url>` | `staged` | Review scope |
| `--severity` | `critical`, `high`, `medium`, `low`, `all` | `all` | Filter by severity (controls progressive loading) |
| `--mode` | `light`, `normal` | `normal` | Execution mode (light = 30% token reduction) |
| `--pr-context` | `full`, `diff-only`, `commits-only` | `full` | PR context level (for pr: target) |
| `--project-guidelines` | `<file-path>` | - | Custom guidelines file (e.g., ANDROID.md, lint.xml) |
| `--output-format` | `markdown`, `json` | `markdown` | Output format (JSON includes confidence scores) |

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

- 📖 [User Guide](docs/USER_GUIDE.md) - Complete usage guide with test suite
- 📖 [Development Guide](DEVELOPMENT.md) - Plugin development guide
- 🎨 [Architecture Design](docs/2026-02-27-android-test-project-integration-design.md) - System architecture
- 🔄 [Development Workflow](docs/workflows/development-cycle.md) - Development cycle
- 📊 [Plugin Structure](docs/PLUGIN_STRUCTURE.md) - Internal structure
- 📋 [Reference Documentation](docs/reference/) - Detection patterns and rules
- 📄 [Verification Reports](docs/reports/) - Test results and validation

## Test Suite Status

| Component | Status | Coverage |
|-----------|--------|----------|
| Security (SEC-001) | ✅ Verified | Hardcoded secrets, API keys |
| Memory (QUAL-002) | ✅ Verified | Handler leaks |
| Memory (QUAL-003) | ✅ Verified | ViewModel coroutine leaks |
| Memory (QUAL-004) | ✅ Verified | CoroutineScope leaks |
| Quality (NPE) | ✅ Verified | Force unwrap, unsafe nullable |

**Overall:** 100% detection accuracy on 9 test cases | 0% false positive rate

Run tests: `./scripts/batch-validate-reviews.sh`

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

- [Contributing Standards](CONTRIBUTING_STANDARDS.md) - Coding and documentation standards
- [Code of Conduct](CODE_OF_CONDUCT.md) - Community guidelines
- [Changelog](CHANGELOG.md) - Version history

## License

Apache-2.0 © [daishengda2018](https://github.com/daishengda2018)

## Repository

https://github.com/daishengda2018/claude-code-for-android
