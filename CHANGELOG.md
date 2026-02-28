# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Automated test report generation
- Statistical data visualization
- Performance metrics analysis

## [3.0.0] - 2026-02-28

### Added
- **Plugin discovery fix** — Added `name` field to command frontmatter for proper plugin loading
- **Enhanced command documentation** — Restructured command file with clear execution flow
- **Plugin manifest** — Added `.claude/plugin-manifest.json` for project-level plugin loading

### Changed
- **BREAKING**: Plugin directory structure change for v3.0.0 compatibility
- **Command interface** — Added explicit `name: android-code-review` in frontmatter
- **Documentation clarity** — Separated execution flow from feature descriptions

### Fixed
- **Command not found** — Fixed plugin discovery by adding required `name` field
- **Plugin loading** — Ensured `.claude/plugin-manifest.json` exists for proper plugin registration

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
- **Documentation consistency** — Aligned all files with measured token reduction data
- **Version synchronization** — Ensured plugin-manifest.json and marketplace.json match

### Technical Details
- Command token reduction: 60% (simplified interface)
- Pattern token reduction: 38-39% average (measured across severity levels)
- Architecture: 2-layer (Command → Skill), removed separate Agent layer
- Auto-detection priority: staged changes → unstaged changes → last commit

## [2.1.0] - 2026-02-28

### Added
- Progressive pattern loading by severity (token optimization)
- Pattern-based detection system (replaces verbose code examples)
- Caching mechanism for multi-file reviews

### Changed
- **Token Optimization**: 38-39% reduction average
  - Critical severity: 28% reduction
  - High severity: 39% reduction
  - All severity: 41% reduction
- Simplified architecture (2 layers instead of 3)
- Merged agent logic into skill

### Deprecated
- Old YAML-based rule system (v1.0/v2.0) - archived

### Fixed
- Plugin isolation verification issues
- Documentation inconsistencies

## [2.0.0] - 2026-02-27

### Added
- Skill-based orchestration system
- Three-tier testing system
- Test Android project integration
- Automated build verification scripts
- Plugin isolation verification

### Changed
- Restructured documentation
- Improved test coverage (9 test cases)
- Enhanced detection accuracy (100% on test suite)

### Removed
- Legacy agent-based architecture

## [1.0.0] - 2026-02-26

### Added
- Initial release
- Android code review command
- Security, quality, and performance detection patterns
- Basic test suite
- Documentation

[Unreleased]: https://github.com/daishengda2018/claude-code-for-android/compare/v3.0.0...HEAD
[3.0.0]: https://github.com/daishengda2018/claude-code-for-android/compare/v2.1.1...v3.0.0
[2.1.1]: https://github.com/daishengda2018/claude-code-for-android/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/daishengda2018/claude-code-for-android/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/daishengda2018/claude-code-for-android/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/daishengda2018/claude-code-for-android/releases/tag/v1.0.0
