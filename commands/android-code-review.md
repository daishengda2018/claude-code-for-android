---
name: android-code-review
description: Trigger a comprehensive Android code review (Kotlin/Java) for quality, security, performance, and compliance with Android best practices. Integrates with the android-code-reviewer agent to enforce Google's Android guidelines and project-specific standards.
type: command
skill:
  name: android-code-reviewer
  type: agent
  description: Orchestrates Android code review workflows using the dedicated android-code-reviewer agent
parameters:
  - name: target
    type: string
    required: true
    description: "Target scope for review: 'staged' (git diff --staged), 'all' (git diff), 'commit:<hash>' (specific commit), or 'file:<path>' (specific file)"
    enum: ["staged", "all", "commit:", "file:"]
  - name: severity
    type: string
    required: false
    default: "all"
    description: "Filter review findings by severity: 'critical', 'high', 'medium', 'low', or 'all'"
    enum: ["critical", "high", "medium", "low", "all"]
  - name: project-guidelines
    type: string
    required: false
    description: "Path to project-specific Android guidelines file (e.g., ANDROID.md, lint.xml)"
  - name: output-format
    type: string
    required: false
    default: "markdown"
    description: "Output format for review results: 'markdown' (default) or 'json'"
---
## Command Purpose

This command triggers the `android-code-reviewer` agent to perform a structured, compliance-focused review of Android code changes. It enforces Google's Android development guidelines, Jetpack best practices, and project-specific conventions while prioritizing critical issues (security vulnerabilities, crash risks) over low-impact style concerns.

## Trigger Syntax

```bash
# Basic usage (review staged changes)
> android-code-review --target staged

# Review specific file
> android-code-review --target file:app/src/main/java/com/example/MyFragment.kt

# Review specific commit
> android-code-review --target commit:a1b2c3d --severity critical

# Review all uncommitted changes with project guidelines
> android-code-review --target all --project-guidelines ./ANDROID.md --output-format json
```

## Execution Flow

1. **Parameter Validation**

   - Validate required `target` parameter (reject invalid commit hashes/file paths)
   - Sanitize inputs to prevent path traversal or command injection
   - Default to `severity=all` and `output-format=markdown` if not specified
2. **Context Collection**The command invokes the `android-code-reviewer` agent to:

   - Execute git commands to fetch target changes (e.g., `git diff --staged`, `git show <commit-hash>`)
   - Read project-specific guidelines (if provided: `ANDROID.md`, `lint.xml`, `gradle.properties`)
   - Load Android SDK/Jetpack version constraints from `build.gradle`
3. **Agent Execution**The `android-code-reviewer` agent runs through its structured review process:

   - Security checks (hardcoded secrets, insecure storage, permission abuse)
   - Code quality checks (memory leaks, error handling, dead code)
   - Android core pattern checks (lifecycle, ViewModel, Fragment usage)
   - Jetpack/Kotlin pattern checks (coroutines, Room, Hilt)
   - Performance checks (layout inefficiencies, ANR risks)
   - Best practices checks (naming, documentation, deprecated APIs)
4. **Result Formatting**

   - For `markdown` output: Structured findings by severity + summary table + approval verdict
   - For `json` output: Machine-readable format with `filePath`, `lineNumber`, `severity`, `issue`, `fix`, `codeSnippet` fields
5. **Error Handling**

   - If no changes found: Return "No code changes detected for review"
   - If invalid target: Return "Invalid target: `<value>` (valid options: staged/all/commit:`<hash>`/file:`<path>`)"
   - If project guidelines file not found: Return warning + proceed with core Android guidelines

## Output Examples

### Markdown Output

```
# Android Code Review Results
## Target: staged changes

[CRITICAL] Hardcoded API key in source
File: app/src/main/java/com/example/ApiClient.kt:15
Issue: API key "sk_abc123" exposed in source code. This will be committed to git history and visible in APK decompilation.
Fix: Move the API key to gradle.properties, generate BuildConfig, and reference BuildConfig.API_KEY. Add gradle.properties to .gitignore if needed.

  const val API_KEY = "sk_abc123";           // BAD
  const val API_KEY = BuildConfig.API_KEY;   // GOOD

[HIGH] Memory leak in Activity
File: app/src/main/java/com/example/LeakyActivity.kt:22
Issue: Activity Context referenced in static Handler → leaks when Activity is destroyed.
Fix: Use Application Context and clean up Handler in onDestroy().

## Review Summary

| Severity | Count | Status |
|----------|-------|--------|
| CRITICAL | 1     | fail   |
| HIGH     | 1     | warn   |
| MEDIUM   | 0     | info   |
| LOW      | 2     | note   |

Verdict: BLOCK — 1 CRITICAL issue must be fixed before merge.
```

