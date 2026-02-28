---
name: android-code-review
description: Android Code Review v2.1 - Token-optimized with progressive pattern loading
type: command
skill:
  name: android-code-review
  type: orchestration-layer
  description: Pattern-based detection with token budget management
parameters:
  - name: target
    type: string
    required: true
    description: "staged|all|commit:<hash>|file:<path>|pr:<number|url>"

  - name: severity
    type: string
    required: false
    default: "all"
    description: "critical|high|medium|low|all (controls progressive loading)"
    enum: ["critical", "high", "medium", "low", "all"]

  - name: mode
    type: string
    required: false
    default: "normal"
    description: "legacy (deprecated) | normal"
    enum: ["normal", "legacy"]
    deprecated: "Use 'normal' - legacy mode removed in v2.1"

  - name: output-format
    type: string
    required: false
    default: "markdown"
    description: "markdown|json (v2.1 schema with confidence scores)"
    enum: ["markdown", "json"]

  - name: pr-context
    type: string
    required: false
    default: "full"
    description: "PR context: full|diff-only|commits-only"
    enum: ["full", "diff-only", "commits-only"]

  - name: project-guidelines
    type: string
    required: false
    description: "Path to project-specific guidelines (e.g., ANDROID.md, lint.xml)"

---

## Quick Start

```bash
# Security-critical review (84% token reduction)
android-code-review --target staged --severity critical

# High-severity review with JSON output
android-code-review --target file:app/src/main/java/... --severity high --output-format json

# CI/CD quality gate
android-code-review --target ${{ github.sha }} --severity high --output-format json > review.json
```

## v2.1 Features

- **Token Optimization**: 37-40% reduction through pattern-based detection
- **Progressive Loading**: Load only patterns needed for severity level
- **Pattern Caching**: Reuse patterns across multiple file reviews
- **Confidence Scoring**: Filter findings by confidence threshold (≥0.8)

## Execution Flow

1. Parse target (validate git hash/file path)
2. Estimate tokens: `600 + (code_lines × 1.8) + patterns_by_severity`
3. Load patterns progressively based on severity
4. Apply detection patterns with confidence filtering
5. Output findings (markdown or JSON v2.1 schema)

## Token Budget

| Severity | Pattern Cost | Total Estimation* |
|----------|-------------|-------------------|
| `critical` | ~1,500 | 4,500 |
| `high` | ~6,900 | 9,700 |
| `medium` | ~8,100 | 11,200 |
| `all` | ~8,900 | 12,000 |

*Includes command (1,000) + skill overhead (1,800) + code analysis

## v2.1 JSON Schema

```json
{
  "metadata": {
    "version": "2.1.0",
    "timestamp": "2026-02-28T10:00:00Z",
    "target": "staged",
    "severity": "high",
    "patterns_loaded": ["security", "quality", "architecture", "jetpack"]
  },
  "findings": [
    {
      "rule_id": "SEC-001",
      "severity": "CRITICAL",
      "category": "Security",
      "file": "app/src/main/java/.../ApiClient.kt",
      "line": 18,
      "issue": "Hardcoded API key detected",
      "fix": "Move to gradle.properties, inject via BuildConfig",
      "confidence": 0.95,
      "pattern_matches": ["sk_live_...", "const val API_KEY"]
    }
  ],
  "summary": {
    "total": 5,
    "by_severity": {"CRITICAL": 1, "HIGH": 2, "MEDIUM": 2, "LOW": 0},
    "confidence_avg": 0.87
  },
  "verdict": "WARNING"
}
```

## Error Handling

| Error | Message | Solution |
|-------|---------|----------|
| No changes | "No code changes detected" | Stage files or specify commit |
| Invalid target | "Invalid target. Use: staged\|all\|commit:<hash>\|file:<path>" | Check target format |
| Invalid mode | "Error: --mode legacy is deprecated. Use --mode normal" | Update command |
| Token budget | "Auto-degrading to summary mode" | Reduce severity level |

## Deprecation Notice

**v1.0 Agent (Legacy)** - DEPRECATED
- Deprecated: 2026-02-27
- End of Life: 2026-06-30
- Migration: Remove `--mode legacy`, use `--mode normal`

**v2.0 References** - DEPRECATED
- Replaced by pattern-based detection in v2.1
- references/ moved to docs/reference/ for documentation

---

**See `skills/android-code-review/SKILL.md` for complete execution details.**
