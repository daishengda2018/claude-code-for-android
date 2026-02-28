---
name: android-code-review
description: Android Code Review v2.1 - Optimized for token efficiency with progressive rule loading
last_updated: 2026-02-28
---

# Android Code Review v2.1 - Rule Knowledge Base

This skill provides progressive rule loading, token budget management, and confidence-based filtering for Android code reviews.

## Quick Start

When invoked via `android-code-reviewer` agent:

1. Parse `--severity` parameter to determine which rules to load
2. Load rule references progressively based on severity
3. Apply confidence filter (0.8 threshold)
4. Report findings using the output format

---

## Severity-Based Rule Loading

| Severity | Categories | Token Cost |
|----------|-----------|------------|
| `critical` | Security (SEC-*) only | ~2,500 |
| `high` | Security + Quality + Architecture + Jetpack | ~12,000 |
| `medium` | Above + Performance | ~14,200 |
| `all` | All rules including Best Practices | ~16,400 |

**Loading Strategy**: Load only the rule reference files needed for the requested severity level.

---

## Token Budget Management

### Thresholds

- **WARNING**: 128,000 tokens (80% of budget)
- **CRITICAL**: 152,000 tokens (95% of budget)
- **MAX**: 160,000 tokens (usable budget)

### Degradation Strategy

| Usage Level | Action | Output Format |
|-------------|--------|---------------|
| < 80% | Normal | Full details with code examples |
| 80-95% | Summary mode | Bullet points only, no examples |
| > 95% | Critical only | Security rules only, minimal output |

---

## Confidence-Based Filtering

### Formula

```
confidence = (semantic_match × 0.6) + (coverage_score × 0.4)
```

- **semantic_match** (0-1): How well code matches the rule pattern
- **coverage_score** (0-1): How many checklist criteria are satisfied

### Threshold

- **Report if**: confidence ≥ 0.8
- **Skip if**: confidence < 0.8

### Example

```
Finding: Hardcoded API key "sk_live_abc123"
- Semantic match: 0.95 (exact match with "sk_" prefix)
- Coverage score: 0.75 (3/4 checklist items)
- Confidence: (0.95 × 0.6) + (0.75 × 0.4) = 0.87
- Result: REPORT (0.87 ≥ 0.8)
```

---

## Rule Reference Files

### Security Rules (Critical)

**File**: `references/sec-001-to-010-security.md`

**Rules**: SEC-001 to SEC-010
- Hardcoded credentials
- Insecure storage
- Unsafe Intents
- WebView flaws
- Cleartext traffic
- Permission abuse
- Data leakage
- Outdated dependencies

### Quality Rules (High)

**File**: `references/qual-001-to-010-quality.md`

**Rules**: QUAL-001 to QUAL-010
- Memory leaks
- Large functions (>50 lines)
- Large files (>800 lines)
- Deep nesting (>4 levels)
- Missing error handling
- Unsafe `!!` operator
- Dead code
- Debug code

### Architecture Rules (High)

**File**: `references/arch-001-to-009-architecture.md`

**Rules**: ARCH-001 to ARCH-009
- Lifecycle violations
- ViewModel misuse
- Fragment anti-patterns
- Resource hardcoding
- Main thread blocking
- Deprecated APIs

### Jetpack/Kotlin Rules (High)

**File**: `references/jetp-001-to-008-jetpack.md`

**Rules**: JETP-001 to JETP-008
- Coroutine misconfiguration
- State management issues
- Room N+1 queries
- Hilt errors
- Compose anti-patterns
- Navigation issues

### Performance Rules (Medium)

**File**: `references/perf-001-to-008-performance.md`

**Rules**: PERF-001 to PERF-008
- ANR risks
- Layout inefficiencies
- Bitmap issues
- Startup bottlenecks
- Resource bloat
- SharedPreferences overhead

### Best Practices Rules (Low)

**File**: `references/prac-001-to-008-practices.md`

**Rules**: PRAC-001 to PRAC-008
- TODO without tracking
- Missing documentation
- Poor naming
- Magic numbers
- Inconsistent formatting
- Missing accessibility

---

## Parameter Reference

### Input Parameters

- `target`: Review scope (staged|all|commit:<hash>|file:<path>)
- `severity`: Filter level (critical|high|medium|low|all)
- `mode`: Execution mode (normal|light|legacy)
- `output-format`: Output format (markdown|json)

### Severity Matching Algorithm

```
critical → Load SEC rules
high → Load SEC + QUAL + ARCH + JETP rules
medium → Load above + PERF rules
low/all → Load all rules
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

- **v2.1** (2026-02-28): Token optimization - removed redundant pseudocode, simplified loading logic
- **v2.0** (2026-02-27): Progressive rule loading and token budget management
- **v1.0** (2026-02-26): Initial monolithic agent
