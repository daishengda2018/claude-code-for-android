# Plugin Development Guide

本指南说明如何开发和测试 `android-code-reviewer` plugin。

## 🎯 概述

这个项目采用**测试驱动开发**的方法：

1. 编写有问题的代码作为测试用例
2. 运行 plugin 检测问题
3. 优化 plugin 以提高检测率
4. 验证无误后发布新版本

## 📁 项目结构

```
claude-code-for-android/
├── .claude/                          # Plugin 源码（开发版本）
│   ├── agents/
│   │   └── android-code-reviewer.md  # ⚠️ Agent 逻辑 - 在这里修改
│   └── plugin-manifest.json
│
├── commands/
│   └── android-code-review.md        # 用户命令接口
│
├── skills/                           # ⭐ 知识库和参考文档
│   └── android-code-review/
│       ├── SKILL.md                  # 专业知识库
│       └── references/               # 检测规则参考
│           ├── sec-001-to-010-security.md
│           ├── qual-001-to-010-quality.md
│           ├── perf-001-to-008-performance.md
│           ├── jetp-001-to-008-jetpack.md
│           └── prac-001-to-008-practices.md
│
├── test-cases/                       # 独立测试用例（快速验证）✨
│   ├── 001-security-hardcoded-secrets.kt
│   ├── 002-memory-handler-leak.kt
│   └── 003-unsafe-null.kt
│
├── scripts/                          # 自动化脚本
│   ├── verify-isolation.sh           # 验证 plugin 隔离 ✨
│   ├── verify-build.sh               # 验证编译 ✨
│   ├── archive-test.sh               # 归档测试用例
│   ├── batch-validate-reviews.sh     # 批量验证脚本
│   └── publish-plugin.sh             # 发布新版本
│
├── test-android/                     # 真实 Android 测试项目 ✨
│   ├── app/src/main/java/com/test/
│   │   ├── examples/                 # 正确代码示例
│   │   └── bugs/                     # 有问题的代码
│   ├── config/                       # Detekt & Checkstyle 配置
│   └── .claude/                      # ⚠️ 必须为空！
│
├── docs/                             # 文档
│   ├── design/                       # 设计文档
│   ├── workflows/                    # 工作流文档
│   ├── requirements/                 # 需求文档
│   └── test-results/                 # 测试结果
│
└── static-analysis-config/           # 静态分析配置参考
    ├── detekt/
    └── checkstyle/
```

### 核心组件说明

| 组件 | 路径 | 作用 | 修改频率 |
|------|------|------|----------|
| **Agent** | `.claude/agents/android-code-reviewer.md` | 核心审查逻辑 | 高 |
| **Command** | `commands/android-code-review.md` | 用户命令接口 | 低 |
| **Skill** | `skills/android-code-review/SKILL.md` | 专业知识库 | 中 |
| **Rules** | `skills/android-code-review/references/` | 检测规则参考 | 中 |
| **Test Cases** | `test-cases/*.kt` | 单元测试用例 | 高 |
| **Test Project** | `test-android/` | 集成测试环境 | 中 |

## 🔄 开发工作流

### Step 1: 编写测试用例

在 `test-cases/` 目录创建新的测试文件：

```kotlin
// test-cases/004-my-test.kt

package com.test

// Expected Detection: HIGH
// File: test-cases/004-my-test.kt

class BadExample {
    // 故意写的问题代码
    private val leak = Handler()

    override fun onDestroy() {
        // 缺少清理
    }
}

// Verification Checklist:
// [ ] Plugin detects Handler leak
// [ ] Plugin severity is HIGH
// [ ] Plugin suggests proper cleanup
```

### Step 2: 运行代码审查

在 Claude Code 中直接运行 review 命令：

```
/android-code-review --target file:test-cases/004-my-test.kt
```

插件会分析文件并报告检测到的问题。

### Step 3: 分析结果

查看 plugin 是否检测到问题：

- ✅ 检测到了 → 进入 Step 5
- ❌ 漏检了 → 进入 Step 4
- ⚠️ 误检了 → 进入 Step 4

### Step 4: 改进 Plugin

编辑 `agents/android-code-reviewer.md`：

```markdown
## 🔍 Review Checklist

### Memory Leak Checks

添加新的检测规则...
```

**重要：修改后需要重启 Claude Code！**

### Step 5: 验证改进

手动验证所有测试用例以确保改进有效：

```bash
# 逐个测试每个用例
for file in test-cases/*.kt; do
    echo "Testing: $file"
    # /android-code-review --target file:$file
done
```

验证：

- [ ] 所有问题都被检测到
- [ ] 严重程度正确
- [ ] 修复建议有用

### Step 6: 真实环境测试（可选） ✨

在真实 Android 项目中测试：

```bash
# 1. 验证隔离配置
./scripts/verify-isolation.sh

# 2. 在测试项目中编写/修改问题代码
cd test-android/
# 编辑 app/src/main/java/com/test/bugs/...

# 3. 运行 AI Review
/android-code-review --target file:app/src/main/java/com/test/bugs/001-npe/ForceUnwrapActivity.kt

# 4. 验证编译（重要！）
cd ../
./scripts/verify-build.sh
```

**编译验证的意义：**

- ✅ 确认代码可以实际编译
- ✅ 发现 plugin 误报（plugin 说有问题，但代码可编译）
- ✅ 减少 AI token 消耗（脚本运行 Gradle，不用 AI）

### Step 7: 发布更新

当所有测试通过后：

```bash
./scripts/publish-plugin.sh
```

脚本会自动：

1. 更新版本号
2. 提交更改
3. 创建 git tag
4. 推送到远程
5. 提示创建 GitHub release

## 🔒 Plugin 隔离说明

### 工作原理

Claude Code 按以下顺序加载 plugin：

