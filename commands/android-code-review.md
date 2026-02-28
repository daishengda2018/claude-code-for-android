---
name: android-code-review
description: Android Code Review v2.1 - Smart detection with progressive pattern loading
type: command
skill:
  name: android-code-review
  type: orchestration-layer
  description: Pattern-based detection with auto-detection of review scope
parameters:
  - name: target
    type: string
    required: false
    default: "auto"
    description: "auto|staged|all|commit:<hash>|file:<path>|pr:<number>"
    note: "auto: staged changes → unstaged → last commit"

  - name: severity
    type: string
    required: false
    default: "high"
    description: "critical|high|medium|low|all (default: high)"

  - name: output-format
    type: string
    required: false
    default: "markdown"
    description: "markdown|json"

---

## Smart Auto-Detection (Default)

When `--target` is omitted or set to `auto`:

```bash
android-code-review
```

**Detection order:**
1. **Staged changes** → `git diff --staged`
2. **Unstaged changes** → `git diff`
3. **Last commit** → `git log -1 --patch`

## Usage Examples

```bash
# Auto-detect review scope (recommended)
android-code-review

# Security-only review
android-code-review --severity critical

# Specific file
android-code-review --target file:app/src/main/java/ApiClient.kt

# Specific commit
android-code-review --target commit:abc123

# JSON output for CI/CD
android-code-review --output-format json > review.json
```

## Token Efficiency (v2.1)

| Severity | Patterns | Total* |
|----------|----------|--------|
| critical | 1,500 | ~4,500 |
| high | 6,900 | ~9,700 |
| all | 8,900 | ~12,000 |

\*Command (1,000) + Skill (1,800) + Patterns + Code

**Average savings: 38-39% vs v2.0**

---

**See `skills/android-code-review/SKILL.md` for execution details.**
