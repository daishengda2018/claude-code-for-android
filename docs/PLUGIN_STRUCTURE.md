# Claude Code Plugin Structure

## 1. Core Concept

A Claude Code plugin consists of:

* Marketplace metadata (`.claude-plugin/`)
* Runtime resources (`agents/`, `commands/`, `skills/`)
* Optional local development config (`.claude/`)

Only specific directories are published to the Marketplace.

---

## 2. Standard Plugin Layout

```
plugin-name/
│
├── agents/                # Optional
│   └── *.md
│
├── commands/              # Optional
│   └── *.md
│
├── skills/                # Optional but common
│   └── skill-name/
│       ├── SKILL.md
│       └── (supporting files)
│
├── .claude-plugin/        # REQUIRED for Marketplace
│   └── plugin.json OR marketplace.json
│
├── .claude/               # Local dev only (NOT published)
│   └── plugin-manifest.json (optional)
│
└── README.md
```

---

## 3. What Gets Published

Only these directories are packaged:

* `agents/`
* `commands/`
* `skills/`
* `.claude-plugin/`

Everything else is ignored by the marketplace packager.

`.claude/` is local-only.

---

## 4. Runtime Model

After installation:

* Plugin files are stored in:

```
~/.claude/plugins/cache/[owner]/[plugin]/[version]/
```

* Claude runtime dynamically registers:
  * agents
  * commands
  * skills

They are not physically copied into `~/.claude/agents`.

---

## 5. Agents vs Commands vs Skills

| Component | Role                                 |
| --------- | ------------------------------------ |
| Agent     | Execution logic                      |
| Command   | User entry point (`/command-name`) |
| Skill     | Reusable capability module           |

Typical flow:

```
User → Command → Agent → Skill → References
```

Skill-only plugins are valid (e.g., Figma).

---

## 6. Skill Structure Rules

```
skills/
└── my-skill/
    ├── SKILL.md          # required
    ├── references.md     # optional
    ├── configs.yaml      # optional
    └── templates/        # optional
```

Rules:

* `SKILL.md` must be uppercase
* All paths should be relative within the skill directory
* Do not assume repository root path

---

## 7. Marketplace Manifest

`.claude-plugin/plugin.json` (minimal form):

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Plugin description",
  "author": {
    "name": "author"
  }
}
```

`marketplace.json` is an extended multi-plugin format.

Only one is required.

---

## 8. Common Mistakes

❌ Putting skills inside `.claude/`
❌ Assuming runtime copies files to `~/.claude/agents`
❌ Using absolute repository paths
❌ Forgetting `SKILL.md` uppercase

---

## 9. Recommended Best Practice

For most plugins:

```
Use skills as core logic
Use commands as entry point
Add agent only when behavior orchestration is needed
```

Hybrid plugins are valid but often unnecessary.
