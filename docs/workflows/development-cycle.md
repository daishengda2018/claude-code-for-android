# Plugin Development Cycle Workflow

完整的 plugin 开发周期工作流程。

> **重要说明：** 这些脚本专注于环境准备和验证。AI code review 必须在 Claude Code 中手动运行。

## 🔄 完整开发周期

### Phase 1: 快速验证（独立测试文件）

```
1. 编写测试用例
   └─ test-cases/004-new-rule.kt

2. 运行 AI Review
   └─ /android-code-review --target file:test-cases/004-new-rule.kt

3. 分析结果
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
   └─ /android-code-review --target file:test-cases/004-new-rule.kt

4. 迭代直到满意
   └─ 重复 Phase 1-2
```

---

### Phase 3: 真实环境测试

```
1. 验证隔离配置（可选）
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
1. 手动运行所有测试用例
   └─ for file in test-cases/*.kt; do
        /android-code-review --target file:$file
      done

2. 确认所有测试通过
   ├─ Total: N 个测试
   ├─ Passed: X 个
   └─ Failed: Y 个
```

---

### Phase 5: 发布更新

```
1. 运行发布脚本
   └─ ./scripts/publish-plugin.sh

2. 脚本自动完成
   ├─ 更新版本号
   ├─ 提交更改
   ├─ 创建 git tag
   ├─ 推送到远程
   └─ 提示创建 GitHub release
```

---

## 🛠️ 可用脚本

### verify-isolation.sh
验证 plugin 隔离配置（可选，测试前检查）。

### verify-build.sh
验证测试项目能否编译（发现误报）。

### archive-test.sh
归档已验证的测试用例。

### publish-plugin.sh
发布新版本。

---

## 📋 不同场景的工作流

### 场景 A: 快速修复单个规则

```bash
# 1. 编辑测试用例
vim test-cases/004-new-rule.kt

# 2. 运行 review
/android-code-review --target file:test-cases/004-new-rule.kt

# 3. 如果没检测到，编辑 plugin
vim .claude/agents/android-code-reviewer.md

# 4. 重启 Claude Code

# 5. 重新验证
/android-code-review --target file:test-cases/004-new-rule.kt

# 6. 完成后提交
git add . && git commit -m "feat: Add detection for XXX"
```

### 场景 B: 完整功能开发

```bash
# 1. 编写多个测试用例
vim test-cases/004-xxx.kt
vim test-cases/005-yyy.kt

# 2. 运行所有测试
for file in test-cases/0*.kt; do
    /android-code-review --target file:$file
done

# 3. 改进 plugin
vim .claude/agents/android-code-reviewer.md

# 4. 重启 Claude Code

# 5. 真实环境测试
cd test-android/
vim app/src/main/java/com/test/bugs/...
/android-code-review --target file:app/src/main/java/...
cd ../
./scripts/verify-build.sh

# 6. 批量验证所有现有测试
for file in test-cases/*.kt; do
    /android-code-review --target file:$file
done

# 7. 发布
./scripts/publish-plugin.sh
```

### 场景 C: 回归测试

```bash
# 验证所有现有规则仍然有效
for file in test-cases/*.kt; do
    echo "Testing: $file"
    /android-code-review --target file:$file
done

# 如果有失败的，修复后重新测试
```

---

## ⚠️ 常见错误

### 错误 1: Plugin 修改后没有生效

**症状：** 修改了 `.claude/agents/android-code-reviewer.md`，但 AI 检测结果没变化。

**原因：** Claude Code 启动时加载 plugin，修改后需要重启。

**解决：**
```bash
# Quit Claude Code completely and reopen
```

---

### 错误 2: 检测到了但编译失败

**症状：** AI 报告有错误，但代码是故意写的 bug。

**原因：** 这是测试用例，代码本来就有问题。

**解决：**
- 如果是测试用例，不需要验证编译
- 如果要验证检测是否正确，用 bug-free 代码测试

---

### 错误 3: 隔离配置错误

**症状：** 修改 plugin 后没有生效。

**原因：** `test-android/.claude/` 存在并覆盖了开发版本。

**解决：**
```bash
./scripts/verify-isolation.sh
# 如果失败，删除目录
rm -rf test-android/.claude/
```

---

## 📊 工作流图

```
┌─────────────────────────────────────────┐
│ 开发周期总览                              │
└─────────────────────────────────────────┘
        │
        ├─► 快速测试 (test-cases/)
        │    ├─ /android-code-review --target file:...
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
        │    ├─ 手动运行所有测试
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
| `verify-isolation.sh` | 验证隔离 | 测试前（可选） |
| `verify-build.sh` | 验证编译 | Review 后 |
| `archive-test.sh` | 归档测试用例 | 测试通过后 |
| `publish-plugin.sh` | 发布版本 | 完成开发后 |

---

## 📊 测试覆盖率目标

| 类别 | 当前 | 目标 |
|------|------|------|
| Security | - | 10+ cases |
| Memory | - | 8+ cases |
| Performance | - | 5+ cases |
| Architecture | - | 5+ cases |
| Quality | - | 10+ cases |

---

## 📚 相关文档

- [开发指南](../../DEVELOPMENT.md)
- [脚本说明](../../scripts/README.md)
- [设计文档](../plans/2026-02-27-android-test-project-integration-design.md)

---

**维护者：** daishengda2018
**最后更新：** 2026-02-27
