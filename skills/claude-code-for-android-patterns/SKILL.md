---
name: claude-code-for-android-patterns
description: Development patterns extracted from claude-code-for-android plugin repository
version: 1.0.0
source: local-git-analysis
analyzed_commits: 31
---

# Claude Code Plugin Development Patterns

Patterns extracted from the `claude-code-for-android` repository - a Claude Code plugin for automated Android code review.

## Commit Conventions

This project uses **conventional commits** with specific formatting:

### Commit Types
- `feat:` - New features (e.g., agent rewrite, new test infrastructure)
- `docs:` - Documentation updates (README, guides, design docs)
- `chore:` - Maintenance tasks (version bumps, config changes)
- `refactor:` - Code restructuring (token optimization, cleanup)
- `fix:` - Bug fixes (marketplace schema, plugin config)

### Commit Message Format
```
type: description (version)

Examples:
- feat: restructure to standard marketplace plugin format (v2.0.0-alpha)
- optimization: reduce token consumption by 28% (v2.0.0-beta)
- docs: add language convention for English artifacts and Chinese communication
```

### Version Tagging
- Format: `vX.Y.Z[-alpha|beta]` (e.g., v2.0.0-alpha, v2.0.0-beta)
- Tag with: `git tag -a v2.0.0-beta -m "Release notes"`
- Use Semantic Versioning

## Project Architecture

### Directory Structure

```
claude-code-for-android/
├── agents/                              # Plugin Agent definitions
│   └── android-code-reviewer.md        # Review agent logic
├── commands/                            # Plugin Command definitions
│   └── android-code-review.md          # User-facing command
├── skills/                              # Plugin Skills (orchestration)
│   └── android-code-review/
│       ├── SKILL.md                    # Orchestration layer
│       └── references/                 # Rule checklists
│           ├── sec-*.md                # Security rules
│           ├── qual-*.md               # Quality rules
│           ├── arch-*.md               # Architecture rules
│           ├── jetp-*.md               # Jetpack/Kotlin rules
│           ├── perf-*.md               # Performance rules
│           └── prac-*.md               # Best practices
├── .claude/                             # Project-level config (not published)
│   ├── plugin-manifest.json           # Plugin metadata
│   └── settings.local.json            # Local permissions
├── .claude-plugin/                      # Marketplace metadata
│   └── marketplace.json                # Marketplace listing
├── test-cases/                          # Standalone test files (Tier 1)
│   └── *.kt                            # Individual bug examples
├── test-android/                        # Real Android project (Tier 2)
│   └── app/src/main/java/...
├── docs/                                # Documentation
│   ├── PLUGIN_STRUCTURE.md             # Plugin architecture guide
│   ├── DEVELOPMENT.md                  # English dev guide
│   └── DEVELOPMENT_ZH.md                # Chinese dev guide
└── scripts/                             # Automation scripts
    ├── verify-isolation.sh
    ├── verify-build.sh
    └── publish-plugin.sh
```

### Key Design Principles

1. **Marketplace-First Structure**
   - `agents/`, `commands/`, `skills/` in project root (published)
   - `.claude/` for project-level config only (not published)
   - Follows official plugin conventions

2. **Token Optimization Mindset**
   - Progressive rule loading based on severity
   - Confidence-based filtering (>80% threshold)
   - Minimal verbose documentation in SKILL.md
   - Prefer bullet points over code examples

3. **Bilingual Documentation**
   - All documentation in both English and Chinese
   - File naming: `README.md` + `README_ZH.md`
   - Commit messages in English, code comments in English

