# Android Code Review Skill - Changelog

## [Unreleased] - 2026-03-03

### 🎉 Major Update: Skill Fusion & Description Optimization

This release combines the best features from two skill versions and adds significant description optimization for better triggering.

### ✨ New Features

**Severity-Based Pattern Loading**
- `critical` (~1,500 tokens): Production blockers only (security + crash issues)
- `high` (~6,900 tokens): Security + Quality + Architecture + Jetpack
- `medium` (~8,100 tokens): Above + Performance + Best Practices
- `all` (~8,900 tokens): All patterns including PR context rules

**Dual-Mode Support**
- Standalone mode: Direct analysis without agent orchestration
- Agent-orchestrated mode: Integrates with android-code-reviewer agent

**Confidence Scoring**
- 90%+ confidence threshold
- Confidence levels displayed for each issue
- "POTENTIAL ISSUE" marking for lower confidence findings

### 🔧 Improved Detection Rules

**Enhanced Coverage:**
- Memory leaks (static references, Handler leaks, lifecycle issues)
- Thread safety (UI updates from background, GlobalScope misuse)
- Lifecycle problems (Fragment after onDestroyView, state loss)
- Security vulnerabilities (hardcoded secrets, credential logging)
- Architectural anti-patterns (God objects, deep nesting, duplication)

**New Patterns Added:**
- CalledFromWrongThreadException detection
- Coroutine scope management (lifecycleScope vs custom scope)
- ViewModel/Service/BroadcastReceiver lifecycle awareness
- Sealed classes for state modeling
- ContentDescription accessibility checks

### 📝 Description Optimization

**Before (95 words):**
> Automated Android code review with severity-based filtering. Use when: user mentions "review android"...

**After (115 words):**
> Android code review expert. **CRITICAL: Use this skill whenever** the user mentions Android code...
> Trigger on phrases like "**CalledFromWrongThreadException**", "**out of memory**", "**app crashing**"...
> **Always use when reviewing Android/Kotlin/Java code.**

**Trigger Coverage Improvements:**
- ✅ Specific Android components (ViewModel, Service, BroadcastReceiver)
- ✅ Error types (CalledFromWrongThreadException, OOM)
- ✅ User problems (app crashing, memory leaks, security issues)
- ✅ More "pushy" phrasing to compensate for Claude's undertriggering tendency

### 🎨 Enhanced Output Format

**Structured Output with:**
- 📊 Summary section with issue counts
- 🔴 CRITICAL / 🟠 HIGH / 🟡 MEDIUM severity indicators
- File:line references
- Code snippets with ❌ wrong vs ✅ correct patterns
- Impact analysis
- Specific fix recommendations
- Confidence percentages
- Reference links

### 📚 Documentation

**Test Cases:**
- 3 comprehensive test cases created
- Memory leak detection
- Thread safety & lifecycle issues
- Security vulnerabilities (hardcoded secrets)

**Files:**
- `SKILL.md` - Main skill file (enhanced)
- `evals/evals.json` - Test case definitions
- `CHANGELOG.md` - This file

### 🔄 Migration Notes

**Breaking Changes:**
None - This is a drop-in replacement for the previous version.

**Recommended Actions:**
1. Restart Claude Code to load the new skill
2. Test with your existing Android code review workflow
3. Provide feedback for further improvements

### 🙏 Credits

Created by combining:
- Project version: Severity-based loading, Agent orchestration
- Custom version: Detailed rules, Emoji formatting, Usage guide

Optimized using skill-creator methodology with trigger evaluation and description optimization.

---

## Previous Versions

### v3.0.6 (2026-02-28)
- Simplified architecture
- Agent orchestration support

### v3.0.5 and earlier
- See project git history
