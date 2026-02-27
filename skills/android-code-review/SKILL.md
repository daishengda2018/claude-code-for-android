---
name: android-code-review
description: Android Code Review v2.0.0-alpha with progressive rule loading and token budget management
last_updated: 2026-02-27
---

# Android Code Review v2.0 - Orchestration Layer

This orchestrator implements progressive rule loading, token budget management, and confidence-based filtering for Android code reviews.

## Version Information
- **v2.0**: Current implementation with progressive loading
- **V1.0**: Legacy monolithic agent (use --legacy flag)

---

## Parameter Parsing

### Input Parameters
- `target`: Review scope (staged|all|commit:<hash>|file:<path>)
- `severity`: Filter level (critical|high|medium|low|all)
- `mode`: Execution mode (normal|light|legacy)
- `output-format`: Output format (markdown|json)

### Parsing Logic

```yaml
# Parse target parameter
if target starts with "commit:":
  extract commit hash
  validate: git rev-parse <hash> succeeds
elif target starts with "file:":
  extract file path
  validate: file exists and is *.kt|*.java|*.xml
elif target == "staged":
  validate: git diff --staged produces output
elif target == "all":
  validate: git diff produces output
else:
  error: "Invalid target. Use: staged|all|commit:<hash>|file:<path>"
```

### Severity Mapping

| User Input | Rule Categories | Token Estimate |
|------------|----------------|----------------|
| critical | SEC-* (P0) | 2,500 |
| high | SEC-* + QUAL-* + ARCH-* + JETP-* (P0-P1) | 12,000 |
| medium | All except PRAC-* (P0-P2) | 14,200 |
| low / all | All rules (P0-P3) | 16,400 |

---

## Token Estimation

### Formula

```python
def estimate_tokens(code_lines: int, severity: str, mode: str) -> int:
    """Estimate token consumption for review"""

    # Base cost (request parsing + metadata loading)
    base = 600

    # Code cost (1.8 tokens per line of code)
    code_cost = code_lines * 1.8

    # Rule cost by severity
    rule_costs = {
        "critical": 2500,   # SEC only
        "high": 12000,      # SEC + QUAL + ARCH + JETP
        "medium": 14200,    # All except PRAC
        "low": 16400,       # All rules
        "all": 16400
    }

    # Mode multiplier
    mode_multipliers = {
        "light": 0.7,       # Omit code examples
        "normal": 1.0,
        "legacy": 1.3       # Full V1.0 compatibility
    }

    rule_cost = rule_costs.get(severity, 16400)
    mode_multiplier = mode_multipliers.get(mode, 1.0)

    total = int((base + code_cost + rule_cost) * mode_multiplier)

    return total
```

### Usage Example

```yaml
# Example: 1000 lines of code, high severity, normal mode
code_lines: 1000
severity: high
mode: normal

estimate = 600 + (1000 * 1.8) + 12000
estimate = 600 + 1800 + 12000 = 14400 tokens
```

### Budget Limits

| Context Window | Safety Margin | Usable Budget | Warning Threshold |
|----------------|---------------|---------------|-------------------|
| 200,000 | 20% | 160,000 | 128,000 (80%) |
| 100,000 | 20% | 80,000 | 64,000 (80%) |

---

## Rule Metadata Loading

### Load rule-metadata.yaml

```yaml
# Step 1: Read rule metadata
read_file: rules/rule-metadata.yaml

# Step 2: Parse YAML structure
rules = yaml_data["rules"]

# Step 3: Build index
rule_index = {
  "by_id": {rule["rule_id"]: rule for rule in rules},
  "by_category": {
    "SEC": [r for r in rules if r["category"] == "Security"],
    "QUAL": [r for r in rules if r["category"] == "Code Quality"],
    "ARCH": [r for r in rules if r["category"] == "Architecture"],
    "JETP": [r for r in rules if r["category"] == "Jetpack/Kotlin"],
    "PERF": [r for r in rules if r["category"] == "Performance"],
    "PRAC": [r for r in rules if r["category"] == "Best Practices"]
  },
  "by_severity": {
    "P0": [r for r in rules if r["severity"] == "P0"],
    "P1": [r for r in rules if r["severity"] == "P1"],
    "P2": [r for r in rules if r["severity"] == "P2"],
    "P3": [r for r in rules if r["severity"] == "P3"]
  }
}
```

