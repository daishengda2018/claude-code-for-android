# Claude Code Plugin Hooks

This directory contains automated validation hooks for the claude-code-for-android plugin development workflow.

## Available Hooks

### validate-version.sh

Validates version consistency across all plugin files before release.

**What it checks:**
- ✅ Version numbers match between `plugin-manifest.json` and `marketplace.json`
- ✅ Version format follows semantic versioning (semver)
- ✅ `CHANGELOG.md` contains entry for the current version
- ✅ No placeholder or inconsistent version strings in descriptions

**Usage:**

```bash
# Run manually
./.claude/hooks/validate-version.sh

# Or integrate into pre-commit or pre-release workflow
```

**Exit codes:**
- `0` - All checks passed (ready for release)
- `1` - Validation failed (fix errors before release)

**Example output:**
```
🔍 Validating plugin version consistency...

📦 Version numbers found:
  - plugin-manifest.json: 2.1.1
  - marketplace.json:     2.1.1

✅ plugin-manifest.json version format is valid
✅ marketplace.json version format is valid
✅ Version numbers are consistent across all files
✅ CHANGELOG.md contains entry for version 2.1.1

✅ All version checks passed!
Ready for release: v2.1.1
```

## Integration with Release Workflow

### Option 1: Manual Check

Run before every release:
```bash
./.claude/hooks/validate-version.sh && ./scripts/publish-plugin.sh
```

### Option 2: Git Pre-commit Hook (Optional)

Create `.git/hooks/pre-commit`:
```bash
#!/bin/bash
# Run version validation on commit
./.claude/hooks/validate-version.sh
```

### Option 3: GitHub Actions (Future)

Add to `.github/workflows/release.yml`:
```yaml
- name: Validate Version Consistency
  run: ./.claude/hooks/validate-version.sh
```

## Adding New Hooks

To add a new validation hook:

1. Create script in `.claude/hooks/`
2. Make executable: `chmod +x .claude/hooks/your-script.sh`
3. Add documentation to this README
4. Consider integrating with `scripts/publish-plugin.sh`

## Hook Best Practices

- ✅ **Cross-platform**: Use POSIX-compliant shell scripts
- ✅ **Clear output**: Use colors and emojis for readability
- ✅ **Exit codes**: Return 0 for success, non-zero for failure
- ✅ **Self-contained**: No external dependencies beyond standard tools
- ✅ **Well-documented**: Comment complex logic
