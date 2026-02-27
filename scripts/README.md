# Automation Scripts

Plugin 开发和测试的自动化工具集。

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

**自动调用：** `run-review.sh`, `verify-plugin.sh`

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

### run-review.sh
准备测试环境并提示运行命令。

**用途：** 快速设置和运行单个测试用例的 review。

**使用：**
```bash
./scripts/run-review.sh <test-case-id>
```

**示例：**
```bash
./scripts/run-review.sh 001
./scripts/run-review.sh 002-handler-leak
```

**工作流程：**
1. 自动验证 plugin 隔离
2. 查找指定的测试文件
3. 打印运行提示
4. 用户在 Claude Code 中运行提示的命令

**自动验证：** 调用 `verify-isolation.sh`

---

### verify-plugin.sh
批量验证所有测试用例。

**用途：** 回归测试，确保所有检测规则正常工作。

**使用：**
```bash
./scripts/verify-plugin.sh
```

**工作流程：**
1. 自动验证 plugin 隔离
2. 遍历 `test-cases/` 中的所有测试文件
3. 对每个文件提示用户运行 review
4. 用户确认是否通过
5. 统计通过/失败数量

**自动验证：** 调用 `verify-isolation.sh`

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

## 🔄 典型工作流

### 开发新检测规则

```bash
# 1. 编写测试用例
# 编辑 test-cases/004-new-rule.kt

# 2. 运行 review
./scripts/run-review.sh 004
# → 脚本验证隔离 → 提示运行命令
# → 在 Claude Code 中运行命令

# 3. 修改 plugin
# 编辑 .claude/agents/android-code-reviewer.md

# 4. 重启 Claude Code
# (让修改生效)

# 5. 重新验证
./scripts/run-review.sh 004

# 6. 真实环境测试（可选）
cd test-android/
# 编写 bugs/ 中的代码
/android-code-review --target file:...

# 7. 验证编译
cd ../
./scripts/verify-build.sh

# 8. 批量验证
./scripts/verify-plugin.sh

# 9. 发布
./scripts/publish-plugin.sh
```

### 日常测试

```bash
# 快速验证单个规则
./scripts/run-review.sh 001

# 验证所有规则
./scripts/verify-plugin.sh

# 验证项目编译
./scripts/verify-build.sh
```

### 归档旧测试

```bash
# 测试用例已验证，不再需要日常测试
./scripts/archive-test.sh 001-npe

# 如需恢复用于回归测试
mkdir -p test-android/bugs
cp -r test-android/bugs-archive/2026-02/001-npe test-android/bugs/
```

---

## 🛠️ 脚本依赖关系

```
run-review.sh
  └─> verify-isolation.sh (自动)

verify-plugin.sh
  └─> verify-isolation.sh (自动)

verify-build.sh
  └─> (独立运行)

archive-test.sh
  └─> (独立运行)

publish-plugin.sh
  └─> (独立运行)
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

### run-review.sh 找不到文件

**错误：** `Test case not found: 999`

**解决：**
```bash
# 查看可用的测试用例
ls test-cases/
```

---

## 📚 相关文档

- [开发指南](../DEVELOPMENT.md)
- [设计文档](../docs/plans/2026-02-27-android-test-project-integration-design.md)
- [测试项目说明](../test-android/README.md)

---

**维护者：** daishengda2018
**最后更新：** 2026-02-27