4. **Three-Tier Testing System**
   - **Tier 1:** Standalone test files (test-cases/*.kt)
   - **Tier 2:** Real Android project (test-android/)
   - **Tier 3:** Batch regression testing

## Development Workflows

### Adding New Detection Rule

1. Create test case in `test-cases/`:
   ```kotlin
   // test-cases/004-new-rule.kt
   // Expected Detection: HIGH
   class BadExample { /* bug */ }
   ```

2. Update reference file (e.g., `references/sec-*.md`):
   - Add rule description
   - Include ❌ bad example and ✅ good example
   - Set severity level (P0/P1/P2/P3)

3. Update `agents/android-code-reviewer.md`:
   - Add quick reference to new rule
   - Specify severity and token estimate

4. Test locally:
   ```bash
   /android-code-review --target file:test-cases/004-new-rule.kt
   ./scripts/verify-build.sh  # Verify no false positives
   ```

### Token Optimization Workflow

1. **Analyze current token usage**
   - Count lines in SKILL.md: `wc -l skills/android-code-review/SKILL.md`
   - Check for verbose Python pseudo-code
   - Identify redundant tables

2. **Simplify documentation**
   - Remove code blocks, replace with bullet points
   - Consolidate duplicate tables
   - Add references instead of duplicating content

3. **Measure improvement**
   - Before: 589 lines SKILL.md → After: 146 lines (75% reduction)
   - Target: 20-30% token savings per review

### Publishing New Version

1. Update version numbers:
   - `.claude/plugin-manifest.json`
   - `.claude-plugin/marketplace.json`

2. Create commit:
   ```bash
   git add -A
   git commit -m "feat: description (vX.Y.Z)"
   ```

3. Tag release:
   ```bash
   git tag -a vX.Y.Z -m "Release notes"
   git push origin main
   git push origin vX.Y.Z
   ```

4. Create GitHub release:
   ```bash
   gh release create vX.Y.Z --notes "Release notes"
   ```

## Testing Patterns

### Test-Driven Development

**Always write test case first:**
1. Create `test-cases/XXX-description.kt`
2. Run `/android-code-review --target file:test-cases/XXX-description.kt`
3. Verify detection works
4. Commit test case with rule description

### Build Verification

After AI review, always verify compilation:
```bash
cd test-android/
./gradlew assembleDebug --console=plain
```

**Exit codes:**
- `0` = Build success (possible false positive)
- `1` = Build failed (correct detection)

### Isolation Verification

Before testing, ensure plugin isolation:
```bash
./scripts/verify-isolation.sh
```

**Critical:** `test-android/.claude/` must NOT exist (overrides development version)

## Code Quality Standards

### File Naming Conventions
- Test cases: `XXX-description.kt` (3-digit ID + kebab-case)
- Documentation: English + `_ZH.md` suffix for Chinese
- Markdown: All in project root or `docs/`

### Documentation Requirements
- **English artifacts:** README.md, DEVELOPMENT.md, CLAUDE.md
- **Chinese artifacts:** README_ZH.md, DEVELOPMENT_ZH.md
- **Code comments:** English only (checked by pre-commit hook)

### Plugin Configuration
- `plugin-manifest.json`: Minimal metadata (no `capabilities` field)
- `marketplace.json`: `keywords` array only (no duplicate `tags`)
- `settings.local.json`: Essential permissions only

## Token Budget Management

### Progressive Rule Loading

| Severity | Categories | Files | Tokens |
|----------|------------|-------|--------|
| critical | SEC-* (P0) | security only | ~2,500 |
| high | P0-P1 | + quality + architecture + jetpack | ~12,000 |
| medium | P0-P2 | + performance | ~14,200 |
| all | P0-P3 | + practices | ~16,400 |

### Confidence Filtering

**Report only if confidence ≥ 80%**
- Semantic score (60%): Pattern match quality
- Coverage score (40%): Checklist items satisfied
- Formula: `(semantic × 0.6) + (coverage × 0.4)`

## Continuous Improvement Patterns

### Optimization Iterations
- v1.0.1 → v2.0.0-alpha: Restructure to standard format
- v2.0.0-alpha → v2.0.0-beta: Token optimization (-28%)
- Focus: Progressive token reduction while maintaining functionality

### Documentation Evolution
- Start with basic README
- Add PLUGIN_STRUCTURE.md for reference
- Create bilingual guides (EN + CN)
- Maintain DEVELOPMENT.md with workflows

## Anti-Patterns to Avoid

### ❌ Don't
- Put skills/ or agents/ in `.claude/` directory
- Use Chinese in commit messages or code comments
- Skip build verification (may have false positives)
- Leave test-android/.claude/ directory existing
- Hardcode absolute paths in agent
- Use verbose Python pseudo-code in SKILL.md

### ✅ Do
- Keep agents/, commands/, skills/ in project root
- Use English for all commit messages
- Run verify-build.sh after AI review
- Verify isolation before testing
- Use relative paths from project root
- Prefer bullet points over code examples

## Related Skills

- [everything-claude-code:tdd-workflow](https://github.com/affaan-m/everything-claude-code) - Test-driven development
- [everything-claude-code:backend-patterns](https://github.com/affaan-m/everything-claude-code) - Backend architecture
- [everything-claude-code:python-testing](https://github.com/affaan-m/everything-claude-code) - Python testing

## Version History

- v1.0.0 (2026-02-27): Initial skill creation from 31 commits