### Metadata Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| rule_id | string | Yes | Unique identifier (SEC-001) |
| severity | string | Yes | P0/P1/P2/P3 |
| category | string | Yes | Security/Code Quality/... |
| enabled | boolean | Yes | Whether rule is active |
| confidence_threshold | float | Yes | Min confidence (0.0-1.0) |
| priority_weight | int | Yes | 100-20 for trimming |
| global_priority | boolean | Yes | Cannot be overridden by projects |
| checklist_path | string | Yes | Path to checklist file |
| checklist_token_estimate | int | Yes | Estimated tokens |

---

## Rule Disable Configuration

### Load rule-disable.yaml

```yaml
# Step 1: Read disable config
read_file: rules/rule-disable.yaml

# Step 2: Parse disabled rules
disabled_rules = yaml_data.get("disabled_rules", [])

# Step 3: Parse severity-based disables
severity_disables = yaml_data.get("severity_based_disables", {})

# Step 4: Apply to rule index
for disabled_rule in disabled_rules:
  rule_id = disabled_rule["rule_id"]
  if rule_id in rule_index["by_id"]:
    rule_index["by_id"][rule_id]["enabled"] = False

# Step 5: Apply category-based disables
for mode, config in severity_disables.items():
  for category in config.get("disabled_categories", []):
    for rule in rule_index["by_category"].get(category, []):
      rule["enabled"] = False
```

### Example Configuration

```yaml
# rule-disable.yaml
disabled_rules:
  - rule_id: PRAC-001
    reason: "Project has legacy TODO tracking"
    disabled_until: "2025-03-31"

severity_based_disables:
  lightweight_mode:
    disabled_categories:
      - PRAC    # Skip best practices
      - PERF    # Skip performance rules
```

### Validation

After applying disables, verify:
```python
enabled_count = sum(1 for r in rules if r["enabled"])
total_count = len(rules)

if enabled_count == 0:
  error: "No rules enabled after applying disable configuration"
```

---

## Severity-Based Rule Matching

### Matching Algorithm

```python
def match_rules(severity: str, mode: str) -> List[Rule]:
    """Match rules based on severity and mode"""

    # Map severity to categories
    severity_map = {
        "critical": ["SEC"],           # P0 only
        "high": ["SEC", "QUAL", "ARCH", "JETP"],  # P0-P1
        "medium": ["SEC", "QUAL", "ARCH", "JETP", "PERF"],  # P0-P2
        "low": ["SEC", "QUAL", "ARCH", "JETP", "PERF", "PRAC"],  # All
        "all": ["SEC", "QUAL", "ARCH", "JETP", "PERF", "PRAC"]
    }

    # Get categories for severity
    categories = severity_map.get(severity, severity_map["all"])

    # Collect rules from categories
    matched_rules = []
    for category in categories:
      matched_rules.extend(rule_index["by_category"].get(category, []))

    # Filter enabled rules
    matched_rules = [r for r in matched_rules if r["enabled"]]

    # Apply mode filtering
    if mode == "light":
      # In light mode, skip rules with low priority
      matched_rules = [r for r in matched_rules if r["priority_weight"] >= 40]

    return matched_rules
```

### Matching Examples

```yaml
# Example 1: Critical severity
Input: severity="critical"
Output: [SEC-001, SEC-002, ..., SEC-010]  # 10 rules
Tokens: ~2,500

# Example 2: High severity
Input: severity="high"
Output: [SEC-*, QUAL-*, ARCH-*, JETP-*]  # 37 rules
Tokens: ~12,000

# Example 3: Light mode with high severity
Input: severity="high", mode="light"
Output: [SEC-*, QUAL-*, ARCH-*, JETP-* with priority >= 40]
Tokens: ~8,400 (30% reduction)
```

---

## Progressive Checklist Loading

### Loading Strategy

**DO NOT load all checklists at once.** Load progressively based on matched rules.

### Algorithm

