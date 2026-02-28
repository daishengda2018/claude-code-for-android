# Automation Scripts

Essential scripts for plugin development and testing.

> **Note**: To run AI code review, use the command in Claude Code:
> ```
> /android-code-review --target file:<path>
> ```

## Scripts

### verify-isolation.sh
Verify plugin isolation configuration.

**Usage:**
```bash
./scripts/verify-isolation.sh
```

### verify-build.sh
Verify test Android project builds successfully.

**Usage:**
```bash
./scripts/verify-build.sh
```

### publish-plugin.sh
Automate version release process.

**Usage:**
```bash
./scripts/publish-plugin.sh
```

## Development Workflow

```bash
# 1. Verify isolation
./scripts/verify-isolation.sh

# 2. Make changes to patterns/
# Edit skills/android-code-review/patterns/*.md

# 3. Test review
/android-code-review --target file:test-cases/001-*.kt

# 4. Verify build
./scripts/verify-build.sh

# 5. Publish when ready
./scripts/publish-plugin.sh
```

---

**Simplified 2026-02-28**: Removed complex git hooks and unused tools.
