---
name: android-code-review
description: Android Code Review v2.0.0-alpha with progressive rule loading and token budget management
last_updated: 2026-02-27
---

# Android Code Review v2.0 - Orchestration Layer

This orchestrator implements progressive rule loading, token budget management, and confidence-based filtering for Android code reviews.

## Parameters

- `target`: Review scope (staged|all|commit:<hash>|file:<path>|pr:<number|url>)
- `severity`: Filter level (critical|high|medium|low|all)
- `mode`: Execution mode (normal|light)
- `output-format`: Output format (markdown|json)
- `pr-context`: PR context (full|diff-only|commits-only)

## Progressive Rule Loading

See `agents/android-code-reviewer.md` for detailed file paths and token estimates.

| Severity | Categories | Files | Tokens |
|----------|------------|-------|--------|
| critical | SEC-* (P0) | security only | ~2,500 |
| high | P0-P1 | + quality + architecture + jetpack | ~12,000 |
| medium | P0-P2 | + performance | ~14,200 |
| all | P0-P3 | + practices | ~16,400 |

## Token Estimation

**Formula:** `base + (code_lines × 1.8) + rule_cost × mode_multiplier`

- Base: 600 tokens (request parsing + metadata)
- Code: 1.8 tokens per line
- Rule cost: See severity mapping table above
- Mode multiplier: light=0.7, normal=1.0

**Example:** 1000 lines, high severity, normal mode
= 600 + (1000 × 1.8) + 12000 = 14,400 tokens

**Budget Limits:**
- 200K context → 160K usable (20% margin) → 128K warning threshold
- 100K context → 80K usable (20% margin) → 64K warning threshold

## Confidence Scoring

Only report findings with ≥80% confidence.

**Formula:** `confidence = (semantic_score × 0.6) + (coverage_score × 0.4)`

- **Semantic Score (60%):** How well code matches the pattern
  - High (0.8-1.0): Exact match, multiple indicators, clear context
  - Medium (0.5-0.8): Partial match, some indicators
  - Low (<0.5): Weak match - skip reporting

- **Coverage Score (40%):** How many checklist criteria are satisfied
  - Each checklist item satisfied adds points
  - 3/4 items = 0.75 coverage score

**Thresholds:**
- High confidence: ≥0.9
- Medium confidence: 0.8-0.9
- Skip reporting: <0.8 (unless rule overrides)

## Token Budget Management

**Strategy:** Progressive degradation based on usage

| Usage Level | Trigger | Output | Rules |
|-------------|---------|--------|-------|
| Normal | <80% | Full with examples | All matched |
| Summary | 80-95% | Bullet points only | All matched |
| Critical | >95% | Minimal, SEC only | SEC only |
| Emergency | >98% | Abort | - |

**Checkpoints:**
- After metadata load (10%)
- After SEC rules (40%)
- After P1 rules (70%)
- During review (80% → enable summary mode)

## Confidence Filtering

**Noise Reduction:**
- Skip: Stylistic preferences, unchanged code issues (unless CRITICAL), hypothetical problems
- Consolidate: Multiple similar issues → 1 finding

**Filter Logic:**
1. Calculate confidence for each finding
2. Apply rule-specific threshold (default 0.8)
3. Report only if confidence ≥ threshold
4. Mark high/medium confidence in output

## Result Aggregation

Group findings by severity and category, calculate verdict:
- **BLOCK**: Any CRITICAL issues
- **WARN**: >5 HIGH issues
- **PASS**: Otherwise

## Output Formats

**Markdown:** Severity-based sections + confidence scores + verdict

**JSON Schema:**
```json
{
  "metadata": {"version": "2.0.0", "timestamp": "...", "target": "...", "severity": "..."},
  "findings": [{"rule_id": "SEC-001", "severity": "CRITICAL", "confidence": 0.95, ...}],
  "summary": {"total": 1, "by_severity": {"CRITICAL": 1, ...}},
  "verdict": "BLOCK"
}
```

## Execution Flow

1. Parse parameters (target, severity, mode)
2. Estimate tokens → warn if >128K
3. Load rule metadata (rules/rule-metadata.yaml)
4. Match rules by severity and mode
5. Load checklists progressively (check token budget after each)
6. Execute review with confidence filtering
7. Aggregate results by severity/category
8. Apply degradation if budget exceeded
9. Format output (markdown or JSON)
10. Return findings with verdict

## Error Handling

- **No changes**: "No code changes detected"
- **Invalid target**: "Invalid target. Use: staged|all|commit:<hash>|file:<path>|pr:<number>"
- **Token budget exceeded**: Auto-degrade or split review
- **No rules enabled**: Error (check disable configuration)

## Project-Specific Guidelines

Check `ANDROID.md` or use `--project-guidelines` parameter for:
- Architecture pattern (MVVM/MVI/Clean)
- SDK version requirements (minSdk, targetSdk)
- Kotlin vs Java requirements
- Testing coverage requirements
- Resource naming conventions
- DI framework (Hilt/Koin)

Adapt review to project's established patterns. When in doubt, match what the codebase does.
