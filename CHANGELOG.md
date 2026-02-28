# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Automated test report generation
- Statistical data visualization
- Performance metrics analysis

## [3.0.1] - 2026-02-28

### Fixed
- **Plugin manifest validation** — Corrected `plugin.json` format for marketplace compatibility
  - Changed `author` from string to object with `name` and `url` fields
  - Changed `agents` from directory path to file array listing specific agent files
  - Added comprehensive keywords for better plugin discovery
- Resolved plugin loading errors: "author: Invalid input: expected object, received string" and "agents: Invalid input"

### Changed
- Project documentation cleanup:
  - Archived V2.x architecture docs to `docs/archive/v2.x-architecture/`
  - Removed duplicate documentation files
  - Updated `docs/README.md` for V3.0.0 structure
  - Rewrote `DEVELOPMENT.md` as concise guide
  - Deleted outdated `package.json`
- Documentation reduced by 27% (169 lines) while maintaining completeness

### Migration Notes
Users should restart Claude Code after upgrading to ensure plugin cache is refreshed with the corrected manifest.

## [3.0.0] - 2026-02-28

### Added
- **Plugin discovery fix** — Added `name` field to command frontmatter for proper plugin loading
- **Enhanced command documentation** — Restructured command file with clear execution flow
- **Plugin manifest** — Added `.claude-plugin/plugin.json` for marketplace compatibility
- `docs/archive/` for historical documentation

### Changed
- **BREAKING**: `agent/` → `agents/` (plural) to match standard structure
- **BREAKING**: `.claude/plugin-manifest.json` → `.claude-plugin/plugin.json`
- **Command interface** — Added explicit `name: android-code-review` in frontmatter
- **Documentation clarity** — Separated execution flow from feature descriptions

### Fixed
- **Command not found** — Fixed plugin discovery by adding required `name` field
- **Plugin loading** — Ensured proper plugin registration with correct directory structure

### Migration Notes
This release fixes the critical "command not found" issue. Users must restart Claude Code after upgrading.

## [2.1.1] - 2026-02-28

### Added
- **Smart auto-detection** — Zero-configuration review (staged → unstaged → last commit)
- **Token optimization metrics** — Measured data: 38-39% average reduction
  - Critical severity: 28% reduction
  - High severity: 39% reduction
  - All severity: 41% reduction
- **Marketplace keywords** — Added `automation` and `token-optimization` for better discoverability

### Changed
- **Command interface** — `--target` parameter now optional (defaults to `auto`)
- **Simplified command** — Reduced token usage by 59% (1,745 bytes vs 4,255 bytes)
- **Pattern-based detection** — Replaces verbose code examples (38-39% token savings)
- **Version management** — Upgraded from `2.1.0-beta` to stable `2.1.1`
- **Documentation** — Enhanced README.md and README_ZH.md with v2.1.1 features

### Fixed
- **Token data accuracy** — Corrected from estimated 40-50% to measured 38-39%
- **Plugin manifest** — Removed empty `agents: []` field (aligns with v2.1 architecture)
