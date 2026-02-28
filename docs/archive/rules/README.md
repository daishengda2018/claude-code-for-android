# Archived Rules Configuration

This directory contains the **v1.0/v2.0 YAML-based rule system** that was replaced in v2.1.

## Historical Context

These files were part of the early plugin architecture where rules were configured via YAML:

- **rule-metadata.yaml** - Metadata for 53 rules (ID, severity, category, confidence threshold)
- **rule-disable.yaml** - Runtime disable configuration
- **rule-priority.yaml** - Priority strategy for global vs project rules

## Why It Was Replaced

The YAML-based system had several limitations:

1. **Complexity**: Required YAML parsing and validation
2. **Maintenance**: Rule metadata needed to be synced with actual pattern files
3. **Token Overhead**: Loading YAML files added significant token cost
4. **Duplication**: Rule definitions existed in both YAML and pattern files

## v2.1 Replacement

In v2.1, rules are now defined directly as **detection patterns** in Markdown:

```
skills/android-code-review/patterns/
├── security-patterns.md
├── quality-patterns.md
├── architecture-patterns.md
├── jetpack-patterns.md
├── performance-patterns.md
└── practices-patterns.md
```

**Advantages:**
- ✅ Single source of truth
- ✅ No YAML parsing overhead
- ✅ More token-efficient (patterns vs full metadata)
- ✅ Easier to maintain and update

## Migration Path

If you want to restore YAML-based configuration:

1. Revert to v2.0.0-alpha tag
2. Implement YAML parsing in SKILL.md
3. Sync rule-metadata.yaml with pattern files

**Not recommended** for new projects.

## Status

- **Archived**: 2026-02-28
- **Superseded by**: v2.1 pattern-based detection
- **Last used**: v2.0.0-alpha
