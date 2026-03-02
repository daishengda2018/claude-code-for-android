# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Automated test report generation
- Statistical data visualization
- Performance metrics analysis

## [3.0.5] - 2026-03-02

### Changed
- **Simplified architecture** — Removed redundant `.claude/plugin-manifest.json`
  - Plugin now relies on directory structure discovery (commands/, skills/, agents/)
  - Reduces version sync burden from 3 files to 2 files
  - Follows "Simple + Complete = Professional" principle

### Removed
- `.claude/plugin-manifest.json` — No longer needed for local development or marketplace publishing

### Documentation
- Updated CLAUDE.md to reflect 2-file version check
- Consolidated MEMORY.md from 247 to 133 lines (46% reduction)
- Created global instincts for development principles

## [3.0.4] - 2026-02-28

### Changed
- **Removed hardcoded model** — Agent now compatible with all Claude providers (Haiku, Sonnet, Opus)
  - Removed `model: sonnet` from `agents/android-code-reviewer.md`
  - Plugin now works with user's default model or specified model

### Documentation
- Updated marketplace descriptions to reflect new provider compatibility

## [3.0.3] - 2026-02-28

### Changed
- **Fixed severity default value** — Properly defaults to `high` when not specified
- **Raised confidence threshold** — Increased from 85% to 90% for fewer false positives
- **Token optimization** — 22% savings when using default settings

## [3.0.2] - 2025-02-28

### Added
- **File type filtering** — Automatic XML layout file filtering in Command layer
  - Skips `*.xml` files (layouts, menus, colors, drawables) to reduce noise
  - Only reviews source code files (`.kt`, `.java`, `.gradle`, `.gradle.kts`)
  - Logs filtering results for transparency
- **Async context detection** — Enhanced ConcurrentModificationException detection
  - Only reports collection modification during iteration when async context is present
  - Detects coroutines, handlers, threads, and worker annotations
  - Skips main-thread-only iterations (onCreate, init, etc.)
- **Test cases** — Added 5 comprehensive test cases:
  - `007-xml-layout.xml`: XML file filtering verification
  - `008-gradle-versions.gradle`: Gradle version number exception
  - `009-concurrent-main-thread.kt`: Safe main-thread iteration
  - `010-concurrent-async.kt`: Unsafe async iteration detection
  - `011-code-quality-comments.kt`: Commented code handling
- **Testing guide** — Comprehensive testing documentation in `docs/TESTING-GUIDE.md`
  - Individual test case instructions
  - Expected results and verification points
  - Batch testing commands
  - Troubleshooting guide

### Changed
- **Confidence threshold** — Raised from 80% to 85% for all rule types
  - Reduces false positives while maintaining good detection rate
  - Simplified from layered system (90%/80%/70%) to unified 85%
  - Applied consistently across Security, Architecture, and Quality rules
- **Commented code detection** — Removed entirely (too noisy)
  - Eliminated from PR CONTEXT RULES in SKILL.md
  - No longer reports commented-out code blocks
- **Gradle file handling** — Version numbers and build constants now allowed
  - Dependency versions (e.g., `1.12.0`) are not flagged as hardcoded
  - Build config constants (versionCode, versionName, minSdk) are allowed
  - Only non-version hardcoded values are still detected

### Fixed
- **XML file noise** — Reduced from 8 files to 0 files reviewed (-100%)
- **Gradle version false positives** — Reduced from ~5 warnings to 0 warnings (-100%)
- **Concurrent modification false positives** — Reduced from ~10 warnings to ~2 warnings (-80%)
- **Commented code false positives** — Reduced from ~8 warnings to 0 warnings (-100%)
- **Overall false positive rate** — Reduced from ~40% to ~10-15% (-70%)

### Documentation
- Added design document: `docs/plans/2025-02-28-android-code-review-optimization-design.md`
- Added testing guide: `docs/TESTING-GUIDE.md`
- Updated CHANGELOG.md with v3.0.2 release notes

### Migration Notes
Users should restart Claude Code after upgrading to ensure new filtering rules take effect.

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
