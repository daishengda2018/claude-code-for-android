# Claude Code Plugin Structure Guide

This document describes the standard directory structure for Claude Code plugins, based on analysis of official plugins (figma, everything-claude-code) installed from the marketplace.

## Standard Plugin Structure

```
plugin-name/
├── agents/                           # Plugin Agent definitions (published)
│   └── [agent-name].md               # Agent logic and behavior
│
├── commands/                         # Plugin Command definitions (published)
│   └── [command-name].md             # Command interface and parameters
│
├── skills/                           # Plugin Skills (published) 🎯
│   └── [skill-name]/                 # Skill subdirectory (named by skill)
│       ├── SKILL.md                  # Main skill orchestration layer
│       └── [dependencies]/           # Skill dependency files
│           ├── *.md                  # Reference files, configs, etc.
│           └── ...
│
├── .claude/                          # Project-level config (NOT published)
│   ├── plugin-manifest.json          # Plugin metadata
│   ├── settings.local.json           # Local development settings
│   └── settings.json                 # Project settings (optional)
│
├── .claude-plugin/                   # Marketplace metadata
│   ├── plugin.json                   # OR marketplace.json (either works)
│   └── [other marketplace files]
│
└── [other project files]
```

## Directory Purposes

### Published to Marketplace

These directories are included when users install your plugin from the marketplace:

| Directory | Purpose | Installation Target |
|-----------|---------|---------------------|
| `agents/` | Agent definitions that perform specific tasks | `~/.claude/agents/` |
| `commands/` | User-invocable command interfaces | `~/.claude/commands/` |
| `skills/` | Skill orchestration layers with dependencies | `~/.claude/skills/` |

### NOT Published

These are for local development only:

| Directory | Purpose |
|-----------|---------|
| `.claude/` | Project-level configuration, only affects your local development |
| `.git/` | Git repository data |
| `test-*` | Test directories |

## Examples from Official Plugins

### Figma Plugin (v1.0.0)

```
figma/
├── .claude-plugin/
│   └── plugin.json                   # Simple manifest
├── skills/                           # Three skill modules
│   ├── implement-design/
│   │   └── SKILL.md
│   ├── code-connect-components/
│   │   └── SKILL.md
│   └── create-design-system-rules/
│       └── SKILL.md
└── README.md
```

**Observation:** Figma plugin has no `agents/` or `commands/` directories, only `skills/`. This is a **skill-only plugin**.

### Everything Claude Code (v1.4.1)

```
everything-claude-code/
├── .claude-plugin/
│   └── marketplace.json
├── skills/                           # 30+ skill modules
│   ├── backend-patterns/
│   │   └── SKILL.md
│   ├── coding-standards/
│   │   └── SKILL.md
│   ├── django-patterns/
│   │   └── SKILL.md
│   ├── python-patterns/
│   │   └── SKILL.md
│   ├── security-review/
│   │   ├── SKILL.md
│   │   └── cloud-infrastructure-security.md
│   └── ... (26 more skills)
└── docs/
```

**Observation:** This plugin demonstrates that skills can have additional dependency files (like `cloud-infrastructure-security.md` in `security-review/`).

### Claude Code for Android (v2.0.0) - This Plugin

```
claude-code-for-android/
├── agents/
│   └── android-code-reviewer.md
├── commands/
│   └── android-code-review.md
├── skills/
│   └── android-code-review/
│       ├── SKILL.md
│       └── references/
│           ├── sec-001-to-010-security.md
│           ├── qual-001-to-010-quality.md
│           ├── arch-001-to-009-architecture.md
│           ├── jetp-001-to-008-jetpack.md
│           ├── perf-001-to-008-performance.md
│           └── prac-001-to-008-practices.md
├── .claude/
│   ├── plugin-manifest.json
│   └── settings.local.json
├── .claude-plugin/
│   └── marketplace.json
└── test-cases/
```

**This is a hybrid plugin:** Uses agents, commands, AND skills together.

## Installation Paths

When users install your plugin from the marketplace, files are copied to:

```
~/.claude/plugins/cache/
└── [plugin-author]/
    └── [plugin-name]/
        └── [version]/
            ├── agents/ → copied to ~/.claude/agents/
            ├── commands/ → copied to ~/.claude/commands/
            └── skills/ → copied to ~/.claude/skills/
```

## File Naming Conventions

### Agents
- Use kebab-case: `android-code-reviewer.md`
- Descriptive name ending with `-er` or `-or`: `reviewer`, `executor`, `analyzer`

