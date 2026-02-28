# Android Code Review 优化测试指南

## 测试说明

本次优化主要解决了以下噪音问题：
1. ✅ XML 布局文件参与审查
2. ✅ Gradle 版本号被误报为硬编码
3. ✅ 主线程集合并发修改误报
4. ✅ 注释代码误报
5. ✅ 统一阈值导致过高误报率

## 测试用例

### Test 007: XML 文件过滤
**文件**: `test-cases/007-xml-layout.xml`

**测试命令**:
```bash
/android-code-review --target file:test-cases/007-xml-layout.xml
```

**预期结果**:
```
🔍 Filtered files: 1 → 0
No files to review.
```

**验证点**: XML 文件应被自动跳过

---

### Test 008: Gradle 版本号
**文件**: `test-cases/008-gradle-versions.gradle`

**测试命令**:
```bash
/android-code-review --target file:test-cases/008-gradle-versions.gradle
```

**预期结果**:
- ✅ 不应报告 `implementation "androidx.core:core-ktx:1.12.0"` 为硬编码
- ✅ 不应报告 `versionCode 1` 为硬编码
- ⚠️ 仍应报告 `api_key = "sk-proj-xxxxx"` 为硬编码（这是真实密钥格式）

**验证点**: Gradle 依赖版本号和构建配置常量应被允许

---

### Test 009: 主线程并发修改（安全）
**文件**: `test-cases/009-concurrent-main-thread.kt`

**测试命令**:
```bash
/android-code-review --target file:test-cases/009-concurrent-main-thread.kt
```

**预期结果**:
- ✅ 不应报告 ConcurrentModificationException 警告
- 原因：代码在主线程方法中（onCreate, init），无异步上下文

**验证点**: 主线程安全的集合修改应被跳过

---

### Test 010: 异步上下文并发修改（不安全）
**文件**: `test-cases/010-concurrent-async.kt`

**测试命令**:
```bash
/android-code-review --target file:test-cases/010-concurrent-async.kt
```

**预期结果**:
- ⚠️ 应报告 `viewModelScope.launch` 中的并发修改问题
- ⚠️ 应报告有异步上下文证据的并发修改

**验证点**: 异步上下文中的不安全操作应被检测

---

### Test 011: 注释代码和代码质量
**文件**: `test-cases/011-code-quality-comments.kt`

**测试命令**:
```bash
/android-code-review --target file:test-cases/011-code-quality-comments.kt
```

**预期结果**:
- ✅ 不应报告注释代码问题（检测已移除）
- ❓ 长方法警告：取决于 AI 的置信度评分（85% 统一阈值）
  - 可能报告也可能不报告，这是预期的
  - 所有规则类型使用统一的 85% 阈值

**验证点**: 注释代码检测已禁用

---

## 快速批量测试

```bash
# Test all cases
for file in test-cases/007-* test-cases/008-* test-cases/009-* test-cases/010-* test-cases/011-*; do
    echo "=== Testing: $file ==="
    /android-code-review --target file:$file
    echo ""
done
```

---

## 预期效果对比

| 指标 | 优化前 | 优化后 | 改进 |
|------|--------|--------|------|
| XML 文件审查 | 8 files | 0 files | ✅ 100% 减少 |
| Gradle 版本号误报 | ~5 warnings | 0 warnings | ✅ 100% 减少 |
| 并发修改误报 | ~10 warnings | ~2 warnings | ✅ 80% 减少 |
| 注释代码误报 | ~8 warnings | 0 warnings | ✅ 100% 减少 |
| **总体误报率** | **~40%** | **~10-15%** | ✅ **降低 70%** |

---

## 故障排查

### 问题：XML 文件仍被审查

**检查**:
```bash
# Verify command has filtering step
grep -A 5 "Step 1.5" commands/android-code-review.md
```

**预期**: 应看到 XML 过滤逻辑

---

### 问题：Gradle 版本号仍被报错

**检查**:
```bash
# Verify agent has Gradle exception
grep -A 2 "Version numbers in" agents/android-code-reviewer.md
```

**预期**: 应看到 Gradle 版本号例外规则

---

### 问题：主线程并发修改仍被报告

**检查**:
```bash
# Verify agent has async context checking
grep -A 20 "ConcurrentModificationException" agents/android-code-reviewer.md
```

**预期**: 应看到异步上下文检测逻辑

---

### 问题：注释代码仍被报告

**检查**:
```bash
# Verify SKILL.md doesn't have commented code rule
grep "Commented-out code" skills/android-code-review/SKILL.md
```

**预期**: 不应找到此规则（已移除）

---

## 下一步

1. ✅ 代码已提交到 main 分支
2. ⏭️ 运行上述测试用例验证效果
3. ⏭️ 根据实际效果调整阈值（如需要）
4. ⏭️ 更新 CHANGELOG.md
5. ⏭️ 发布 v3.0.2 版本

---

## 设计文档

详细设计见: `docs/plans/2025-02-28-android-code-review-optimization-design.md`