```python
def load_checklists(matched_rules: List[Rule]) -> Dict[str, str]:
    """Load checklist files progressively"""

    # Group rules by checklist file
    checklist_groups = {}
    for rule in matched_rules:
      checklist_path = rule["checklist_path"]
      if checklist_path not in checklist_groups:
        checklist_groups[checklist_path] = []
      checklist_groups[checklist_path].append(rule)

    # Load checklists in priority order
    loaded_checklists = {}
    load_order = [
        "references/sec-001-to-010-security.md",
        "references/arch-001-to-009-architecture.md",
        "references/jetp-001-to-008-jetpack.md",
        "references/qual-001-to-010-quality.md",
        "references/perf-001-to-008-performance.md",
        "references/prac-001-to-008-practices.md"
    ]

    for checklist_path in load_order:
      if checklist_path in checklist_groups:
        # Load checklist
        content = read_file(checklist_path)
        loaded_checklists[checklist_path] = content

        # Check token budget after each load
        current_tokens = estimate_current_usage()
        if current_tokens > WARNING_THRESHOLD:
          log_warning(f"Token budget at {current_tokens}/{BUDGET}")
          if current_tokens > CRITICAL_THRESHOLD:
            log_error("Critical token threshold reached")
            break

    return loaded_checklists
```

### Token Checkpoints

| Phase | Trigger | Threshold | Action |
|-------|---------|-----------|--------|
| After metadata load | Metadata loaded | 10% | Continue |
| After SEC rules | SEC checklist loaded | 40% | Continue |
| After P1 rules | P1 checklists loaded | 70% | Evaluate remaining |
| During review | Token usage check | 80% | Enable summary mode |
| Critical | Budget exhausted | 95% | Drop to P0 only |

---

## Token Budget Management

### Budget Constants

```yaml
# Context window configuration
CONTEXT_WINDOW: 200000  # Claude Sonnet 4.6
SAFETY_MARGIN: 0.2      # 20% safety margin
USABLE_BUDGET: 160000   # CONTEXT_WINDOW * (1 - SAFETY_MARGIN)

# Thresholds
WARNING_THRESHOLD: 128000   # 80% of USABLE_BUDGET
CRITICAL_THRESHOLD: 152000  # 95% of USABLE_BUDGET
```

### Degradation Strategy

```python
def apply_degradation_strategy(token_usage: int) -> str:
    """Apply appropriate degradation based on token usage"""

    if token_usage < WARNING_THRESHOLD:
      return "normal"  # Full detailed output

    elif token_usage < CRITICAL_THRESHOLD:
      return "summary"  # Condensed output, no code examples

    else:
      return "critical_only"  # Drop all except SEC rules
```

### Degradation Levels

| Level | Trigger | Output Format | Which Rules |
|-------|---------|---------------|-------------|
| Normal | <80% budget | Full with code examples | All matched rules |
| Summary | 80-95% | Condensed, bullet points only | All matched rules |
| Critical | >95% | Minimal, SEC only | SEC rules only |
| Emergency | >98% | Error message | Abort review |

### Example

```yaml
# Scenario: Large codebase review
Input: 5000 lines of code, severity="all"

Step 1: Estimate
  estimate = 600 + (5000 * 1.8) + 16400 = 26000 tokens

Step 2: Check budget
  26000 < 128000 (WARNING_THRESHOLD) → Normal mode

Step 3: During review
  ... loading more code ...
  Current usage: 130000 tokens → Exceeded WARNING_THRESHOLD

Step 4: Degrade
  Switch to summary mode
  Omit code examples from findings
  Condense descriptions
```

---

## Confidence Calculation

### Formula

```python
def calculate_confidence(
    finding: Finding,
    rule: Rule
) -> float:
    """Calculate confidence score for a finding"""

    # Semantic match score (how well the code matches the rule pattern)
    semantic_score = finding.semantic_match  # 0.0-1.0

    # Coverage score (how many checklist items are satisfied)
    coverage_score = finding.coverage_score  # 0.0-1.0

    # Weighted combination
    confidence = (semantic_score * 0.6) + (coverage_score * 0.4)

    return confidence
```

### Component Scores

#### Semantic Score (60% weight)

Measures how well the code matches the rule's pattern:

