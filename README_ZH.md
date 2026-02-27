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
cp -r agents/* ~/.claude/agents/
```

---

## 使用方法

### 基础审查（暂存的更改）

```bash
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
android-code-review --target all --severity critical
```

### 审查特定提交

```bash
android-code-review --target commit:a1b2c3d
```

---

## 审查内容

| 类别 | 检查项 |
|------|--------|
| **安全** | 硬编码密钥、不安全存储、Intent 劫持、WebView 漏洞、明文传输 |
| **代码质量** | 内存泄漏、错误处理、大型函数、深层嵌套、死代码 |
| **Android 模式** | 生命周期违规、ViewModel 误用、已弃用的 API、权限处理 |
| **Jetpack/Kotlin** | 协程误配置、Room 问题、Hilt 错误、Compose 反模式 |
| **性能** | ANR 风险、布局效率、Bitmap 管理问题、启动瓶颈 |
| **最佳实践** | 命名规范、文档、可访问性、资源管理 |

---

## 命令选项

| 参数 | 值 | 默认值 | 描述 |
|------|-----|--------|------|
| `--target` | `staged`、`all`、`commit:<hash>`、`file:<path>` | `staged` | 审查范围 |
| `--severity` | `critical`、`high`、`medium`、`low`、`all` | `all` | 按严重级别过滤 |
| `--project-guidelines` | `<file-path>` | - | 自定义指南文件 |
| `--output-format` | `markdown`、`json` | `markdown` | 输出格式 |

---

## 输出示例

```
# Android 代码审查结果
## 目标：暂存的更改

[CRITICAL] 源代码中硬编码的 API 密钥
文件：app/src/main/java/com/example/ApiClient.kt:15
问题：API 密钥 "sk_abc123" 暴露在源代码中。这将被提交到 git 历史记录，并可通过 APK 反编译看到。
修复：将 API 密钥移至 gradle.properties，生成 BuildConfig，并引用 BuildConfig.API_KEY。

[HIGH] Activity 内存泄漏
文件：app/src/main/java/com/example/LeakyActivity.kt:22
问题：静态 Handler 中引用了 Activity Context，当 Activity 被销毁时会导致泄漏。
修复：使用 Application Context 并在 onDestroy() 中清理 Handler。

## 审查摘要

| 严重级别 | 数量 | 状态 |
|----------|------|------|
| CRITICAL | 1     | 失败  |
| HIGH     | 1     | 警告  |
| MEDIUM   | 0     | 信息  |
| LOW      | 2     | 注意  |

判定：阻止 — 必须在合并前修复 1 个 CRITICAL 问题。
```

---

## 插件结构

```
claude-code-for-android/
├── commands/
│   └── android-code-review.md     # 用户可调用的命令
├── agents/
│   └── android-code-reviewer.md    # 审查代理逻辑
└── .claude/
    └── plugin-manifest.json        # Claude Code marketplace 清单
```

---

## 合规与标准

本插件强制执行以下标准：

- Google [Android 应用质量指南](https://developer.android.com/quality-guidelines)
- [Android 安全最佳实践](https://developer.android.com/topic/security/best-practices)
- [Android Kotlin 风格指南](https://developer.android.com/kotlin/style-guide)
- Jetpack Compose [性能与最佳实践](https://developer.android.com/jetpack/compose/performance)

---

## 贡献

欢迎贡献！请随时提交 Pull Request。

---

## 开发文档

如果你想参与开发或了解内部实现，请查看：

- 📖 [开发指南](DEVELOPMENT.md) - Plugin 开发指南
- 🎨 [设计文档](docs/plans/2026-02-27-android-test-project-integration-design.md) - 架构设计
- 🔄 [开发工作流](docs/workflows/development-cycle.md) - 开发周期
- 📜 [变更日志](CHANGELOG.md) - 版本历史

---

## 许可证

Apache-2.0 © [daishengda2018](https://github.com/daishengda2018)

---

## 仓库地址

https://github.com/daishengda2018/claude-code-for-android
