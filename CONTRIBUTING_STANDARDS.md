# Contributing Standards

This document outlines the coding and documentation standards for contributing to this project.

## Language Convention

**English for Artifacts, Native Language for Communication**

| Context | Language | Example |
|----------|----------|---------|
| Commit messages | English | `feat(auth): add biometric authentication` |
| Documentation | English | `README.md`, `docs/guide.md` |
| Code comments | English | `// Load user data from API` |
| File names | English | `UserRepository.kt` |
| Variable names | English | `userProfile`, `authService` |
| With AI assistant | Your preference | Use your native language for efficiency |

## Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `style`, `build`, `ci`

### Examples

✅ **Correct**:
```
feat(auth): add biometric authentication

Implement fingerprint/face recognition for login flow.
Add fallback to PIN entry when biometric unavailable.

Closes #123
```

```
docs: update README with PR review commands

Add comprehensive PR review examples and CI/CD integration guide.
```

❌ **Incorrect**:
```
feat: 添加生物识别    # Subject must be English
fix(auth): 修复登录bug  # Don't mix languages
Added new feature     # Don't use past tense
```

## Documentation Standards

### File Structure

All project documentation MUST be in English:

✅ **Allowed**:
- `README.md` (English only)
- `CONTRIBUTING.md` (English only)
- `DEVELOPMENT.md` (English only)
- `docs/guides/feature-name.md` (English only)
- Code comments (English only)

❌ **Not Allowed**:
- `README_ZH.md` in project root (use `docs/translations/` instead)
- `开发指南.md` (Use `development-guide.md` instead)
- Mixed languages in the same file

### Documentation Style

- Use clear, concise language
- Provide examples for complex concepts
- Include code snippets with syntax highlighting
- Add diagrams for architecture explanations (when helpful)
- Keep documentation up to date with code changes

## Code Standards

### General

- **Follow language style guides**:
  - Kotlin: [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html)
  - Java: [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)

- **Keep functions small**: < 50 lines
- **Keep files focused**: < 800 lines
- **Use descriptive names**: `loadUserProfile()` not `load()`
- **Avoid deep nesting**: Maximum 4 levels
- **Handle errors explicitly**: Never silently swallow errors

### Code Comments

All comments MUST be in English:

✅ **Correct**:
```kotlin
/**
 * ViewModel for user profile screen.
 * Handles user data loading and state management.
 */
class ProfileViewModel : ViewModel() {
    // Load user data from repository
    private fun loadUser(userId: String) {
        // TODO: Add error handling for network failures
    }
}
```

❌ **Incorrect**:
```kotlin
// 用户资料视图模型  # Don't use Chinese
// 加载用户数据
```

### File Naming

Use descriptive English names:

✅ **Correct**:
- `UserProfileViewModel.kt`
- `authentication-service/`
- `CODE_REVIEW_GUIDE.md`

❌ **Incorrect**:
- `用户资料界面.kt`
- `认证服务/`
- `代码审查指南.md`

## Pattern Files

When adding detection patterns:

1. **Use clear rule IDs**: Follow existing pattern (SEC-011, QUAL-011)
2. **Provide examples**: Show both bad and good code
3. **Explain the fix**: Clear remediation steps
4. **Set appropriate severity**: CRITICAL, HIGH, MEDIUM, LOW

```markdown
## RULE-ID: Rule Name

### Detection Patterns
- Pattern 1: Description
- Pattern 2: Description

### Fix Suggestions
1. Recommendation 1
2. Recommendation 2

### Severity: HIGH
```

## Test Cases

When creating test cases:

1. **Prefix with number**: Sequential (001, 002, 003...)
2. **Descriptive name**: What the case tests
3. **Add comments**: Expected detection and severity
4. **Test one thing**: Each file tests one specific issue

```kotlin
// test-cases/008-aws-keys.kt
// Expected Detection: CRITICAL
// Rule: SEC-011

object AwsConfig {
    const val AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE"
}
```

## Translation Support

For non-English documentation:
- Place translations in `docs/translations/`
- Use language code subdirectories (e.g., `zh-CN/`, `ja/`)
- Keep English versions as source of truth
- Document translation status in `docs/translations/README.md`

## Enforcement

### Git Hooks

Optional commit-msg hook to enforce English commit messages:

```bash
#!/bin/bash
# .git/hooks/commit-msg

commit_msg=$(cat $1)

# Check if commit message contains non-ASCII characters in subject
if echo "$commit_msg" | head -1 | grep -P '[^\x00-\x7F]'; then
    echo "❌ Commit subject must be in English only!"
    echo "Please rewrite your commit message."
    exit 1
fi

# Check conventional commit format
if ! echo "$commit_msg" | head -1 | grep -qE '^(feat|fix|refactor|docs|test|chore|perf|style|build|ci)(\(.+\))?:'; then
    echo "❌ Commit message must follow conventional format!"
    echo "Format: <type>(<scope>): <subject>"
    exit 1
fi
```

Install:
```bash
cp .github/hooks/commit-msg .git/hooks/
chmod +x .git/hooks/commit-msg
```

## Related Resources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html)
- [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)
- [Contributing Guide](CONTRIBUTING.md)

---

For detailed contribution workflow, see [CONTRIBUTING.md](CONTRIBUTING.md).
