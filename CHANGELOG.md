# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Automated test report generation
- Statistical data visualization
- Performance metrics analysis

## [2.1.1] - 2026-02-28

### Changed
- Simplified command interface with smart auto-detection
- Improved documentation structure

### Fixed
- Corrected token usage data inconsistencies (28-41% reduction, not 40-50%)
- Fixed execution logic documentation alignment

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

[Unreleased]: https://github.com/daishengda2018/claude-code-for-android/compare/v2.1.1...HEAD
[2.1.1]: https://github.com/daishengda2018/claude-code-for-android/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/daishengda2018/claude-code-for-android/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/daishengda2018/claude-code-for-android/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/daishengda2018/claude-code-for-android/releases/tag/v1.0.0
