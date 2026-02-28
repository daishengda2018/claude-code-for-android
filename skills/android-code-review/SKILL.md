---
name: android-code-review
description: Android Code Review v2.1 - Token-optimized, pattern-based detection with progressive rule loading
last_updated: 2026-02-28
---

# Android Code Review v2.1 - Optimized Skill

This skill provides token-efficient Android code review with progressive rule loading and confidence-based filtering.

## Quick Start

When invoked via `/android-code-review` command:

1. Parse `--severity` parameter to determine which patterns to load
2. Load pattern files progressively based on severity
3. Apply confidence filter (≥0.8 threshold)
4. Report findings using the output format
5. Cache patterns for subsequent reviews in same session

---

## Agent Integration (Simplified Architecture)

This skill now includes the agent logic directly (no separate agent file):

### Review Process

1. **Gather context** — Run `git diff --staged` or `git diff` to see changes. If no diff, check recent commits with `git log --oneline -5`.

2. **Understand scope** — Identify files, intent, and Android components (Activities, Fragments, ViewModels, Composables).

3. **Read surrounding code** — Don't review in isolation. Read full files for dependencies and lifecycle.

4. **Load patterns** — Based on `--severity` parameter, load only relevant pattern files:
   - `critical` → `patterns/security-patterns.md` only (~1,500 tokens)
   - `high` → Security + Quality + Architecture + Jetpack (~6,900 tokens)
   - `medium` → Above + Performance (~8,100 tokens)
   - `all` → All patterns including Best Practices (~8,900 tokens)

5. **Apply patterns** — Use detection patterns from loaded files to identify issues.

6. **Report findings** — Use the output format below.

### Commit Type Focus

Match your focus to commit intent:

| Commit Type | Focus Areas |
|-------------|------------|
| `feat:` | Architecture, lifecycle, state management, tests |
| `fix:` | Root cause, edge cases, error handling, regression tests |
| `refactor:` | Side effects, migration completeness, no old code left |
| `perf:` | Measurable improvements, regression risks, benchmarks |
| `test:` | Coverage, assertions, test isolation |
| `chore:` | Dependencies, config, documentation |

---

## Severity-Based Pattern Loading

| Severity | Pattern Files | Token Cost |
|----------|--------------|------------|
| `critical` | Security only | ~1,500 |
| `high` | Security + Quality + Architecture + Jetpack | ~6,900 |
| `medium` | Above + Performance | ~8,100 |
| `all` | All patterns including Best Practices | ~8,900 |

**Loading Strategy**: Load only the pattern files needed for the requested severity level.

**Optimization**: Patterns use detection rules instead of code examples, reducing token usage by 40-50%.

---

## Token Budget Management

### Thresholds

- **WARNING**: 128,000 tokens (80% of budget)
- **CRITICAL**: 152,000 tokens (95% of budget)
- **MAX**: 160,000 tokens (usable budget)

### Degradation Strategy

| Usage Level | Action | Output Format |
|-------------|--------|---------------|
| < 80% | Normal | Full details with fix suggestions |
| 80-95% | Summary mode | Bullet points only, minimal examples |
| > 95% | Critical only | Security patterns only, essential output |

### Caching Strategy

If reviewing multiple files in same session:
- First review: Load all patterns for severity level
- Subsequent reviews: "Use cached patterns from previous review" (reduces token usage)

---

## Confidence-Based Filtering

### Formula

```
confidence = (semantic_match × 0.6) + (coverage_score × 0.4)
```

- **semantic_match** (0-1): How well code matches the detection pattern
- **coverage_score** (0-1): How many pattern criteria are satisfied

### Threshold

- **Report if**: confidence ≥ 0.8
- **Skip if**: confidence < 0.8

### Example

```
Finding: Hardcoded API key "sk_live_abc123"
- Semantic match: 0.95 (exact match with "sk_" prefix)
- Coverage score: 0.75 (matches 3/4 pattern criteria)
- Confidence: (0.95 × 0.6) + (0.75 × 0.4) = 0.87
- Result: REPORT (0.87 ≥ 0.8)
```

---

## Pattern Files Reference

### Security Patterns (Critical)

**File**: `patterns/security-patterns.md`

**Rules**: SEC-001 to SEC-010
- Hardcoded credentials, insecure storage, unsafe Intents
- WebView flaws, cleartext traffic, permission abuse
- Data leakage, outdated dependencies, SSL/TLS issues
- Encryption algorithm flaws

**Token**: ~1,500 (optimized from 2,500, **-40%**)

### Quality Patterns (High)

**File**: `patterns/quality-patterns.md`

**Rules**: QUAL-001 to QUAL-010
- Memory leaks, long functions, deep nesting
- Missing error handling, unsafe null access
- Debug code, dead code, test coverage, readability

**Token**: ~1,800 (optimized from 3,200, **-44%**)

### Architecture Patterns (High)

**File**: `patterns/architecture-patterns.md`

