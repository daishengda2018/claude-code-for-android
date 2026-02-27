# Automation Scripts

Plugin 开发和测试的自动化工具集。

> **注意：** 这些脚本专注于环境准备和验证，不包含 AI code review 的调用。
>
> 要运行 AI code review，请在 Claude Code 中直接使用命令：
> ```
> /android-code-review --target file:<path-to-file>
> ```

## 📋 Scripts Overview

### verify-isolation.sh
验证 plugin 隔离配置。

**用途：** 确保 `test-android/.claude/` 不存在或为空，使开发版本 plugin 被加载。

**使用：**
```bash
./scripts/verify-isolation.sh
```

**输出：**
- ✅ 通过 → `Plugin isolation OK`
- ❌ 失败 → 错误信息和修复命令

**Quiet 模式：**
```bash
./scripts/verify-isolation.sh --quiet
# 只返回退出码，不输出（用于脚本集成）
```

---

### verify-build.sh
验证测试 Android 项目能否编译通过。

**用途：**
- 验证代码在 AI review 后仍能编译
- 检测 plugin 误报（plugin 说有问题，但代码可编译）
- 减少 AI token 消耗（脚本运行 Gradle，不用 AI）

**使用：**
```bash
./scripts/verify-build.sh
```

**工作流程：**
```
AI Review → 修复代码 → verify-build.sh → 编译成功 ✅
```

**输出：**
- ✅ 成功 → `Build SUCCESS`
- ❌ 失败 → 构建错误和可能原因

**特性：**
- 自动检测 Gradle wrapper
- 支持系统 gradle 作为后备
- 清晰的成功/失败消息

---

### archive-test.sh
归档已验证的测试用例。

**用途：** 将不再需要日常测试的用例移至归档目录。

**使用：**
```bash
./scripts/archive-test.sh <test-id>
```

**示例：**
```bash
./scripts/archive-test.sh 001-npe
./scripts/archive-test.sh 002-handler-leak
```

**归档位置：**
```
test-android/bugs-archive/
└── 2026-02/
    ├── 001-npe/
    └── 002-handler-leak/
```

**何时归档：**
- ✅ 测试用例已验证（plugin 正确检测）
- ✅ 被 bug-free 代码覆盖
- ✅ 不再需要日常回归测试

---

### publish-plugin.sh
发布新版本。

**用途：** 自动化版本发布流程。

**使用：**
```bash
./scripts/publish-plugin.sh
```

**工作流程：**
1. 显示当前版本号
2. 提示输入新版本号
3. 更新所有配置文件
4. 提交更改
5. 创建 git tag
6. 推送到远程
7. 提示创建 GitHub release

**交互式：** 会询问版本号和确认

---

## 🔄 手动测试工作流

### 单个测试用例测试

```bash
# 1. 验证 plugin 隔离（可选，脚本会自动检查）
./scripts/verify-isolation.sh

# 2. 在 Claude Code 中运行 AI review
# /android-code-review --target file:test-cases/001-security-hardcoded-secrets.kt

# 3. 查看检测结果，如果不通过：
#    - 编辑 .claude/agents/android-code-reviewer.md
#    - 重启 Claude Code
#    - 重新运行步骤 2

# 4. 真实环境测试（可选）
cd test-android/
# 编写/修改 bugs/ 中的代码
# /android-code-review --target file:app/src/main/java/com/test/bugs/...

# 5. 验证编译
cd ../
./scripts/verify-build.sh
```

### 批量回归测试

```bash
# 手动对每个 test-cases/*.kt 运行 review
for file in test-cases/*.kt; do
    echo "Testing: $file"
    # /android-code-review --target file:$file
done
```

---

## 🛠️ 脚本依赖关系

```
verify-build.sh
  └─> (独立运行)

archive-test.sh
  └─> (独立运行)

publish-plugin.sh
  └─> (独立运行)

verify-isolation.sh
  └─> (独立运行，或被其他脚本调用)
```

---

## 📝 Exit Codes

所有脚本遵循标准 exit code 规范：

- `0` - 成功
- `1` - 失败（错误、验证失败等）

可以在 shell 脚本中使用：

```bash
if ./scripts/verify-isolation.sh --quiet; then
  echo "Isolation OK"
else
  echo "Isolation failed"
  exit 1
fi
```

---

## 🔧 故障排除

### verify-isolation.sh 失败

**错误：** `test-android/.claude/ exists and contains files`

**解决：**
```bash
rm -rf test-android/.claude/
```

---

### verify-build.sh 失败

**错误：** `Build FAILED`

**可能原因：**
1. 代码有实际错误（plugin 检测正确）
2. 代码有故意的 bug（测试用例）
3. Gradle 配置问题

**排查：**
```bash
cd test-android/
./gradlew assembleDebug --stacktrace
```

---

## 📚 相关文档

- [开发指南](../DEVELOPMENT.md)
- [设计文档](../docs/plans/2026-02-27-android-test-project-integration-design.md)
- [测试项目说明](../test-android/README.md)

---

**维护者：** daishengda2018
**最后更新：** 2026-02-27
