# Language Convention

## Principle

**English for Artifacts, Chinese for Communication**

- **Artifacts**: Code, Documentation, Commits → **English**
- **Communication**: Discussions with AI, Team Chat → **Chinese**

---

## 📝 Documentation Language Convention

### English-Only Documentation (Strict)

All project documentation MUST be in English:

✅ **Allowed**:
- `README.md` (English only)
- `DEVELOPMENT.md` (English only)
- `ARCHITECTURE.md` (English only)
- `CLAUDE.md` (English only)
- `docs/` (English only)
- `CONTRIBUTING.md` (English only)
- Code comments (English only)

❌ **Not Allowed**:
- `README_ZH.md` (Use English README instead)
- `开发指南.md` (Use `development-guide.md` instead)
- Mixed language in same file

### Exception

User-facing documentation MAY have translations:
- If project supports international users, add `docs/zh-CN/` for translations
- Master English version is always source of truth
- Translations must be kept in sync with English version

**Example Structure**:
```
README.md                    (English, primary)
docs/
  zh-CN/
    README.md              (Chinese translation)
  ja/
    README.md              (Japanese translation)
```

---

## 🔧 Commit Message Convention

### Conventional Commits (English Only)

All commit messages MUST follow [Conventional Commits](https://www.conventionalcommits.org/) in **English**:

```
<type>: <subject>

<body>

<footer>
```

**Types** (English):
- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code restructuring
- `docs:` - Documentation changes
- `test:` - Test changes
- `chore:` - Maintenance tasks
- `perf:` - Performance improvements
- `style:` - Code style changes (formatting)
- `build:` - Build system changes
- `ci:` - CI/CD changes

**Examples**:

✅ **Correct**:
```
feat(auth): add biometric authentication

Implement fingerprint/face recognition for login flow.
Add fallback to PIN entry when biometric unavailable.

Closes #123
```

```
fix(crash): resolve NPE in UserProfileFragment

Fix null pointer exception when avatar URL is null.
Add default placeholder image instead of null.

Fixes #456
```

```
docs: update README with PR review commands

Add comprehensive PR review examples and CI/CD integration guide.
```

❌ **Wrong**:
```
功能：添加生物识别认证  # ❌ Don't use Chinese
feat: 添加生物识别    # ❌ Subject must be English
feat(auth): 添加指纹识别  # ❌ Don't mix languages
```

### Commit Message Hooks (Enforcement)

To enforce this convention, use commit-msg git hook:

```bash
#!/bin/bash
# .git/hooks/commit-msg

commit_msg=$(cat $1)

# Check if commit message contains Chinese characters
if echo "$commit_msg" | grep -P '[\x{4e00}-\x{9fff}]'; then
    echo "❌ Commit message must be in English only!"
    echo "Please rewrite your commit message."
    exit 1
fi

# Check conventional commit format
if ! echo "$commit_msg" | grep -qE '^(feat|fix|refactor|docs|test|chore|perf|style|build|ci)(\(.+\))?:'; then
    echo "❌ Commit message must follow conventional format!"
    echo "Format: <type>: <subject>"
    echo "Types: feat, fix, refactor, docs, test, chore, perf, style, build, ci"
    exit 1
fi
```

Install:
```bash
cp hooks/commit-msg .git/hooks/
chmod +x .git/hooks/commit-msg
```

---

## 💬 Communication Convention

### With AI Assistant (Chinese)

When interacting with Claude Code or other AI assistants:

✅ **Use Chinese**:
- Feature requirements
- Bug descriptions
- Code review requests
- Questions and explanations

**Examples**:
```
✅ 请帮我审查这个 PR 的代码质量
✅ 我需要添加一个新的功能来处理用户认证
✅ 这个内存泄漏问题怎么修复？
❌ Please review this PR  # Don't use English with AI
```

### Code Comments (English)

All code comments MUST be in English:

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

❌ **Wrong**:
```kotlin
// 用户资料视图模型  # ❌ Don't use Chinese
// 加载用户数据         # ❌ Don't use Chinese
```

### Exception for Developer Notes

For temporary developer notes, use English with `FIXME` or `TODO`:

```kotlin
// FIXME: Replace hardcoded timeout with configuration
// TODO: Implement caching for better performance
// NOTE: This is a temporary workaround, refactor in v2.0
```

---

## 📋 File Naming Convention

All files and directories MUST use English names:

✅ **Correct**:
- `user-profile-screen.kt`
- `authentication-service/`
- `CODE_REVIEW_GUIDE.md`

❌ **Wrong**:
- `用户资料界面.kt`          # ❌ Don't use Chinese
- `认证服务/`                # ❌ Don't use Chinese
- `代码审查指南.md`           # ❌ Don't use Chinese

---

## 🛠️ Tooling and Enforcement

### Pre-commit Hook (Language Check)

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash

# Check for Chinese characters in documentation files
echo "🔍 Checking documentation language..."

find . -name "*.md" -not -path "./.git/*" -not -path "./docs/zh-CN/*" | while read file; do
    if grep -P '[\x{4e00}-\x{9fff}]' "$file" > /dev/null; then
        echo "❌ Chinese characters found in: $file"
        echo "   Please translate to English or move to docs/zh-CN/"
        exit 1
    fi
done

# Check for Chinese characters in code files
echo "🔍 Checking code comments..."

find . -name "*.kt" -o -name "*.java" | while read file; do
    if grep -P '[\x{4e00}-\x{9fff}]' "$file" > /dev/null; then
        echo "⚠️  Chinese characters found in: $file"
        echo "   Code comments should be in English"
        # Only warn, don't block commit
    fi
done

echo "✅ Language check passed"
```

### Linting Configuration

Add to `.editorconfig`:

```ini
[*.{kt,java,md}]
charset = utf-8
insert_final_newline = true
trim_trailing_whitespace = true
```

---

## 📖 Quick Reference

| Context | Language | Example |
|----------|----------|---------|
| **Commit messages** | English | `feat(auth): add biometric authentication` |
| **Documentation** | English | `README.md`, `docs/guide.md` |
| **Code comments** | English | `// Load user data from API` |
| **With AI assistant** | Chinese | `请帮我审查这段代码` |
| **Team chat** | Chinese | (use team's preferred language) |
| **Variable names** | English | `userProfile`, `authService` |
| **File names** | English | `UserRepository.kt` |

---

## 🔄 Migration Plan

### Phase 1: Setup (Immediate)

1. ✅ Create this `CONVENTIONS.md`
2. ⬜ Add commit-msg hook
3. ⬜ Add pre-commit hook
4. ⬜ Update `.editorconfig`

### Phase 2: Clean Up (This Week)

1. ⬜ Remove or rename `README_ZH.md` → merge into `README.md`
2. ⬜ Translate any Chinese documentation to English
3. ⬜ Update code comments to English

### Phase 3: Enforcement (Ongoing)

1. ⬜ Enable git hooks in team workflow
2. ⬜ Add language check to CI/CD pipeline
3. ⬜ Review pull requests for language compliance

---

## 🎯 Why This Convention?

### English Artifacts

- **Global collaboration**: English is de facto standard for open source
- **Tool compatibility**: Most tools work best with English
- **Searchability**: English keywords are more universal
- **Consistency**: Single language reduces confusion

### Chinese Communication

- **Natural expression**: Native language for complex discussions
- **Efficiency**: Faster to communicate nuanced ideas
- **Cultural context**: Easier to explain domain-specific concepts
- **AI interaction**: Most AIs understand Chinese well

---

## 📚 Related Resources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Google Style Guide](https://google.github.io/styleguide/)
- [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html)

---

**Version**: 1.0.0
**Created**: 2025-02-27
**Owner**: daishengda2018
