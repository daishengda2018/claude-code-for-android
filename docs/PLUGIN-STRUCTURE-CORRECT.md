# Claude Code 插件目录结构 - 正确版本

## ✅ 正确的目录结构

```
claude-code-for-android/
├── .claude-plugin/              # 元数据目录（必需）
│   └── plugin.json              # 插件清单（必需）
│
├── commands/                    # 命令文件（项目根目录）
│   └── android-code-review.md
│
├── skills/                      # 技能文件（项目根目录）
│   └── android-code-review/
│       └── SKILL.md
│
├── agents/                      # 代理文件（项目根目录）
│   └── android-code-reviewer.md
│
└── .claude/                     # 配置目录
    ├── settings.json            # 权限配置
    ├── hooks/                   # 钩子配置
    └── memory/                  # 记忆存储
```

## 🔑 关键规则

1. **`.claude-plugin/plugin.json`** 是必需的
   - ❌ 不是 `.claude/plugin-manifest.json`
   - ❌ 不是 `.claude-plugin/plugin-manifest.json`
   - ✅ 应该是 `.claude-plugin/plugin.json`

2. **组件目录位置**
   - ✅ `commands/`, `skills/`, `agents/` 在**项目根目录**
   - ❌ 不在 `.claude-plugin/` 下
   - ❌ 不在 `.claude/` 下

3. **路径配置**
   ```json
   {
     "commands": "./commands",
     "skills": "./skills",
     "agents": "./agents"
   }
   ```
   路径相对于插件根目录，以 `./` 开头

## 📄 plugin.json 标准格式

```json
{
  "name": "claude-code-for-android",
  "version": "2.1.1",
  "description": "Android code review toolkit",
  "author": "daishengda2018",
  "license": "Apache-2.0",
  "repository": "https://github.com/...",
  "homepage": "https://github.com/...",
  "commands": "./commands",
  "skills": "./skills",
  "agents": "./agents"
}
```

### 必需字段
- `name`: 插件名称（kebab-case）

### 可选字段
- `version`: 版本号
- `description`: 描述
- `author`: 作者信息
- `license`: 许可证
- `repository`: 仓库 URL
- `homepage`: 主页 URL
- `commands`: 命令目录路径
- `skills`: 技能目录路径
- `agents`: 代理目录路径

## 🔍 常见错误

### 错误 1: 错误的清单文件位置
```
❌ .claude/plugin-manifest.json
❌ .claude-plugin/plugin-manifest.json
✅ .claude-plugin/plugin.json
```

### 错误 2: 组件目录位置错误
```
❌ .claude/commands/
❌ .claude-plugin/commands/
✅ commands/ (项目根目录)
```

### 错误 3: 目录命名不一致
```
❌ agent/ (单数)
✅ agents/ (复数，与配置匹配)
```

## 📚 参考

- [Claude Code Plugin Documentation](https://docs.anthropic.com/claude-code/plugins)
- [Plugin Manifest Specification](https://docs.anthropic.com/claude-code/plugins/manifest)
- [Example Plugin Repository](https://github.com/anthropics/claude-code-plugins)

---

## 🎯 本项目的修复记录

**问题 1**: 使用了 `.claude/plugin-manifest.json`
- **修复**: 移动并重命名为 `.claude-plugin/plugin.json`

**问题 2**: 组件目录在项目根目录，但清单在 `.claude/` 下
- **修复**: 将清单移到 `.claude-plugin/`，组件保持在根目录

**问题 3**: `agent/` 目录名是单数
- **修复**: 重命名为 `agents/` (复数)

**问题 4**: 清单包含不必要的字段（`manifestVersion`, `capabilities`, `categories`）
- **修复**: 简化为标准格式，使用路径配置而不是 capabilities 列表

---

## ✅ 验证清单

- [ ] `.claude-plugin/plugin.json` 存在
- [ ] `commands/` 在项目根目录
- [ ] `skills/` 在项目根目录
- [ ] `agents/` 在项目根目录
- [ ] 路径配置正确（`./commands`, `./skills`, `./agents`）
- [ ] 所有文件有正确的 frontmatter
- [ ] `.claude/settings.json` 配置了权限

---

**最后更新**: 2026-02-28
**Claude Code 版本**: Latest
