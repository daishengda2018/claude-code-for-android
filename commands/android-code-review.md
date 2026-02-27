---
name: android-code-review
description: Android Code Review v2.0.0-alpha - Progressive rule loading, token budget management, PR support
type: command
skill:
  name: android-code-review
  type: orchestration-layer
  description: Uses SKILL.md v2.0 orchestration layer for efficient Android code reviews
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
    description: "light (0.7x tokens)|normal"
    enum: ["light", "normal"]
    deprecated: "legacy mode removed, use normal instead"

  - name: output-format
    type: string
    required: false
    default: "markdown"
    description: "markdown|json (v2.0 schema with confidence scores)"
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

## v2.0 Execution Flow

1. **Parse & Estimate**
   - Parse target (validate git hash/file path)
   - Estimate tokens: `600 + (code_lines × 1.8) + rules_by_severity × mode_multiplier`
   - Warn if > WARNING_THRESHOLD (128,000)

2. **Progressive Loading** (v2.0 core)
   - Load SKILL.md orchestration layer
   - Match rules by severity:
     * `critical` → SEC only (~2,500 tokens)
     * `high` → SEC+QUAL+ARCH+JETP (~12,000)
     * `medium` → +PERF (~14,200)
     * `all` → +PRAC (~16,400)
   - Load checklists in priority order with checkpoint checks
   - Apply degradation if needed (normal→summary→critical)

3. **Review Execution**
   - Load project guidelines if provided (ANDROID.md, lint.xml)
   - For PR: Fetch metadata + parse pr-context
   - For non-PR: Git diff + code analysis
   - Calculate confidence: `(semantic × 0.6) + (coverage × 0.4)`
   - Filter findings: only report if confidence ≥ threshold (default 0.8)

4. **Output**
   - Markdown: Severity-based + confidence scores + verdict
   - JSON: v2.0 schema with `metadata`, `findings[]`, `summary`, `verdict`

## Usage Examples

```bash
# Security-critical review (84% token reduction)
android-code-review --target staged --severity critical

# High-severity PR review with JSON output
android-code-review --target pr:123 --severity high --output-format json

# Large project: light mode + batch by module
android-code-review --target file:app/src/core/ --mode light --severity medium

# With project-specific guidelines
android-code-review --target staged --project-guidelines ./ANDROID.md

# CI/CD quality gate
android-code-review --target ${{ github.sha }} --severity high --output-format json > review.json
```

## v2.0 JSON Schema

```json
{
  "metadata": {"version": "2.0.0", "timestamp": "...", "target": "...", "severity": "..."},
  "findings": [
    {
      "rule_id": "SEC-001",
      "severity": "CRITICAL",
      "confidence": 0.95,
      "file": "...",
      "line": 23,
      "message": "...",
      "code_snippet": "..."
    }
  ],
  "summary": {"total": 1, "by_severity": {"CRITICAL": 1, "HIGH": 0, "MEDIUM": 0, "LOW": 0}},
  "verdict": "BLOCK"
}
```

## Error Handling

- No changes: "No code changes detected"
- Invalid target: "Invalid target. Use: staged|all|commit:<hash>|file:<path>|pr:<number>"
- Token budget exceeded: Auto-degrade or split review
- Invalid mode: "Error: --mode legacy is deprecated. Use --mode normal instead."

## Deprecation Notice

**V1.0 Agent (Legacy Mode) - DEPRECATED**
- Deprecated: 2025-02-27
- End of Life: 2025-06-30
- Action: Migrate to v2.0 by removing `--mode legacy` parameter
- Migration guide: See `docs/plans/2025-02-27-implementation-summary.md`
