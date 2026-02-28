# Android Code Review 插件优化设计

**日期**: 2025-02-28
**状态**: 已批准
**方案**: 方案 A - 最小改动方案

## 需求背景

用户反馈 Android 代码审查插件在测试中产生较多噪音，具体问题：

1. **XML 布局文件参与审查** - 主要噪音源
2. **集合并发修改误报** - 单线程场景下提示并发风险
3. **注释代码误报** - 正常注释被误认为恢复旧代码
4. **Gradle 版本号检查** - 依赖版本号被标记为硬编码
5. **可信度阈值单一** - 所有规则使用 80% 阈值，缺乏灵活性

## 方案选择

选择 **方案 A - 最小改动方案**，理由：

- ✅ 快速见效（1-2 小时完成）
- ✅ 保持 v3.0 简化架构
- ✅ 风险最低，容易回滚
- ✅ 不需要恢复 patterns 文件

## 技术设计

### 1. 文件类型过滤器

**位置**: `commands/android-code-review.md`

**实现**: 在 Step 1 (收集文件) 之后添加过滤

```bash
# Step 1.5: Filter files by type
filtered_files=$(echo "$collected_files" | grep -v '\.xml$' | grep -v '^\s*$' | grep -v '^#')
```

**效果**: 跳过所有 `.xml` 文件，只审查源代码文件

---

### 2. Gradle 版本号硬编码例外

**位置**: `agents/android-code-reviewer.md`

**实现**: 在 "Skip" 列表中添加例外规则

```markdown
**Skip** (additional rules for Android):
- ❌ Version numbers in *.gradle / *.gradle.kts files
- ❌ Build configuration constants (versionCode, versionName, etc.)
```

**检测逻辑**:
```kotlin
if (file.endsWith(".gradle") && issue.type == "hardcoded_value") {
    if (isVersionNumber(value)) skip()
}
```

---

### 3. 集合并发修改检测优化

**位置**: `agents/android-code-reviewer.md`

**实现**: 添加异步上下文检查条件

**报告条件** (必须同时满足):
1. ✅ Collection is modified during iteration
2. ✅ Code is in async context:
   - `CoroutineScope` / `lifecycleScope` / `viewModelScope`
   - `Handler` / `Looper` / `ExecutorService` / `Thread`
   - `@WorkerThread` / `@AnyThread` annotation
   - Method name contains: `async`, `background`, `thread`

**跳过条件**:
- ❌ Only simple for/forEach without async context
- ❌ In main thread methods (`onCreate`, `init`)
- ❌ No async keywords in surrounding 50 lines

---

### 4. 注释代码检测优化

**位置**: `agents/android-code-reviewer.md` + `skills/android-code-review/SKILL.md`

**改动 1 - Agent**:
```markdown
# Commented-out Code Detection

## Report Condition
ONLY report in PR context (git diff)

## Skip Condition
Always skip if:
- ❌ Reviewing single file with `--target file:path`
- ❌ Comments contain: "TODO", "FIXME", "HACK", "NOTE"
- ❌ Less than 3 lines of commented code
```

**改动 2 - SKILL.md**:
```markdown
### PR CONTEXT RULES (Diff-Aware)
* Shotgun surgery (>5 files changed for one concern)
* Divergent change (class modified for unrelated reasons)
* ~~Commented-out code blocks~~ → REMOVED
* Debug artifacts left in change
```

---

### 5. 分层可信度阈值系统

**位置**: `agents/android-code-reviewer.md`

**实现**: 将统一 80% 阈值改为分层阈值

| 规则类型 | 阈值 | 示例 |
|---------|------|------|
| 🔴 安全类 | 90% | Hardcoded keys, SQL injection |
| 🟠 架构/生命周期 | 80% | Fragment lifecycle, Memory leaks |
| 🟡 代码质量 | 70% | Long method, High complexity |

**理由**:
- 安全问题误报会导致恐慌，需要高精度
- Android 特定问题模式明确，80% 合适
- 代码质量问题有主观性，允许更多提醒

## 预期效果

| 问题 | 优化前 | 优化后 |
|------|--------|--------|
| XML 文件噪音 | 8 XML files reviewed | 0 XML files |
| Gradle 版本号误报 | ~5 warnings | 0 warnings |
| 集合并发误报 | ~10 warnings | ~2 warnings (only async) |
| 注释代码误报 | ~8 warnings | 0 warnings (single file) |
| 总体误报率 | ~40% | ~10-15% |

## 风险评估

| 风险 | 可能性 | 影响 | 缓解措施 |
|------|--------|------|----------|
| 漏检真实并发问题 | 低 | 中 | 仅在无异步上下文时跳过 |
| 漏检 Gradle 真实硬编码 | 极低 | 低 | 仍检查非版本号的硬编码值 |
| XML 中真实问题被忽略 | 极低 | 极低 | XML 布局文件很少有逻辑错误 |

## 实施计划

下一步：调用 `writing-plans` skill 创建详细实施步骤

## 批准记录

- [x] 需求确认
- [x] 方案选择
- [x] 技术设计确认
- [x] 用户批准所有部分