```yaml
High semantic match (0.8-1.0):
  - Code exactly matches bad example pattern
  - Multiple indicators present (e.g., hardcoded key + "sk_" prefix)
  - Context confirms violation (e.g., API key in network call)

Medium semantic match (0.5-0.8):
  - Code partially matches pattern
  - Some indicators present
  - Context ambiguous but likely violation

Low semantic match (0.2-0.5):
  - Code loosely matches pattern
  - Few indicators
  - Context unclear

Very low semantic match (0.0-0.2):
  - Code barely matches pattern
  - Skip reporting
```

#### Coverage Score (40% weight)

Measures how many checklist criteria are satisfied:

```yaml
# Example: SEC-001 Hardcoded Credentials
checklist_items:
  - Hardcoded string literal with sensitive keywords
  - Length matches typical key format (>16 chars)
  - Found in source code (not config)
  - No obfuscation or encryption

# If 3/4 items present → coverage_score = 0.75
```

### Thresholds

```yaml
# Confidence thresholds
REPORTING_THRESHOLD: 0.8    # Only report if confidence >= 0.8
HIGH_CONFIDENCE: 0.9        # Mark as "high confidence" if >= 0.9
MEDIUM_CONFIDENCE: 0.8      # Mark as "medium" if 0.8-0.9
LOW_CONFIDENCE: 0.7         # Skip if < 0.8

# Per-rule override
rule["confidence_threshold"]  # Use rule-specific threshold if defined
```

### Example

```python
# Finding: Hardcoded API key
finding = {
    "code": 'const val API_KEY = "sk_live_abc1234567890"',
    "semantic_match": 0.95,  # Exact match with "sk_" prefix
    "coverage_score": 0.75   # 3/4 checklist items
}

confidence = (0.95 * 0.6) + (0.75 * 0.4)
           = 0.57 + 0.30
           = 0.87

# Result: Report as medium confidence (0.87 >= 0.8 threshold)
```

---

## Confidence-Based Filtering

### Filtering Algorithm

```python
def filter_findings(
    findings: List[Finding],
    rules: List[Rule]
) -> List[Finding]:
    """Filter findings based on confidence"""

    filtered = []

    for finding in findings:
      rule = rule_index["by_id"][finding.rule_id]

      # Calculate confidence
      confidence = calculate_confidence(finding, rule)

      # Get threshold
      threshold = rule.get("confidence_threshold", 0.8)

      # Apply filter
      if confidence >= threshold:
        finding.confidence = confidence
        filtered.append(finding)

    return filtered
```

### Noise Reduction Rules

```yaml
skip_patterns:
  - Stylistic preferences
  - Unchanged code issues (unless CRITICAL)
  - Hypothetical problems

consolidate:
  - Multiple similar issues → 1 finding
```

---

## Result Aggregation

### Aggregation Algorithm

```python
def aggregate_results(findings: List[Finding]) -> AggregatedResults:
    """Aggregate findings by severity and category"""

    aggregated = {
        "by_severity": {"CRITICAL": [], "HIGH": [], "MEDIUM": [], "LOW": []},
        "by_category": {
            "Security": [], "Code Quality": [], "Architecture": [],
            "Jetpack/Kotlin": [], "Performance": [], "Best Practices": []
        },
        "summary": {"total": 0, "by_severity": {}, "by_category": {}},
        "verdict": None
    }

    for finding in findings:
      aggregated["by_severity"][finding.severity].append(finding)
      aggregated["by_category"][finding.category].append(finding)

    aggregated["summary"]["total"] = len(findings)
    
    if aggregated["summary"]["by_severity"]["CRITICAL"] > 0:
      aggregated["verdict"] = "BLOCK"
    elif aggregated["summary"]["by_severity"]["HIGH"] > 5:
      aggregated["verdict"] = "WARN"
    else:
      aggregated["verdict"] = "PASS"

    return aggregated
```

---

## Output Formatting - Markdown & JSON

Supports both markdown and JSON output formats with complete schema definitions.

---

## Complete Execution Flow

10-step orchestration process from parameter parsing to output formatting.

---

## Legacy Mode Support

Backward compatibility with V1.0 agent via --mode legacy flag.

