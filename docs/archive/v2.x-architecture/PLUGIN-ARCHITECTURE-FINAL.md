# Claude Code 插件架构 - 最终理解

## 🔍 关键发现

通过对比 `everything-claude-code` 插件，发现了正确的插件结构：

### 1. Command 文件格式

**❌ 错误理解**：Command 需要引用 skill
```yaml
---
name: my-command
skill: my-skill  # ❌ 不需要这个字段
---
```

**✅ 正确格式**：Command 只描述功能，不引用 skill
```yaml
---
name: my-command
description: What this command does
---

# Command Title

Description of what happens when user runs this command.
```

### 2. 技能被自动发现

Skills 不需要在 command 中引用。它们通过以下方式被自动发现：
- Plugin manifest 中的 `skills` 字段指定目录
- Command 执行时，Claude Code 自动加载相关 skills
- Agent 主动引用 skills（通过 frontmatter 或内容）

### 3. 正确的目录结构

```
claude-code-for-android/
├── .claude-plugin/
│   └── plugin.json              # 插件清单
│
├── commands/                    # 命令文件（项目根目录）
│   └── android-code-review.md   # ✅ 简洁描述，无 skill 引用
│
├── skills/                      # 技能文件（项目根目录）
│   └── android-code-review/
│       └── SKILL.md             # ✅ 知识库，被 Agent 引用
│
├── agents/                      # 代理文件（项目根目录）
│   └── android-code-reviewer.md # ✅ 执行逻辑
│
└── .claude/
    ├── settings.json            # 权限配置
    ├── hooks/
    └── memory/
```

### 4. plugin.json 格式

```json
{
  "name": "claude-code-for-android",
  "version": "2.1.1",
  "description": "...",
  "author": "...",
  "license": "Apache-2.0",
  "repository": "...",
  "homepage": "...",
  "skills": ["./skills/", "./commands/"],
  "agents": ["./agents/android-code-reviewer.md"]
}
```

**关键点**：
- `skills` 包含 `./commands/` — commands 也可以被视为 skills
- `agents` 列出具体的 agent 文件路径

### 5. 执行流程

```
User runs: /android-code-review
    ↓
Command 文件被读取（提供上下文和参数说明）
    ↓
Claude Code 自动加载相关 skills（包括 command 本身）
    ↓
如果 command 提到 agent 或需要执行，Claude Code 调用 agent
    ↓
Agent 引用 skills 中的知识库
    ↓
Agent 执行分析并输出结果
```

### 6. Skill 的作用

Skill 是**知识库**，不是执行逻辑：
- ✅ 提供检测规则、checklist、模式
- ✅ 被 Agent 主动引用和学习
- ❌ 不负责执行或编排

### 7. Agent 的作用

Agent 是**执行者**：
- ✅ 阅读代码
- ✅ 应用 skill 中的规则
- ✅ 执行分析
- ✅ 输出结果

### 8. Command 的作用

Command 是**用户接口**：
- ✅ 描述命令功能
- ✅ 说明参数用法
- ✅ 提供上下文
- ❌ 不引用 skill 或 agent

---

## 📝 对比：修改前后

### 修改前（错误）

```yaml
# commands/android-code-review.md
---
name: android-code-review
skill: android-code-review  # ❌ 多余字段
parameters: ...              # ❌ 不需要
---

# 执行流程...
```

### 修改后（正确）

```yaml
# commands/android-code-review.md
---
name: android-code-review
description: Android PR & commit review...
---

# Android Code Review

Comprehensive Android code review...

## What This Command Does
1. Auto-detect scope
2. Gather context
...

## Usage
/android-code-review --target file:...
```

---

## 🎯 当前状态

| 组件 | 状态 | 说明 |
|------|------|------|
| `.claude-plugin/plugin.json` | ✅ 正确 | 已修复位置和格式 |
| `commands/android-code-review.md` | ✅ 正确 | 已移除 skill 引用 |
| `skills/android-code-review/SKILL.md` | ✅ 正确 | 知识库格式正确 |
| `agents/android-code-reviewer.md` | ✅ 正确 | Agent 格式正确 |
| `.claude/settings.json` | ✅ 正确 | 权限配置完整 |

---

## 🚀 下一步

**重启 Claude Code 并测试：**

```bash
/android-code-review --target file:test-cases/001-security-hardcoded-secrets.kt
```

---

## 📚 参考

- **对比插件**: `~/.claude/plugins/cache/everything-claude-code/everything-claude-code/1.4.1/`
- **Command 示例**: `everything-claude-code/commands/e2e.md`, `go-build.md`
- **Plugin 结构**: `everything-claude-code/.claude-plugin/plugin.json`

---

**最后更新**: 2026-02-28 16:55
**问题状态**: 等待测试验证
