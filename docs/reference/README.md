# Android Code Review - Reference Documentation

This directory contains detailed reference documentation for all Android code review rules.

## Purpose

These files provide **detailed explanations** with full code examples for each detection rule. They serve as:
- Educational material for understanding security issues
- Reference for developers learning Android best practices
- Documentation for the detection patterns used in v2.1

## v2.1 Architecture Note

**In v2.1**, the plugin uses **pattern-based detection** for token efficiency:
- **Pattern files** (`skills/android-code-review/patterns/*.md`) are used during code review
- **Reference files** (this directory) are for documentation only

## File Structure

| File | Rules | Category | Token Size |
|------|-------|----------|------------|
| [sec-001-to-010-security.md](sec-001-to-010-security.md) | SEC-001 to SEC-010 | Security (CRITICAL) | ~2,500 |
| [qual-001-to-010-quality.md](qual-001-to-010-quality.md) | QUAL-001 to QUAL-010 | Code Quality (HIGH) | ~3,200 |
| [arch-001-to-009-architecture.md](arch-001-to-009-architecture.md) | ARCH-001 to ARCH-009 | Architecture (HIGH) | ~2,800 |
| [jetp-001-to-008-jetpack.md](jetp-001-to-008-jetpack.md) | JETP-001 to JETP-008 | Jetpack/Kotlin (HIGH) | ~3,500 |
| [perf-001-to-008-performance.md](perf-001-to-008-performance.md) | PERF-001 to PERF-008 | Performance (MEDIUM) | ~2,400 |
| [prac-001-to-008-practices.md](prac-001-to-008-practices.md) | PRAC-001 to PRAC-008 | Best Practices (LOW) | ~1,700 |

## Rule Categories

### Security (P0 - CRITICAL)
- Hardcoded credentials
- Insecure data storage
- Intent hijacking
- WebView vulnerabilities
- Cleartext traffic
- Permission abuse
- Data leakage
- Outdated dependencies
- SSL/TLS issues
- Encryption flaws

### Code Quality (P1 - HIGH)
- Memory leaks
- Large functions (>50 lines)
- Deep nesting (>4 levels)
- Missing error handling
- Debug code remnants
- Insufficient test coverage
- Dead code
- Unsafe null access
- Code readability

### Architecture (P1 - HIGH)
- Lifecycle violations
- ViewModel misuse
- Fragment anti-patterns
- Resource hardcoding
- Main thread blocking
- Deprecated APIs
- Permission handling
- Configuration changes
- View binding violations

### Jetpack/Kotlin (P1 - HIGH)
- Coroutine misconfiguration
- State management issues
- Room N+1 queries
- Hilt dependency injection errors
- Compose anti-patterns
- Navigation issues
- DataStore problems
- WorkManager issues

### Performance (P2 - MEDIUM)
- ANR risks
- Layout inefficiencies
- Bitmap mismanagement
- Startup bottlenecks
- Memory leaks
- List performance
- SharedPreferences issues
- Network optimization

### Best Practices (P3 - LOW)
- TODO tracking
- Documentation
- Naming conventions
- Magic numbers
- Formatting
- Exception handling
- Accessibility
- Hardcoded config

## Usage

### For Developers Learning Android Best Practices

These reference files provide:
- ❌ **Wrong examples** - Common mistakes to avoid
- ✅ **Correct examples** - Proper implementation patterns
- 📋 **Checklists** - What to look for during code review
- 🔧 **Fix suggestions** - How to remediate issues

### For Plugin Maintainers

When adding new rules:
1. Create detection pattern in `skills/android-code-review/patterns/*.md`
2. Add detailed reference in this directory with full examples
3. Update `SKILL.md` with pattern reference
4. Add test case to `test-cases/`

## Migration from v2.0 to v2.1

**v2.0**: Loaded these reference files directly during review (~16,100 tokens)
**v2.1**: Uses optimized pattern files (~8,600 tokens, **-47%**)

These reference files are kept for:
- Documentation purposes
- Educational material
- Future pattern development

## Contributing

When adding new detection rules:

1. **Pattern File**: Add concise detection patterns to `patterns/*.md`
2. **Reference File**: Add detailed examples with ❌/✅ code here
3. **Test Case**: Create test case in `test-cases/`
4. **Documentation**: Update relevant user guides

## Related Documentation

- [SKILL.md](../../skills/android-code-review/SKILL.md) - Main orchestration layer
- [Pattern Files](../../skills/android-code-review/patterns/) - Optimized detection patterns
- [CLAUDE.md](../../CLAUDE.md) - Plugin development guide
- [User Guide](../../docs/USER_GUIDE.md) - End-user documentation

---

**Last Updated**: 2026-02-28
**Plugin Version**: v2.1.0-beta
