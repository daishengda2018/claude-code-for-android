# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Claude Code plugin** for automated Android code review (Kotlin/Java).

**Current Version**: v3.0.6

**Architecture**:

```
User: /android-code-review --target file:example.kt
    ↓
Command (file collection, XML filtering)
    ↓
Skill (rule selection, severity filtering)
    ↓
Agent (code analysis, confidence scoring >90%)
    ↓
Output: Structured findings
```

## Critical Constraints

### Plugin Isolation

**The `test-android/.claude/` directory MUST NOT exist or be empty.**

Claude Code loads plugins in this priority:
1. Project-level: `test-android/.claude/` ← Overrides your development version!
2. Git root: `.claude/` ← Your development version
3. User-level: `~/.claude/`

**Verify**: `ls test-android/.claude/ 2>/dev/null && echo "❌" || echo "✅"`

**Remove if exists**: `rm -rf test-android/.claude`

## Common Commands

```bash
# Auto-detection (staged → unstaged → last commit)
/android-code-review

# Review specific file
/android-code-review --target file:test-cases/001-security-hardcoded-secrets.kt

# Severity filtering
/android-code-review --severity critical  # Security only
/android-code-review --severity high      # Default
/android-code-review --severity all       # All patterns
```

## Development Workflow

### Quick Start

1. **Write test case** in `test-cases/`:

   ```kotlin
   // test-cases/012-new-test.kt
   // Expected Detection: HIGH
   class BadExample {
       private val leak = Handler()  // Missing cleanup
   }
   ```

2. **Run review**: `/android-code-review --target file:test-cases/012-new-test.kt`

3. **Edit detection rules**: `skills/android-code-review/SKILL.md`
   - **Restart Claude Code after changes**

4. **Verify**: Confirm issue detected with expected severity

### Testing

- **Tier 1**: `test-cases/*.kt` - Standalone files (quick verification)
- **Tier 2**: `test-android/` - Real Android project (deep testing)
  - Verify build: `cd test-android/ && ./gradlew assembleDebug`

## Architecture

| Component | File | Responsibility |
|-----------|------|----------------|
| Command | `commands/android-code-review.md` | File collection, filtering |
| Skill | `skills/android-code-review/SKILL.md` | Rule selection |
| Agent | `agents/android-code-reviewer.md` | Analysis, scoring |

## Detection System

**Severity Levels**:

| Severity | Token Cost | Patterns |
|----------|------------|----------|
| `critical` | ~1,500 | Security only |
| `high` | ~6,950 | Security + Quality + Architecture |
| `medium` | ~8,100 | Above + Performance |
| `all` | ~8,900 | All patterns |

**Confidence Threshold**: 90% (only report >90% confidence)

**Categories**: Security, Quality, Android Patterns, Jetpack/Kotlin, Performance, Best Practices

## Release Process

Follow [RELEASE_CHECKLIST.md](docs/RELEASE_CHECKLIST.md):

1. Structure validation
2. Runtime compatibility
3. Version integrity (plugin.json, marketplace.json, CHANGELOG.md)
4. Git sync and tag
5. GitHub Release
6. Post-release validation

## Key Notes

- **TDD**: Write test cases first
- **Restart required**: Plugin changes need Claude Code restart
- **Token efficiency**: Use appropriate severity level
- **Build verification**: Always verify code compiles
- **Plugin isolation**: Ensure `test-android/.claude/` doesn't exist

## Current Date

Today's date is 2026-03-02.