```
1. test-android/.claude/              ← 如果存在，优先加载（测试项目）
2. (Git root)/.claude/                ← 你的开发版本 ✅
3. ~/.claude/                          ← 用户安装的稳定版本
```

**关键约束：**

> ⚠️ **重要：** `test-android/.claude/` 目录必须**不存在**或为**空**
>
> 如果测试项目有自己的 `.claude/`，会覆盖开发版本！

**验证方法：**

```bash
./scripts/verify-isolation.sh
```

**自动验证：**
`run-review.sh` 和 `verify-plugin.sh` 会自动验证隔离

**关键点：**

- ✅ 项目级 plugin 会覆盖用户级
- ✅ 修改只影响当前项目
- ✅ 不影响其他项目或 marketplace
- ⚠️ 需要重启 Claude Code 才能加载修改

### 三层测试体系

#### **Layer 1: 独立测试文件**（快速验证）

- 位置：`test-cases/*.kt`
- 用途：快速验证单个检测规则
- 命令：`/android-code-review --target file:test-cases/<file>.kt`

#### **Layer 2: 真实 Android 项目**（深度测试） ✨

- 位置：`test-android/`
- 用途：在真实项目环境中测试
- 命令：`cd test-android/ && /android-code-review --target file:app/src/main/java/com/test/bugs/...`
- 编译验证：`./scripts/verify-build.sh`

#### **Layer 3: 批量回归测试**

- 位置：`test-cases/*.kt`（全部）
- 用途：验证所有检测规则仍然有效
- 方法：使用 `batch-validate-reviews.sh` 脚本

### 验证隔离

```bash
# 检查当前加载的 plugin
ls -la .claude/agents/android-code-reviewer.md

# 对比用户级版本
ls -la ~/.claude/homunculus/evolved/agents/android-code-reviewer.md
```

## 📊 测试覆盖率

当前测试用例覆盖：

| 类别     | 测试用例              | 状态 |
| -------- | --------------------- | ---- |
| Security | 001-hardcoded-secrets | ✅   |
| Memory   | 002-handler-leak      | ✅   |
| Quality  | 003-unsafe-null       | ✅   |

目标覆盖：

- [ ] Security: 10+ cases
- [ ] Memory: 8+ cases
- [ ] Performance: 5+ cases
- [ ] Architecture: 5+ cases
- [ ] Quality: 10+ cases

## 🚀 常见问题

### Q: 修改 plugin 后没有生效？

**A:** 需要重启 Claude Code：

```bash
# macOS
Quit Claude Code and reopen

# 或者使用命令（如果支持）
/claude restart
```

### Q: 如何确认使用的是开发版？

**A:** 在项目中检查：

```bash
# 应该指向项目目录
ls -la .claude/agents/

# 而不是用户目录
ls -la ~/.claude/homunculus/evolved/agents/
```

### Q: 测试通过后如何发布？

**A:** 运行发布脚本：

```bash
./scripts/publish-plugin.sh
```

### Q: 会不会影响 marketplace 的其他用户？

**A:** 不会！原因：

1. 开发只在项目级进行
2. 用户安装的是 marketplace 的特定版本
3. 只有当你主动发布新版本时，用户才能获得更新
4. 用户可以选择是否更新

## 📝 开发最佳实践

1. **小步迭代**

   - 每次只修改一个检测规则
   - 立即测试验证
   - 频繁提交代码
2. **测试驱动**

   - 先写测试用例
   - 再实现检测逻辑
   - 确保所有测试通过
3. **文档同步**

   - 修改 plugin 时更新文档
   - 记录新的检测规则
   - 添加示例代码
4. **版本管理**

   - 遵循语义化版本
   - 每个版本有明确更新内容
   - 保持 CHANGELOG

## 🎓 示例：添加新的检测规则

假设要添加"AsyncTask 泄漏"检测：

### 1. 写测试用例

```kotlin
// test-cases/004-async-task-leak.kt
class AsyncTaskLeak : Activity() {
    // 内部类持有 Activity 引用
    private inner class MyTask : AsyncTask<Void, Void, Void>() {
        override fun doInBackground(vararg params: Void?): Void? {
            // 长时间运行
            Thread.sleep(5000)
            return null
        }
    }
}
```

### 2. 运行审查

在 Claude Code 中运行：

```
/android-code-review --target file:test-cases/004-async-task-leak.kt
```

### 3. 修改 Plugin

在 `.claude/agents/android-code-reviewer.md` 添加：

```markdown
### AsyncTask Memory Leak Checks

```kotlin
// ❌ HIGH: Inner class AsyncTask
class LeakyActivity : Activity() {
    private inner class MyTask : AsyncTask<Void, Void, Void>() {
        // Implicit reference to Activity
    }
}

// ✅ CORRECT: Use static inner class or coroutines
class SafeActivity : Activity() {
    private class MyTask(val activityRef: WeakReference<Activity>) : AsyncTask<Void, Void, Void>() {
        override fun doInBackground(vararg params: Void?): Void? {
            activityRef.get()?.let { activity ->
                // Use activity safely
            }
            return null
        }
    }
}
```

```

### 4. 验证

运行所有测试用例的 review 来验证：
```

/android-code-review --target file:test-cases/001-*.kt
/android-code-review --target file:test-cases/002-*.kt

# ... etc

```

### 5. 发布

```bash
./scripts/publish-plugin.sh
```

## 📞 获取帮助

- 📖 查看测试用例: `test-cases/`
- 🔧 运行测试: `/android-code-review --target file:<path>`
- ✅ 验证隔离: `scripts/verify-isolation.sh`
- 🔨 验证编译: `scripts/verify-build.sh`
- 🚀 发布更新: `scripts/publish-plugin.sh`

---

Happy coding! 🎉
