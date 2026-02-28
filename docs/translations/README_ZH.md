# Claude Code for Android

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blue.svg)](https://claude.ai/claude-code)

English | **简体中文**

Android Kotlin/Java 代码自动化审查工具 - 基于 Google 官方 Android 最佳实践的质量、安全性和性能检查。

---

## 特性

- 🔍 **自动化代码审查** — 主动审查 Android 代码变更
- 🛡️ **安全扫描** — 检测硬编码密钥、不安全存储、WebView 漏洞
- ⚡ **性能分析** — 识别 ANR 风险、内存泄漏、布局效率问题
- 📱 **Android 最佳实践** — 强制执行 Jetpack、Kotlin 和生命周期模式
- 🎯 **基于置信度的过滤** — 只报告真实问题（>80% 置信度），零噪音

---

## 安装

### 通过 Marketplace（推荐）

```bash
# 步骤 1：添加 marketplace
/plugin marketplace add daishengda2018/claude-code-for-android

# 步骤 2：安装插件
/plugin install claude-code-for-android@claude-code-for-android

# 步骤 3：验证安装
/plugin
```

### 手动安装

```bash
git clone https://github.com/daishengda2018/claude-code-for-android.git
cd claude-code-for-android
cp -r commands/* ~/.claude/commands/
```

---

## 使用方法

### 🚀 智能自动检测（v2.1.1+）

**零配置** — 直接运行：

```bash
android-code-review
```

插件自动检测审查目标：
1. **已暂存的更改** → `git diff --staged`
2. **未暂存的更改** → `git diff`
3. **最后一次提交** → `git log -1 --patch`

### 基础审查

```bash
# 使用自动检测审查（推荐）
android-code-review

# 等同于手动指定：
android-code-review --target staged
```

### 审查特定文件

```bash
android-code-review --target file:app/src/main/java/com/example/MyFragment.kt
```

### 审查所有未提交的更改

```bash
android-code-review --target all
```

### 按严重级别过滤审查

```bash
# 仅安全审查（最快）
android-code-review --severity critical

# 高严重级别（默认）
android-code-review --severity high

# 所有检查
android-code-review --severity all
```

### 审查特定提交

```bash
android-code-review --target commit:a1b2c3d
```

### JSON 输出（用于 CI/CD）

```bash
android-code-review --output-format json > review.json
```

---

## 审查内容

| 类别 | 检查项 |
|------|--------|
| **安全（Security）** | 硬编码密钥、不安全存储、Intent 劫持、WebView 漏洞、明文传输 |
| **代码质量（Code Quality）** | 内存泄漏、错误处理、大型函数、深层嵌套、死代码 |
| **Android 模式** | 生命周期违规、ViewModel 误用、已弃用的 API、权限处理 |
| **Jetpack/Kotlin** | 协程误配置、Room 问题、Hilt 错误、Compose 反模式 |
| **性能（Performance）** | ANR 风险、布局效率、Bitmap 管理问题、启动瓶颈 |
| **最佳实践** | 命名规范、文档、可访问性、资源管理 |

---

## 命令选项

| 参数 | 值 | 默认值 | 描述 |
|------|-----|--------|------|
| `--target` | `auto`, `staged`, `all`, `commit:<hash>`, `file:<path>` | `auto` | 审查范围（auto = 智能检测） |
| `--severity` | `critical`, `high`, `medium`, `low`, `all` | `high` | 按严重级别过滤 |
| `--output-format` | `markdown`, `json` | `markdown` | 输出格式 |

**Token 效率**（v2.1.1）：
- 自动检测减少 60% 的命令开销
- 按严重级别渐进式加载模式
- 平均节省：38-39%（相比 v2.0）

---

## 示例输出

```
# Android Code Review 结果
## 目标：暂存的更改

[CRITICAL] 源代码中硬编码 API 密钥
文件：app/src/main/java/com/example/ApiClient.kt:15
问题：API 密钥 "sk_abc123" 暴露在源代码中。这将被提交到 git 历史并在 APK 反编译中可见。
修复：将 API 密钥移至 gradle.properties，生成 BuildConfig，并引用 BuildConfig.API_KEY。

[HIGH] Activity 中的内存泄漏
文件：app/src/main/java/com/example/LeakyActivity.kt:22
问题：Activity Context 在静态 Handler 中引用 → Activity 销毁时泄漏。
修复：使用 Application Context 并在 onDestroy() 中清理 Handler。

## 审查摘要

| 严重级别 | 数量 | 状态 |
|----------|------|------|
| CRITICAL | 1    | 失败  |
| HIGH     | 1    | 警告  |
| MEDIUM   | 0    | 信息  |
| LOW      | 2    | 备注  |

判定：阻塞 — 1 个 CRITICAL 问题必须在合并前修复。
```

---

## 插件结构（v2.1）

```
claude-code-for-android/
├── commands/
│   └── android-code-review.md         # 用户可调用命令
├── skills/
│   └── android-code-review/
│       ├── SKILL.md                   # 审查编排逻辑
│       ├── patterns/                  # 检测模式（v2.1）
│       │   ├── security-patterns.md
│       │   ├── quality-patterns.md
│       │   ├── architecture-patterns.md
│       │   ├── jetpack-patterns.md
│       │   ├── performance-patterns.md
│       │   └── practices-patterns.md
│       └── references/                # 详细参考文档
└── .claude/
    └── plugin-manifest.json           # Marketplace 清单
```

---

## 合规与标准

本插件强制执行以下标准：

- Google 的 [Android 应用质量指南](https://developer.android.com/quality-guidelines)
- [Android 安全最佳实践](https://developer.android.com/topic/security/best-practices)
- [Android Kotlin 风格指南](https://developer.android.com/kotlin/style-guide)
- Jetpack Compose [性能与最佳实践](https://developer.android.com/jetpack/compose/performance)

---

## 文档

**快速入门**：[用户指南](../USER_GUIDE.md)

### 面向用户

- 📖 [用户指南](../USER_GUIDE.md) - 完整使用指南和测试套件
- 📋 [所有文档](../docs/) - 浏览所有文档

### 面向贡献者

- 🔧 [贡献指南](../../CONTRIBUTING.md) - 贡献指南
- 📖 [开发指南](../../DEVELOPMENT.md) - 插件开发指南
- 🔄 [开发工作流](../docs/guides/development/development-cycle.md) - 开发周期
- 📊 [贡献标准](../../CONTRIBUTING_STANDARDS.md) - 编码标准

### 架构与参考

- 🎨 [插件结构](../docs/PLUGIN_STRUCTURE.md) - 内部结构
- 📖 [检测模式](../../skills/android-code-review/patterns/) - 有效的检测规则

---

## 版本历史

### v2.1.1 (2026-02-28)
- ✨ **智能自动检测** — 零配置审查（staged → unstaged → last commit）
- ⚡ **60% 命令 token 减少** — 简化界面
- 📉 **38-39% 平均 token 节省** — 基于模式的检测
- 🗑️ **移除废弃的 agents/** — 简化架构

### v2.1.0 (2026-02-28)
- 🎯 基于模式的检测（替换代码示例）
- 🏗️ 简化架构（2 层 vs 3 层）
- 📊 按严重级别的渐进式模式加载

### v2.0.0 (2026-02-27)
- 渐进式规则加载和 token 预算管理

### v1.0.0 (2026-02-26)
- 初始单体式代理

---

## 测试套件状态

| 组件 | 状态 | 覆盖范围 |
|-----------|--------|----------|
| 安全（SEC-001） | ✅ 已验证 | 硬编码密钥、API 密钥 |
| 内存（QUAL-002） | ✅ 已验证 | Handler 泄漏 |
| 内存（QUAL-003） | ✅ 已验证 | ViewModel 协程泄漏 |
| 内存（QUAL-004） | ✅ 已验证 | CoroutineScope 泄漏 |
| 质量（NPE） | ✅ 已验证 | 强制解包、不安全可空 |

**总体：** 9 个测试用例 100% 检测准确率 | 0% 误报率

---

## 贡献

欢迎贡献！请参阅 [CONTRIBUTING.md](../../CONTRIBUTING.md) 了解指南。

- [贡献标准](../../CONTRIBUTING_STANDARDS.md) - 编码和文档标准
- [行为准则](../../CODE_OF_CONDUCT.md) - 社区指南
- [更新日志](../../CHANGELOG.md) - 版本历史

---

## 许可证

Apache-2.0 © [daishengda2018](https://github.com/daishengda2018)

---

## 仓库

https://github.com/daishengda2018/claude-code-for-android
