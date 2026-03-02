# V3.x Architecture

**Version**: 3.0.6
**Last Updated**: 2026-03-02

This document describes the architecture of the Claude Code for Android plugin.

---

## Overview

### Plugin Purpose

Automated code review for Android projects (Kotlin/Java), detecting:

- **Security vulnerabilities** - Hardcoded secrets, insecure storage, Intent hijacking, WebView flaws
- **Code quality issues** - Memory leaks, error handling, large functions, deep nesting
- **Android pattern violations** - Lifecycle issues, ViewModel misuse, deprecated APIs
- **Jetpack/Kotlin issues** - Coroutine problems, Room errors, Hilt errors, Compose anti-patterns
- **Performance bottlenecks** - ANR risks, layout inefficiencies, bitmap mismanagement
- **Best practice violations** - Naming conventions, documentation, accessibility

### Design Principles

1. **Zero Configuration** - Smart auto-detection of code changes
2. **Confidence-Based Filtering** - Only reports issues with >90% confidence
3. **Token Efficiency** - Progressive pattern loading minimizes token usage
4. **Model Agnostic** - Compatible with all Claude providers (Haiku, Sonnet, Opus)

---

## Architecture

### Directory Structure

```
claude-code-for-android/
├── commands/
│   └── android-code-review.md         # User-facing command interface
├── agents/
│   └── android-code-reviewer.md       # Code review execution agent
├── skills/
│   └── android-code-review/
│       └── SKILL.md                   # Detection rules orchestration
├── .claude/                           # Development environment config (not published)
│   └── settings.json                  # Project settings
├── .claude-plugin/                    # Marketplace metadata
│   ├── plugin.json                    # Plugin manifest
│   └── marketplace.json               # Marketplace description
├── test-cases/                        # Standalone test files (Tier 1)
├── test-android/                      # Real Android project (Tier 2)
└── docs/                              # Documentation
```

### Layer Responsibilities

| Layer | File | Responsibility | Token Cost |
|-------|------|----------------|------------|
| **Command** | `commands/android-code-review.md` | File collection, filtering, user interface | ~1,000 |
| **Skill** | `skills/android-code-review/SKILL.md` | Rule selection, severity filtering, agent invocation | ~500-6,000 |
| **Agent** | `agents/android-code-reviewer.md` | Code analysis, pattern matching, confidence scoring | ~2,000-4,000 |

### Execution Flow

```
User: /android-code-review --target file:Example.kt --severity high
    ↓
Command Layer
  • Parse arguments
  • Collect files
  • Filter XML files
  • Invoke Skill
    ↓
Skill Layer
  • Load rules by severity
  • Invoke Agent
    ↓
Agent Layer
  • Read code
  • Apply rules
  • Score confidence
  • Filter >90%
  • Output findings
    ↓
Skill Layer
  • Format output
    ↓
Command Layer
  • Present to user
```

---

## Component Details

### 1. Command Layer

**File**: `commands/android-code-review.md`

**Responsibilities**:
- Parse user arguments (`--target`, `--severity`, `--output-format`)
- Collect files to review (staged/unstaged/commit/file)
- Filter out non-source files (XML layouts, etc.)
- Invoke Skill with context
- Format and present agent results

**Key Features**:
- **Smart Auto-Detection**: Automatically detects what to review
  1. Staged changes → `git diff --staged`
  2. Unstaged changes → `git diff`
  3. Last commit → `git log -1 --patch`
- **File Filtering**: Skips XML files (layouts, menus, drawables)
- **Severity Pass-through**: Passes severity threshold to Skill

### 2. Skill Layer

**File**: `skills/android-code-review/SKILL.md`

**Responsibilities**:
- Load detection rules based on severity threshold
- Invoke Agent with context
- Filter agent results by confidence (>90%)
- Format output structure

**Severity-Based Rule Loading**:

| Severity | Token Cost | Patterns Loaded |
|----------|------------|-----------------|
| `critical` | ~1,500 | Security only |
| `high` | ~6,900 | Security + Quality + Architecture + Jetpack |
| `medium` | ~8,100 | Above + Performance |
| `all` | ~8,900 | All patterns |

