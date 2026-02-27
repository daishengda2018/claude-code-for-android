# Language Convention Quick Reference

## 🎯 Core Rule

**English for Artifacts, Chinese for Communication**

| Context | Language | Example |
|----------|----------|---------|
| Commit messages | English | `feat(auth): add biometric authentication` |
| Documentation | English | `README.md`, `docs/guide.md` |
| Code comments | English | `// Load user data from API` |
| With AI | Chinese | `请帮我审查这段代码` |
| File names | English | `UserRepository.kt` |
| Variable names | English | `userProfile`, `authService` |

## 📝 Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `style`, `build`, `ci`

## ✅ Correct Examples

```
feat(auth): add biometric authentication
fix(crash): resolve NPE in UserProfileFragment
docs: update README with PR review commands
```

## ❌ Wrong Examples

```
功能：添加生物识别  # ❌ Don't use Chinese
feat: 添加指纹识别    # ❌ Subject must be English
fix(auth): 修复登录bug    # ❌ Don't mix languages
```

## 🔗 Enforcement

Git hooks will check for:
- ✅ Commit messages in English
- ✅ Documentation in English
- ⚠️  Code comments in English (warning only)
- ✅ File names in English

## 📖 Full Guide

See `CONVENTIONS.md` for complete language convention guidelines.