**Rules**: ARCH-001 to ARCH-009
- Lifecycle violations, ViewModel misuse, Fragment anti-patterns
- Resource hardcoding, main thread blocking, deprecated APIs
- Permission handling, config changes, View binding issues

**Token**: ~1,500 (optimized from 2,800, **-46%**)

### Jetpack/Kotlin Patterns (High)

**File**: `patterns/jetpack-patterns.md`

**Rules**: JETP-001 to JETP-008
- Coroutine misconfiguration, state management issues
- Room N+1 queries, Hilt errors, Compose anti-patterns
- Navigation issues, DataStore, WorkManager

**Token**: ~1,800 (optimized from 3,500, **-49%**)

### Performance Patterns (Medium)

**File**: `patterns/performance-patterns.md`

**Rules**: PERF-001 to PERF-008
- ANR risks, layout inefficiencies, bitmap issues
- Startup bottlenecks, memory leaks, list performance
- SharedPreferences, network optimization

**Token**: ~1,200 (optimized from 2,400, **-50%**)

### Best Practices Patterns (Low)

**File**: `patterns/practices-patterns.md`

**Rules**: PRAC-001 to PRAC-008
- TODO tracking, documentation, naming conventions
- Magic numbers, formatting, exception handling
- Accessibility, hardcoded config

**Token**: ~800 (optimized from 1,700, **-53%**)

---

## Parameter Reference

### Input Parameters

- `target`: Review scope (staged|all|commit:<hash>|file:<path>)
- `severity`: Filter level (critical|high|medium|low|all)
- `mode`: Execution mode (normal|light - light mode deprecated, use normal)
- `output-format`: Output format (markdown|json)

### Severity Matching Algorithm

```
critical → Load security patterns
high → Load security + quality + architecture + jetpack patterns
medium → Load above + performance patterns
low/all → Load all patterns
```

---

## Output Schema

### Finding Object

```json
{
  "rule_id": "SEC-001",
  "severity": "CRITICAL",
  "category": "Security",
  "file": "app/src/main/java/.../ApiClient.kt",
  "line": 18,
  "issue": "Hardcoded API key detected",
  "fix": "Move to gradle.properties, inject via BuildConfig",
  "confidence": 0.95
}
```

### Summary Object

```json
{
  "total": 10,
  "by_severity": {
    "CRITICAL": 1,
    "HIGH": 3,
    "MEDIUM": 4,
    "LOW": 2
  },
  "verdict": "WARNING"
}
```

---

## Review Output Format

```
[CRITICAL] Hardcoded API key in source code
File: app/src/main/java/com/example/ApiClient.kt:18
Issue: Production API key "sk_live_abc123" is hardcoded in source code.
Fix: Move to gradle.properties, inject via BuildConfig.

## Review Summary

| Severity | Count | Status |
|----------|-------|--------|
| CRITICAL | 0     | pass   |
| HIGH     | 2     | warn   |
| MEDIUM   | 3     | info   |
| LOW      | 1     | note   |

Verdict: WARNING — 2 HIGH issues should be resolved before merge.
```

---

## Approval Criteria

- **Approve**: No CRITICAL or HIGH issues
- **Warning**: Only HIGH issues (tracked + scheduled)
- **Block**: CRITICAL issues (fix before merge)

---

## Project-Specific Guidelines

Check for project-specific configuration files:
- `ANDROID_GUIDELINES.md` in project root
- `--project-guidelines` parameter
- Architecture patterns (MVVM/MVI/Clean Architecture)
- SDK version requirements (minSdk, targetSdk)
- Testing coverage requirements

**Adapt your review to the project's established patterns. When in doubt, match what the rest of the codebase does.**

---

## Noise Reduction Rules

**Skip**:
- Stylistic preferences only
- Issues in unchanged code (unless CRITICAL)
- Hypothetical problems without evidence

**Consolidate**:
- Multiple similar issues → 1 finding with count
- Same issue across files → 1 finding with file list

---

## Version History

- **v2.1** (2026-02-28): **Major Token Optimization**
  - Introduced pattern-based detection (replaces code examples)
  - Merged agent logic into skill (simplified architecture)
  - Reduced token usage by 40-50%
  - Added pattern caching for multi-file reviews

- **v2.0** (2026-02-27): Progressive rule loading and token budget management

- **v1.0** (2026-02-26): Initial monolithic agent

---

## Token Optimization Summary

| Component | v2.0 | v2.1 | Improvement |
|-----------|------|------|-------------|
| **Command** | ~1,000 | ~1,000 | - |
| **Agent** | ~600 | 0 | Merged into Skill |
| **Skill** | ~1,300 | ~1,800 | +38% (includes agent logic) |
| **Patterns (high)** | ~12,000 | ~6,900 | **-42%** |
| **Total (high)** | ~15,500 | ~9,700 | **-37%** |

**Key Changes**:
1. Pattern-based detection replaces code examples (40-50% reduction)
2. Agent merged into Skill (simplified architecture)
3. Caching strategy for multi-file reviews
4. More efficient severity-based loading
