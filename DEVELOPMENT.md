# Development Guide (v3.0.0)

Android Code Review Plugin 开发指南。

## Quick Start

### Test-Driven Development

```bash
# 1. Write test case
# test-cases/004-new-rule.kt

# 2. Run review
/android-code-review --target file:test-cases/004-new-rule.kt

# 3. Fix detection rules
# Edit: skills/android-code-review/SKILL.md

# 4. Restart Claude Code (required!)
# 5. Re-test
```

## Plugin Architecture (v3.0.0)

```
├── .claude-plugin/
│   └── plugin.json              # Plugin metadata
├── commands/
│   └── android-code-review.md   # User-facing command
├── agents/
│   └── android-code-reviewer.md # Review logic
└── skills/
    └── android-code-review/
        └── SKILL.md             # Detection patterns
```

## Testing

- **Tier 1**: `test-cases/*.kt` - Standalone files
- **Tier 2**: `test-android/` - Real project
- **Verification**: `./scripts/verify-build.sh`

## Release

```bash
./scripts/publish-plugin.sh
```

See [Development Workflow](docs/guides/development/development-cycle.md) for details.