### Commands
- Use kebab-case: `android-code-review.md`
- Match the command name users type: `/android-code-review`

### Skills
- Skill directory: kebab-case name: `android-code-review`
- SKILL.md: UPPERCASE filename (required by Claude Code)
- Dependencies: descriptive names: `references/`, `configs/`, `templates/`

## Manifest Files

### plugin.json (Figma style)

```json
{
  "name": "plugin-name",
  "description": "Plugin description",
  "version": "1.0.0",
  "author": {
    "name": "Author Name"
  }
}
```

### marketplace.json (Everything Claude Code style)

```json
{
  "name": "plugin-name",
  "owner": {
    "name": "username",
    "email": "user@users.noreply.github.com"
  },
  "metadata": {
    "description": "Plugin description"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "version": "1.0.0",
      "source": "./",
      "description": "Detailed description",
      "author": {
        "name": "username"
      },
      "repository": "https://github.com/username/repo",
      "license": "Apache-2.0",
      "keywords": ["tag1", "tag2"],
      "category": "category-name",
      "tags": ["tag1", "tag2"]
    }
  ]
}
```

### plugin-manifest.json (Project-level)

```json
{
  "manifestVersion": "1.0",
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Plugin description",
  "author": "username",
  "license": "Apache-2.0",
  "repository": {
    "type": "git",
    "url": "https://github.com/username/repo.git"
  },
  "capabilities": {
    "commands": ["command-name"],
    "agents": ["agent-name"]
  },
  "installation": {
    "type": "marketplace",
    "minClaudeVersion": "1.0.0"
  },
  "categories": ["category1", "category2"]
}
```

## Best Practices

### 1. Skill Organization
- Keep skills modular: one skill per concern
- Use subdirectories for dependencies: `references/`, `configs/`, `templates/`
- Reference dependencies with relative paths from SKILL.md

### 2. Path References in Skills
- If SKILL.md and dependencies are in same directory: use relative path `references/file.md`
- If referencing from agents/commands to skills: use `skills/skill-name/references/file.md`

### 3. Project vs. Marketplace Files
- **Project-level (`.claude/`)**: Settings that affect ONLY your local development
- **Marketplace (agents/, commands/, skills/)**: Files that get published to users

### 4. Version Management
- Keep versions in sync across:
  - `.claude/plugin-manifest.json`
  - `.claude-plugin/marketplace.json` (or `plugin.json`)
  - `skills/*/SKILL.md` (if versioned)

### 5. Documentation
- Include `README.md` in project root
- Include installation instructions
- Document skill dependencies and their purposes

## Common Mistakes to Avoid

### ❌ Mistake 1: Putting skills in `.claude/`
```bash
# WRONG
.claude/
└── skills/              # These won't be published!
    └── my-skill/
```

**Correct:**
```bash
# ✅ CORRECT
skills/                  # In project root, will be published
└── my-skill/
```

### ❌ Mistake 2: Agents/Commands in `.claude/`
```bash
# WRONG
.claude/
├── agents/              # These won't be published!
└── commands/
```

**Correct:**
```bash
# ✅ CORRECT
agents/                  # In project root, will be published
commands/
```

### ❌ Mistake 3: Incorrect path references
```yaml
# In agents/my-agent.md:
load: skills/my-skill/config.yaml  # ❌ Won't work after installation
```

**Correct:**
```yaml
# In agents/my-agent.md:
load: skills/my-skill/config.yaml  # ✅ Works both locally and after installation
```

## Testing Your Plugin Structure

### Verify Files Will Be Published

```bash
# Check marketplace source path
grep '"source"' .claude-plugin/marketplace.json

# Should show: "source": "./"  (relative to marketplace.json)
```

### Test Installation Locally

```bash
# 1. Build package
./scripts/publish-plugin.sh

# 2. Install from local source
/plugin marketplace add /path/to/plugin

# 3. Verify files are in correct locations
ls -la ~/.claude/plugins/cache/[author]/[plugin-name]/[version]/
ls -la ~/.claude/agents/
ls -la ~/.claude/commands/
ls -la ~/.claude/skills/
```

## References

- Official Figma Plugin: `~/.claude/plugins/cache/claude-plugins-official/figma/1.0.0/`
- Everything Claude Code: `~/.claude/plugins/cache/everything-claude-code/everything-claude-code/1.4.1/`
- This Plugin: `https://github.com/daishengda2018/claude-code-for-android`

## Version History

- **v1.0** (2026-02-27): Initial documentation based on official plugin analysis
