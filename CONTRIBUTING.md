# Contributing to Claude Code for Android

Thank you for your interest in contributing to Claude Code for Android! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)

## Code of Conduct

This project adheres to a Code of Conduct that all contributors are expected to follow. Please see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for details.

## Getting Started

### Prerequisites

- Claude Code installed and configured
- Git for version control
- Basic understanding of Android development (Kotlin/Java)
- Familiarity with static analysis concepts

### Development Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/claude-code-for-android.git
   cd claude-code-for-android
   ```
3. Verify plugin isolation:
   ```bash
   ./scripts/verify-isolation.sh
   ```
4. Test the plugin:
   ```bash
   /android-code-review --target file:test-cases/001-security-hardcoded-secrets.kt
   ```

## Development Workflow

### 1. Choose an Issue

- Check [Issues](https://github.com/daishengda2018/claude-code-for-android/issues) for open tasks
- Comment on the issue to indicate you're working on it
- For new features, create an issue first for discussion

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-number
```

Branch naming conventions:
- `feature/` for new features
- `fix/` for bug fixes
- `docs/` for documentation changes
- `refactor/` for code refactoring

### 3. Make Changes

Follow the Test-Driven Development approach:

1. **Write Test Case First**
   - Create a test file in `test-cases/` with the issue you want to detect
   - Example: `008-new-detection-rule.kt`

2. **Implement Detection Logic**
   - Edit `skills/android-code-review/patterns/*.md` to add detection patterns
   - Or modify `skills/android-code-review/SKILL.md` for orchestration changes

3. **Verify Locally**
   ```bash
   # Test your new detection
   /android-code-review --target file:test-cases/008-new-detection-rule.kt

   # Verify compilation
   ./scripts/verify-build.sh
   ```

4. **Test Against All Cases**
   - Ensure your change doesn't break existing detections
   - Run review on all test cases manually

### 4. Commit Changes

Follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```bash
feat(security): add detection for hardcoded AWS keys

Add pattern to detect AWS access key and secret key formats
in source code. Covers both const and val declarations.

Closes #123
```

Commit types:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `refactor:` Code restructuring
- `test:` Test changes
- `chore:` Maintenance tasks

## Pull Request Process

### 1. Before Submitting

- [ ] Code follows project coding standards
- [ ] Test cases added/updated
- [ ] Documentation updated (if needed)
- [ ] All existing tests still pass
- [ ] Commit messages follow conventional format

### 2. Submit PR

1. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```
2. Open a Pull Request on GitHub
3. Fill out the PR template
4. Link related issues

### 3. PR Review Process

- Maintainer will review your PR
- Address any feedback requested
- Keep the discussion focused and constructive
- Be patient - all PRs are reviewed

### 4. Merge

Once approved:
- Squash and merge commits
- Delete your branch after merge

## Coding Standards

### Language

- **Code**: English only (Kotlin/Java)
- **Comments**: English only
- **Documentation**: English only
- **Commit messages**: English only (Conventional Commits format)

### Pattern Files

When adding detection patterns to `skills/android-code-review/patterns/`:

1. **Use clear rule IDs**: Follow existing pattern (e.g., SEC-011, QUAL-011)
2. **Provide examples**: Show both bad and good code
3. **Explain the fix**: Clear remediation steps
4. **Set appropriate severity**: CRITICAL, HIGH, MEDIUM, LOW

```markdown
## SEC-011: Hardcoded AWS Keys

### Detection Patterns
- Pattern 1: AWS_ACCESS_KEY_ID followed by 20-character base64
- Pattern 2: AWS_SECRET_ACCESS_KEY followed by 40-character base64

### Fix Suggestions
1. Use environment variables or build config
2. Reference: BuildConfig.AWS_ACCESS_KEY_ID
3. Never commit secrets to git

### Severity: CRITICAL
```

### Test Cases

When creating test cases in `test-cases/`:

1. **Prefix with number**: Sequential numbering (001, 002, 003...)
2. **Descriptive name**: What the case tests
3. **Add comments**: Expected detection and severity
4. **Test one thing**: Each file should test one specific issue

```kotlin
// test-cases/008-aws-keys.kt
// Expected Detection: CRITICAL
// Rule: SEC-011

object AwsConfig {
    const val AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE"  // Should be detected
    const val AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"  // Should be detected
}
```

## Testing

### Three-Tier Testing System

**Tier 1: Standalone Files** (Quick Verification)
```bash
/android-code-review --target file:test-cases/008-aws-keys.kt
```

**Tier 2: Real Android Project** (Deep Testing)
```bash
cd test-android/
/android-code-review --target file:app/src/main/java/com/test/bugs/
cd ../
./scripts/verify-build.sh
```

**Tier 3: Batch Regression** (All Test Cases)
```bash
# Manually review all test cases
for file in test-cases/*.kt; do
    /android-code-review --target file:$file
done
```

## Questions?

- Open an issue for bugs or feature requests
- Start a discussion for general questions
- Check existing documentation first

## License

By contributing, you agree that your contributions will be licensed under the [Apache-2.0 License](LICENSE).

---

Thank you for contributing! 🎉
