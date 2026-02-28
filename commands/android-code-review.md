---
name: android-code-review
description: Android PR & commit review — lifecycle, coroutine, architecture & security focused
type: command

skill: android-code-review

parameters:
  - name: target
    type: string
    required: false
    default: "auto"
    description: "auto|commit:<commit_id>|file:<path>|pr:<pr_number>"
    note: "auto: staged → unstaged → last commit"
    shorthand: "android-code-review pr:123 / file:xxx / commit:xxx"

  - name: severity
    type: string
    required: false
    default: "high"
    description: "critical|high|medium|all"
    note: "Controls pattern loading scope (token optimization)"

  - name: output-format
    type: string
    required: false
    default: "markdown"
    description: "markdown|json"
---
# Android Code Review Command

This command orchestrates Android code review by collecting files and invoking the skill.

## Execution Flow

### Step 1: Collect Files (Git Operations)

Based on `{{target}}` parameter:

**auto** (default):

```bash
# Check staged changes first
git diff --staged --quiet
if [ $? -eq 1 ]; then
    git diff --staged --name-only
else
    # Check unstaged changes
    git diff --quiet
    if [ $? -eq 1 ]; then
        git diff --name-only
    else
        # Review last commit
        git log -1 --patch --name-only
    fi
fi
```

**commit:`<id>`**:

```bash
git diff <id>~1..<id> --name-only
```

**pr:`<number>`**:

```bash
gh pr diff <number> --name-only
```

**file:`<path>`**:

```bash
# Direct file path, no git command needed
echo "<path>"
```

### Step 1.5: Filter Files by Type

**Goal**: Skip XML layout files and non-source files to reduce noise

```bash
# Filter out XML files and empty lines
filtered_files=$(echo "$collected_files" | grep -v '\.xml$' | grep -v '^\s*$')

# Optional: Log filtering results
original_count=$(echo "$collected_files" | grep -v '^\s*$' | wc -l | xargs)
filtered_count=$(echo "$filtered_files" | grep -v '^\s*$' | wc -l | xargs)
echo "🔍 Filtered files: ${original_count} → ${filtered_count}"
```

**Filter Rules**:
- ❌ **Skip**: `*.xml` (layouts, menus, colors, drawables, etc.)
- ❌ **Skip**: Empty lines and whitespace-only lines
- ✅ **Keep**: `*.kt`, `*.java`, `*.gradle`, `*.gradle.kts`

**Note**: XML layout files rarely contain logic errors and reviewing them generates significant noise.

### Step 2: Invoke Skill

Pass collected information to skill:

- Files to review (from Step 1)
- Severity threshold (from `{{severity}}` parameter)
- Output format (from `{{output-format}}` parameter)

### Step 3: Present Results

Format and display agent findings:

- Severity levels (CRITICAL, HIGH, MEDIUM, LOW)
- File locations and line numbers
- Issue descriptions and suggested fixes
- Review summary table

## Security Rule

**Never approve code with security vulnerabilities!**

Block commit if CRITICAL or HIGH issues found.