**Rule Categories**:
- **CRITICAL** - Production blockers (NPE, memory leaks, security issues)
- **HIGH** - Structural decay (long methods, deep nesting, large classes)
- **MEDIUM** - Maintainability (business logic in UI, magic numbers)
- **LOW** - Best practices (naming, documentation, accessibility)

### 3. Agent Layer

**File**: `agents/android-code-reviewer.md`

**Responsibilities**:
- Read and analyze provided files
- Apply detection rules from Skill
- Score findings by confidence (0-100%)
- Filter out low-confidence findings (<90%)
- Output structured findings

**Confidence Scoring**:

| Confidence Range | Action |
|-----------------|--------|
| 90-100% | ✅ Report |
| 80-89% | ⚠️ Skip (near threshold) |
| <80% | ❌ Skip (false positive risk) |

---

## Detection Rule System

### Rule Format

Detection rules are embedded directly in `SKILL.md` as structured lists:

```markdown
### critical (~1,500 tokens)
Only Security patterns that cause production blockers:

* NullPointerException
* Fragment view/binding after `onDestroyView`
* Fragment transaction after state saved
* [ ... more rules ... ]
```

### Rule Categories

| Category | Severity | Focus | Example Rules |
|----------|----------|-------|---------------|
| **Security** | CRITICAL | Production blockers | Hardcoded secrets, Intent hijacking |
| **Quality** | HIGH | Structural decay | Long methods, deep nesting |
| **Architecture** | HIGH | Design issues | God objects, low cohesion |
| **Jetpack** | HIGH | Framework issues | ViewModel leaks, coroutine errors |
| **Performance** | MEDIUM | Efficiency | ANR risks, layout inefficiencies |
| **Practices** | LOW | Code quality | Naming, documentation |

### Progressive Loading

Rules are loaded progressively based on severity to minimize token usage:

```
User specifies --severity critical
    ↓
Skill loads ONLY CRITICAL rules (~1,500 tokens)
    ↓
Agent applies CRITICAL rules only
    ↓
Fast review, minimal token usage
```

---

## Performance Optimizations

### XML File Filtering

- Skips `*.xml` files (layouts, menus, drawables)
- 100% noise reduction for layout files

### Async Context Detection

- Only reports concurrent modifications when async context is detected
- Reduces false positives for collection modifications during iteration

### Confidence Threshold

- 90% confidence threshold
- Prioritizes precision over recall
- When in doubt, skip reporting rather than create noise

### Model-Agnostic Design

- No hardcoded model constraint
- Compatible with Haiku, Sonnet, Opus
- User chooses provider based on cost/quality needs

---

## Token Budget Management

### Token Cost Breakdown

| Component | Critical | High | Medium | All |
|-----------|----------|------|--------|-----|
| Command layer | ~1,000 | ~1,000 | ~1,000 | ~1,000 |
| Skill layer (rules) | ~500 | ~6,000 | ~7,200 | ~8,000 |
| Agent execution | ~1,500 | ~4,000 | ~4,500 | ~5,000 |
| **Total** | **~3,000** | **~11,000** | **~12,700** | **~14,000** |

**Note**: Token costs vary based on file size and complexity.

### Optimization Strategies

1. Use `--severity critical` for fast security scans
2. Review specific files instead of entire PRs
3. XML filtering is automatic
4. 90% confidence threshold reduces noise

---

## Output Format

```markdown
## Android Code Review Results

### 🔴 CRITICAL (N issues)
[Findings...]

### 🟠 HIGH (N issues)
[Findings...]

### 🟡 MEDIUM (N issues)
[Findings...]

## Review Summary
| Severity | Count | Status |
| CRITICAL | N     | fail/warn/pass |
| HIGH     | N     | fail/warn/pass |
| MEDIUM   | N     | fail/warn/pass |

**Verdict**: [APPROVED/WARNING/BLOCKED]
```

---

**Last Updated**: 2026-03-02
**Maintained By**: @daishengda2018
