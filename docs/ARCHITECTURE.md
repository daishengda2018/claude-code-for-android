# V3.x Architecture

**Version**: 3.0.4
**Last Updated**: 2026-02-28

This document provides a deep dive into the V3.x architecture of the Claude Code for Android plugin.

---

## Table of Contents

- [Overview](#overview)
- [Architecture Evolution](#architecture-evolution)
- [V3.x Architecture](#v3x-architecture)
- [Component Details](#component-details)
- [Data Flow](#data-flow)
- [Detection Rule System](#detection-rule-system)
- [Performance Optimizations](#performance-optimizations)

---

## Overview

### Plugin Purpose

The Claude Code for Android plugin provides automated code review for Android projects (Kotlin/Java), detecting:

- **Security vulnerabilities** (hardcoded secrets, insecure storage, etc.)
- **Code quality issues** (memory leaks, error handling, etc.)
- **Android pattern violations** (lifecycle issues, deprecated APIs, etc.)
- **Jetpack/Kotlin issues** (coroutine problems, Room errors, etc.)
- **Performance bottlenecks** (ANR risks, layout inefficiencies, etc.)
- **Best practice violations** (naming, documentation, accessibility, etc.)

### Design Principles

1. **Zero Configuration** — Smart auto-detection of code changes
2. **Confidence-Based Filtering** — Only reports issues with >90% confidence
3. **Token Efficiency** — Progressive pattern loading minimizes token usage
4. **Model Agnostic** — Compatible with all Claude providers (Haiku, Sonnet, Opus)

---

## Architecture Evolution

### V2.x Architecture (Deprecated)

```
User Command → Command → Agent → Subagents (3 layers)
                      ↓
                 Code Examples (verbose)
```

**Issues**:
- ❌ High token usage (code examples)
- ❌ Complex 3-layer architecture
- ❌ Unstable plugin discovery
- ❌ No marketplace integration

### V3.x Architecture (Current)

```
User Command → Command → Skill → Agent (3 layers, simplified)
                              ↓
                         Detection Patterns (concise)
```

**Improvements**:
- ✅ 38-39% token reduction (pattern-based detection)
- ✅ Simplified rule orchestration
- ✅ Stable plugin discovery (with `name` field)
- ✅ Proper marketplace integration

---

## V3.x Architecture

### Directory Structure

```
claude-code-for-android/
├── commands/
│   └── android-code-review.md         # User-facing command interface
│
├── agents/
│   └── android-code-reviewer.md       # Code review execution agent
│
├── skills/
│   └── android-code-review/
│       └── SKILL.md                   # Detection rules orchestration
│
├── .claude/                           # Development environment config
│   ├── plugin-manifest.json           # Project metadata
│   └── settings.json                  # Project settings (hooks, permissions)
│
├── .claude-plugin/                    # Marketplace metadata
│   ├── plugin.json                    # Plugin manifest for marketplace
│   └── marketplace.json               # Marketplace description
│
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

**Example Flow**:
```markdown
User runs: /android-code-review --target file:app/src/main/java/Example.kt
    ↓
Command collects file: app/src/main/java/Example.kt
    ↓
Command filters: Checks if file is *.xml → No, include
    ↓
Command invokes Skill with: { files: [...], severity: "high" }
```

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
| `all` | ~8,900 | All patterns including PR Context |

**Rule Categories**:
- **CRITICAL** — Production blockers (NPE, memory leaks, security issues)
- **HIGH** — Structural decay (long methods, deep nesting, large classes)
- **MEDIUM** — Maintainability (business logic in UI, magic numbers)
- **LOW** — Best practices (naming, documentation, accessibility)

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

**Output Format**:
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

## Data Flow

### Complete Execution Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. USER invokes command                                         │
│    /android-code-review --target file:Example.kt --severity high│
└────────────────────────┬────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│ 2. COMMAND LAYER                                                │
│  • Parse arguments (--target, --severity)                       │
│  • Collect files (git diff, staged, file:)                      │
│  • Filter out XML files                                         │
│  • Invoke Skill with context                                    │
└────────────────────────┬────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│ 3. SKILL LAYER                                                  │
│  • Receive: { files: [...], severity: "high" }                  │
│  • Load detection rules based on severity (HIGH → ~6,900 tokens)│
│  • Invoke Agent with rules and context                          │
└────────────────────────┬────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│ 4. AGENT LAYER                                                  │
│  • Receive: { files, rules, context }                           │
│  • Read code from files                                         │
│  • Apply detection rules                                        │
│  • Score findings by confidence                                 │
│  • Filter by confidence (>90%)                                  │
│  • Output structured findings                                   │
└────────────────────────┬────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│ 5. SKILL LAYER (return path)                                   │
│  • Receive agent findings                                       │
│  • Format output structure                                      │
│  • Return to Command                                            │
└────────────────────────┬────────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│ 6. COMMAND LAYER (return path)                                 │
│  • Receive formatted findings                                   │
│  • Present to user (markdown or JSON)                           │
└─────────────────────────────────────────────────────────────────┘
```

### Example: Reviewing a File

**Input**:
```bash
/android-code-review --target file:app/src/main/java/Example.kt --severity high
```

**Flow**:
1. **Command** collects `app/src/main/java/Example.kt`
2. **Command** filters: File is `.kt` → Include
3. **Command** invokes Skill with `{ files: ["Example.kt"], severity: "high" }`
4. **Skill** loads HIGH severity rules (~6,900 tokens)
5. **Skill** invokes Agent with `{ files, rules: [...], context: "HIGH severity" }`
6. **Agent** reads `Example.kt` content
7. **Agent** applies rules (e.g., "Handler without cleanup")
8. **Agent** detects issue → Scores confidence 95%
9. **Agent** outputs: `[{ severity: "HIGH", confidence: 95, issue: "..." }]`
10. **Skill** formats output → Returns to Command
11. **Command** presents markdown to user

---

## Detection Rule System

### Rule Format (Embedded in SKILL.md)

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

### 1. Pattern-Based Detection (V2.1.1)

**Before** (V2.0):
- Used verbose code examples
- High token usage

**After** (V2.1.1+):
- Uses concise detection patterns
- **38-39% token reduction**

### 2. XML File Filtering (V3.0.2)

**Before**:
- Reviewed all files including XML layouts
- High noise, wasted tokens

**After**:
- Skips `*.xml` files
- **100% noise reduction** for layout files

### 3. Async Context Detection (V3.0.2)

**Before**:
- Reported all collection modifications during iteration
- High false positive rate (~40%)

**After**:
- Only reports when async context is detected
- **80% fewer false positives**

### 4. Confidence Threshold (V3.0.3)

**Before** (V3.0.2):
- 85% confidence threshold
- More false positives

**After** (V3.0.3+):
- 90% confidence threshold
- **22% additional token savings** (fewer issues reported)

### 5. Model-Agnostic Design (V3.0.4)

**Before**:
- Hardcoded `model: sonnet` in agent
- Limited provider compatibility

**After**:
- Removed model constraint
- Compatible with Haiku, Sonnet, Opus

---

## Token Budget Management

### Token Cost Breakdown (V3.0.4)

| Component | Critical | High | Medium | All |
|-----------|----------|------|--------|-----|
| Command layer | ~1,000 | ~1,000 | ~1,000 | ~1,000 |
| Skill layer (rules) | ~500 | ~6,000 | ~7,200 | ~8,000 |
| Agent execution | ~1,500 | ~4,000 | ~4,500 | ~5,000 |
| **Total** | **~3,000** | **~11,000** | **~12,700** | **~14,000** |

**Note**: Token costs vary based on file size and complexity.

### Optimization Strategies

1. **Use `--severity critical`** for fast security scans
2. **Review specific files** instead of entire PRs
3. **Enable XML filtering** (automatic in V3.0.2+)
4. **Increase confidence threshold** (90% in V3.0.3+)

---

## Comparison: V2.x vs V3.x

| Aspect | V2.x | V3.x |
|--------|------|------|
| **Architecture** | 3 layers (complex) | 3 layers (simplified) |
| **Rule Storage** | Separate code examples | Embedded patterns |
| **Token Usage** | Baseline | ~55% reduction |
| **Confidence Threshold** | 80% | 90% |
| **Plugin Discovery** | Unstable | Fixed (`name` field) |
| **Marketplace Support** | No | Yes (`plugin.json`) |
| **XML Filtering** | No | Yes |
| **Async Detection** | No | Yes |
| **Model Compatibility** | Sonnet only | All providers |

---

## Future Architecture Plans

### Reserved Permissions

The plugin includes `python3:*` permission in `.claude/settings.json` for future features:

- **Automated test report generation** — Parse test results and generate summary reports
- **Statistical data visualization** — Create charts from code quality metrics
- **Performance metrics analysis** — Analyze token usage and performance patterns

**Current Status**: Reserved but not actively used.

---

## Related Documentation

- [Migration Guide](MIGRATION.md) — V2.x → V3.x migration details
- [Token Optimization](TOKEN-OPTIMIZATION.md) — Performance optimization details
- [Development Guide](../DEVELOPMENT.md) — Plugin development guide
- [User Guide](guides/USER_GUIDE.md) — Complete usage guide

---

**Last Updated**: 2026-02-28
**Maintained By**: @daishengda2018