### JSON Output

```json
{
  "reviewTarget": "staged",
  "projectGuidelines": "./ANDROID.md",
  "findings": [
    {
      "filePath": "app/src/main/java/com/example/ApiClient.kt",
      "lineNumber": 15,
      "severity": "CRITICAL",
      "issue": "Hardcoded API key in source",
      "description": "API key \"sk_abc123\" exposed in source code. This will be committed to git history and visible in APK decompilation.",
      "fix": "Move the API key to gradle.properties, generate BuildConfig, and reference BuildConfig.API_KEY. Add gradle.properties to .gitignore if needed.",
      "codeSnippet": {
        "bad": "const val API_KEY = \"sk_abc123\";",
        "good": "const val API_KEY = BuildConfig.API_KEY;"
      }
    },
    {
      "filePath": "app/src/main/java/com/example/LeakyActivity.kt",
      "lineNumber": 22,
      "severity": "HIGH",
      "issue": "Memory leak in Activity",
      "description": "Activity Context referenced in static Handler → leaks when Activity is destroyed.",
      "fix": "Use Application Context and clean up Handler in onDestroy().",
      "codeSnippet": {
        "bad": "private val handler = Handler(Looper.getMainLooper()) { Toast.makeText(this, \"Leaky\", Toast.LENGTH_SHORT).show() }",
        "good": "private val handler = Handler(Looper.getMainLooper()) { Toast.makeText(applicationContext, \"Safe\", Toast.LENGTH_SHORT).show() }\noverride fun onDestroy() { super.onDestroy(); handler.removeCallbacksAndMessages(null) }"
      }
    }
  ],
  "summary": {
    "CRITICAL": 1,
    "HIGH": 1,
    "MEDIUM": 0,
    "LOW": 2
  },
  "verdict": "BLOCK — 1 CRITICAL issue must be fixed before merge."
}
```

## Integration with Claude Skills

- **Skill Activation**: This command is registered as a Claude Skill and can be triggered via natural language ("Review my Android code changes") or explicit command syntax.
- **Agent Binding**: The command is tightly coupled with the `android-code-reviewer` agent (defined in `android-code-reviewer.md`), passing all parameters and context to the agent for execution.
- **Permissions**: The command requires read access to the code repository (git, file system) and no write permissions (review-only operation).
- **Rate Limiting**: Configured to prevent abuse (max 10 review requests per minute per user).

## Compliance & Standards

This command enforces compliance with:

- Google's [Android App Quality Guidelines](https://developer.android.com/quality-guidelines)
- [Android Security Best Practices](https://developer.android.com/topic/security/best-practices)
- [Kotlin Style Guide for Android](https://developer.android.com/kotlin/style-guide)
- Jetpack Compose [Performance &amp; Best Practices](https://developer.android.com/jetpack/compose/performance)
- Project-specific lint rules (from `lint.xml`) and Gradle configurations

## Extensibility

To extend the review capabilities:

1. Add new check categories to the `android-code-reviewer` agent (e.g., Compose UI testing, accessibility)
2. Update the `parameters` section to support new filters (e.g., `--module` to review specific Android modules)
3. Add new output formats (e.g., `jira` to create tickets for critical issues)
4. Integrate with CI/CD pipelines (export JSON output to fail builds on critical issues)

### How to Download & Use

1. **Create the first file**:

   - Copy all content under "1. File: `android-code-reviewer.md`"
   - Open a text editor (e.g., Notepad++, VS Code, Sublime Text)
   - Paste the content
   - Save the file as `android-code-reviewer.md` (ensure the file extension is `.md`, not `.txt`)
2. **Create the second file**:

   - Copy all content under "2. File: `android-code-review.md`"
   - Open a new text editor window
   - Paste the content
   - Save the file as `android-code-review.md` (same extension requirement)
3. **Usage**:

   - These files define an Android code review agent and a trigger command for it
   - Integrate them with your code review workflow (e.g., CI/CD pipelines, Claude Skills)
   - Run the `android-code-review` command to trigger structured Android code reviews following Google's best practices

Both files are fully compliant with Google's Android development guidelines and cover critical areas like security, code quality, performance, and Jetpack/Kotlin best practices.
