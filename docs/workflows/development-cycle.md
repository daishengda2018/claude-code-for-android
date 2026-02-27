# Plugin Development Cycle Workflow

完整的 plugin 开发周期工作流程。

## 🔄 完整开发周期

### Phase 1: 快速验证（独立测试文件）

```
1. 编写测试用例
   └─ test-cases/004-new-rule.kt

2. 运行快速验证
   └─ ./scripts/run-review.sh 004
   └─ 自动验证隔离 → 提示运行命令

3. 在 Claude Code 中运行
   └─ /android-code-review --target file:test-cases/004-new-rule.kt

4. 分析结果
   ├─ ✅ 检测到 → 记录通过
   ├─ ❌ 漏检 → 进入 Phase 2
   └─ ⚠️ 误检 → 进入 Phase 2
```

---

### Phase 2: 改进 Plugin

```
1. 修改检测规则
   └─ 编辑 .claude/agents/android-code-reviewer.md

2. 重启 Claude Code ⚠️
   └─ 必须步骤！让修改生效

3. 重新验证
   └─ ./scripts/run-review.sh 004

4. 迭代直到满意
   └─ 重复 Phase 1-2
```

---

### Phase 3: 真实环境测试

```
1. 验证隔离配置
   └─ ./scripts/verify-isolation.sh

2. 在测试项目中编写代码
   └─ test-android/app/src/main/java/com/test/bugs/...

3. 运行 AI Review
   └─ cd test-android/
   └─ /android-code-review --target file:app/src/main/java/...

4. 验证编译 ✨
   └─ cd ../
   └─ ./scripts/verify-build.sh

5. 分析编译结果
   ├─ ✅ 编译成功 + AI 报告 → 可能误报
   ├─ ❌ 编译失败 + AI 未报告 → 漏检
   └─ ✅ 编译成功 + 无问题 → 验证通过
```

---

### Phase 4: 批量验证

```
1. 运行批量验证脚本
   └─ ./scripts/verify-plugin.sh
   └─ 自动验证隔离 → 逐个测试用例

2. 确认所有测试通过
   ├─ Total: N 个测试
   ├─ Passed: X 个
   └─ Failed: Y 个

3. 如果有失败
   └─ 记录失败的测试
   └─ 修改 plugin
   └─ 重新运行 verify-plugin.sh
```

---

### Phase 5: 发布

```
1. 运行发布脚本
   └─ ./scripts/publish-plugin.sh

2. 脚本自动完成
   ├─ 更新版本号
   ├─ 提交 Git
   ├─ 创建 Tag
   ├─ 推送到远程
   └─ 提示创建 GitHub Release

3. 创建 GitHub Release
   └─ gh release create v1.x.x --notes "..."
```

---

## 📋 日常开发流程（最常见）

### 场景：添加新的检测规则

```bash
# Step 1: 编写测试用例
cat > test-cases/004-new-rule.kt << 'EOF'
// Expected Detection: HIGH
// Category: Memory

class NewTestCase {
    // Bug code
}
EOF

# Step 2: 运行 review
./scripts/run-review.sh 004
# 脚本验证隔离 → 打印提示
# 在 Claude Code 中运行提示的命令

# Step 3: 修改 plugin
# 编辑 .claude/agents/android-code-reviewer.md

# Step 4: 重启 Claude Code
# (让修改生效)

# Step 5: 重新验证
./scripts/run-review.sh 004

# Step 6: (可选) 真实环境测试
./scripts/verify-isolation.sh
cd test-android/
# 编写 bugs/ 中的测试代码
/android-code-review --target file:...
cd ../
./scripts/verify-build.sh

# Step 7: 批量验证
./scripts/verify-plugin.sh

# Step 8: 发布
./scripts/publish-plugin.sh
```

---

## 🎯 不同场景的工作流

### 场景 A: 快速修复单个规则

```bash
./scripts/run-review.sh <test-id>
# 修改 plugin
# 重启 Claude Code
./scripts/run-review.sh <test-id>
# ✓ 完成
```

### 场景 B: 完整功能开发

```bash
# 快速验证
./scripts/run-review.sh <test-id>

# 改进 plugin
# 重启 Claude Code

# 真实环境测试
./scripts/verify-build.sh

# 批量验证
./scripts/verify-plugin.sh

# 发布
./scripts/publish-plugin.sh
```

### 场景 C: 回归测试

```bash
# 只运行批量验证
./scripts/verify-plugin.sh

# 或验证编译
./scripts/verify-build.sh
```

---

## ⚠️ 常见错误和解决方法

### 错误 1: Plugin 修改未生效

**症状：** 修改了 plugin 但测试时还是旧行为

**原因：** Claude Code 缓存了 plugin

**解决：**
```bash
# macOS
Cmd+Q 完全退出 Claude Code，然后重新打开
```

---

### 错误 2: 隔离检查失败

**症状：** `test-android/.claude/ exists and contains files`

**原因：** 测试项目有自己的 plugin 配置

**解决：**
```bash
rm -rf test-android/.claude/
```

---

### 错误 3: 编译失败但 AI 未报告

**症状：** `./scripts/verify-build.sh` 失败，但 AI review 没有检测到问题

**原因：** Plugin 漏检或规则不完善

**解决：**
```bash
# 分析编译错误
cd test-android/
./gradlew assembleDebug --stacktrace

# 将问题添加到 plugin 规则
# 编辑 .claude/agents/android-code-reviewer.md

# 重启 Claude Code
```

---

### 错误 4: AI 报告但编译成功

**症状：** AI 报告问题，但 `./scripts/verify-build.sh` 成功

**原因：** 可能是误报（false positive）

**解决：**
```bash
# 分析是否真的有问题
# 如果代码实际正确，调整 plugin 规则
# 降低严重度或修改检测逻辑
```

---

## 📊 工作流图

```
┌─────────────────────────────────────────┐
│ 开发周期总览                              │
└─────────────────────────────────────────┘
        │
        ├─► 快速测试 (test-cases/)
        │    ├─ run-review.sh
        │    ├─ 修改 plugin
        │    └─ 重启 Claude Code
        │
        ├─► 真实环境测试 (test-android/)
        │    ├─ verify-isolation.sh
        │    ├─ AI Review
        │    ├─ verify-build.sh ⭐
        │    └─ 分析结果
        │
        ├─► 批量验证
        │    ├─ verify-plugin.sh
        │    └─ 所有测试通过？
        │
        └─► 发布
             ├─ publish-plugin.sh
             └─ GitHub Release
```

---

## 🔧 工具和脚本速查

| 脚本 | 用途 | 何时使用 |
|------|------|----------|
| `verify-isolation.sh` | 验证隔离 | 测试前 |
| `verify-build.sh` | 验证编译 | Review 后 |
| `run-review.sh` | 运行单个测试 | 日常开发 |
| `verify-plugin.sh` | 批量验证 | 发布前 |
| `archive-test.sh` | 归档测试用例 | 测试通过后 |
| `publish-plugin.sh` | 发布版本 | 完成开发后 |

---

## 📚 相关文档

- [开发指南](../../DEVELOPMENT.md)
- [设计文档](../../docs/plans/2026-02-27-android-test-project-integration-design.md)
- [脚本文档](../../scripts/README.md)
- [测试项目说明](../../test-android/README.md)

---

**维护者：** daishengda2018
**最后更新：** 2026-02-27
