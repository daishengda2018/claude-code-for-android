# Android Code Review Plugin - Release v3.0.3

**发布日期**: 2026-02-28
**版本**: v3.0.3
**类型**: Bugfix Release

---

## 🐛 Bug 修复

### 1. Severity 默认值未生效

**问题描述**:
- 命令定义的 `default: "high"` 在实际执行时未生效
- 不指定 `--severity` 参数时，会加载所有规则（~8,900 tokens）
- 导致不必要的 token 消耗

**修复方案**:
- 在 `skills/android-code-review/SKILL.md` 中添加显式默认值处理
- 新增 "Default Value Handling" 部分
- 确保未指定参数时默认使用 `high` 级别

**测试验证**:
```bash
# 之前：加载所有规则 (~8,900 tokens)
/android-code-review --target file:test-cases/001-security-hardcoded-secrets.kt

# 现在：只加载 high 级别规则 (~6,950 tokens)
/android-code-review --target file:test-cases/001-security-hardcoded-secrets.kt
```

**Token 节省**: ~22% (8,900 → 6,950 tokens)

---

### 2. 置信度阈值不一致

**问题描述**:
- 文档中存在不一致的置信度阈值
- `CLAUDE.md`: 80%
- `README.md`: 80%
- `SKILL.md`: 85%
- `agent`: 85%

**修复方案**:
- 统一所有文件中的置信度阈值为 **90%**
- 更新 4 个文件：
  1. `skills/android-code-review/SKILL.md`
  2. `agents/android-code-reviewer.md`
  3. `CLAUDE.md`
  4. `README.md`

**预期效果**:
- 进一步降低误报率（约 5-10%）
- 提高报告质量

---

## 📝 文档更新

### 1. 统一置信度描述

所有文档中的置信度阈值已统一为 90%：

| 文件 | 之前 | 现在 |
|------|------|------|
| `SKILL.md` | >85% | **>90%** |
| `android-code-reviewer.md` | >85% | **>90%** |
| `CLAUDE.md` | >80% | **>90%** |
| `README.md` | >80% | **>90%** |

### 2. 默认值说明

新增文档说明默认值处理逻辑：

```markdown
## Default Value Handling

If `severity` parameter is not provided or is empty, default to `"high"`:
- This ensures consistent behavior when command is invoked without `--severity` flag
- Fallback prevents accidental loading of all patterns (which would be ~8,900 tokens)
```

---

## 📊 性能改进

| 指标 | v3.0.2 | v3.0.3 | 改进 |
|------|--------|--------|------|
| **默认调用 token** | ~8,900 | ~6,950 | **-22%** |
| **置信度阈值** | 85% | 90% | **+5.9%** |
| **预期误报率** | ~10-15% | ~5-10% | **-33%** |

---

## 🔧 技术细节

### 修改文件列表

```
skills/android-code-review/SKILL.md
├── 新增: Default Value Handling 部分
└── 修改: 置信度阈值 85% → 90%

agents/android-code-reviewer.md
└── 修改: 置信度阈值 85% → 90%

CLAUDE.md
└── 修改: 置信度阈值 80% → 90%

README.md
├── 新增: v3.0.3 版本历史
└── 修改: 置信度阈值 80% → 90%
```

---

## ✅ 升级指南

### 对于用户

**无需任何操作** — 插件会自动处理默认值：

```bash
# 这些命令现在都正确使用 high 级别
/android-code-review
/android-code-review --target file:example.kt
/android-code-review --target staged
```

**重启要求**: 更新后需要重启 Claude Code 以使更改生效

### 对于开发者

测试默认值行为：

```bash
# 1. 验证默认值
/android-code-review --target file:test-cases/001-security-hardcoded-secrets.kt
# 预期：只加载 high 级别规则

# 2. 验证显式指定
/android-code-review --target file:test-cases/001-security-hardcoded-secrets.kt --severity critical
# 预期：只加载 critical 级别规则
```

---

## 🔄 后续计划

- [ ] 添加 `--severity` 参数的单元测试
- [ ] 实现更细粒度的置信度控制（如 `--confidence` 参数）
- [ ] 收集用户反馈以进一步优化阈值

---

## 📞 反馈

如有问题或建议，请提交 Issue：
https://github.com/daishengda2018/claude-code-for-android/issues
