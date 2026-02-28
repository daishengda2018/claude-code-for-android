# Best Practices Detection Patterns

> **规则范围**: PRAC-001 到 PRAC-008
> **严重等级**: P3 (LOW)
> **Token 优化版本**: 800 (原始: 1,700)

---

## PRAC-001: TODO 未追踪

### 检测模式

**无追踪号的 TODO**:
- `// TODO: 实现错误处理` → 无 issue ticket
- `// FIXME: 优化性能` → 无关联任务
- `// HACK: 临时方案` → 无工单号

### 修复建议

1. **追踪**: → `// TODO: 实现错误处理 (PROJ-456)`
2. **清理**: → 定期清理已完成的 TODO
3. **工单关联**: → 每个 TODO 必须关联 JIRA/GitHub issue

---

## PRAC-002: 文档缺失

### 检测模式

**无 KDoc**:
- `public` 函数无文档注释
- 复杂逻辑无注释解释
- 类用途说明缺失

**文档质量**:
- 文档只说"做什么"不说"为什么"
- 参数说明缺失 (`@param`)
- 返回值说明缺失 (`@return`)

### 修复建议

1. **KDoc**: → 公共 API 必须有 KDoc
2. **注释**: → 解释"为什么"而非"做什么"
3. **示例**: → 复杂 API 提供使用示例

---

## PRAC-003: 命名不规范

### 检测模式

**驼峰命名**:
- `user_name` → 应为 `userName`
- `MAX_COUNT` → Kotlin 中应为 `MAX_COUNT` (const) 或 `maxCount` (val)
- `GetUserName()` → Kotlin 中应为 `getUserName()`

**缩写**:
- `usrNm` → 应为 `userName`
- `pwd` → 应为 `password`
- `btn` → 应为 `button`

**拼写错误**:
- `recieve` → 应为 `receive`
- `occured` → 应为 `occurred`

### 修复建议

1. **驼峰**: → 类名大驼峰 (`UserName`), 变量/函数小驼峰 (`userName`)
2. **全称**: → 避免缩写，使用完整单词
3. **常量**: → `const val MAX_COUNT` (全大写+下划线)

---

## PRAC-004: 魔法值

### 检测模式

**硬编码数字**:
- `if (count > 10)` → 应为 `if (count > MAX_RETRY_COUNT)`
- `Thread.sleep(1000)` → 应为 `Thread.sleep(RETRY_DELAY_MS)`
- `if (age >= 18)` → 应为 `if (age >= ADULT_AGE)`

**硬编码字符串**:
- `if (type == "premium")` → 应为枚举 `if (type == UserType.PREMIUM)`
- `intent.putExtra("key", value)` → 应为常量 `intent.putExtra(EXTRA_KEY, value)`

### 修复建议

1. **常量**: → 提取为 `const val`
2. **枚举**: → 使用 `enum class` 替代魔法字符串
3. **配置**: → 使用资源文件 (`res/values/strings.xml`)

---

## PRAC-005: 格式不一致

### 检测模式

**缩进混乱**:
- 混用空格和 Tab
- 缩进大小不一致 (2 空格 vs 4 空格)

**行长问题**:
- 单行超过 120 字符
- 链式调用无换行

**空行**:
- 连续多个空行
- 函数间无空行分隔

### 修复建议

1. **格式化**: → 使用 ktfmt 或 Spotless 自动格式化
2. **Git Hook**: → Pre-commit hook 自动格式化
3. **配置**: → EditorConfig 统一团队格式

---

## PRAC-006: 异常处理不当

### 检测模式

**捕获所有异常**:
- `try { ... } catch (e: Exception)` → 捕获过于宽泛
- `try { ... } catch (e: Throwable)` → 捕获包括 Error

**吞掉异常**:
- `try { ... } catch (e: Exception) { }` → 空catch块
- `e.printStackTrace()` → 仅打印，不处理

**重试无限制**:
- 无限重试 → 无最大次数限制

### 修复建议

1. **具体异常**: → 捕获具体异常类型 (`IOException`, `SQLException`)
2. **处理**: → 记录日志 + 用户提示 + 恢复/降级
3. **重试**: → 限制最大重试次数 + 指数退避

---

## PRAC-007: 可访问性缺失

### 检测模式

**无描述**:
- `ImageView` 无 `android:contentDescription` → 屏幕阅读器无法描述
- `EditText` 无 `android:hint` → 输入提示缺失
- `ImageButton` 无 `contentDescription` → 按钮用途不明

**可访问性属性**:
- `android:importantForAccessibility="no"` 误用 → 隐藏重要信息
- 无 `android:labelFor` → 输入框与标签未关联

### 修复建议

1. **ImageView**: → 添加 `contentDescription` (纯装饰用 `@null`)
2. **EditText**: → `android:hint` + `android:labelFor`
3. **测试**: → 使用 Talkback 测试可访问性

---

## PRAC-008: 硬编码配置

### 检测模式

**环境硬编码**:
- `const val BASE_URL = "https://api.example.com"` → 环境无法切换
- `const val IS_DEBUG = true` → 发布时忘记关闭

**配置硬编码**:
- 超时时间硬编码 → 无法动态调整
- 特性开关硬编码 → 需要 A/B 测试时无法切换

### 修复建议

1. **BuildConfig**: → 使用 `BuildConfig.DEBUG`, `BuildConfig.Flavor`
2. **gradle.properties**: → 敏感配置通过属性注入
3. **RemoteConfig**: → 使用 Firebase Remote Config 动态配置

---

## 检测优先级

| 规则 | 检测优先级 | 影响 |
|------|-----------|------|
| PRAC-006 | 🟡 中 | 异常处理不当导致崩溃 |
| PRAC-004 | 🟢 低 | 魔法值影响可维护性 |
| PRAC-002 | 🟢 低 | 文档缺失不影响功能 |
| PRAC-003 | 🟢 低 | 命名问题不影响功能 |
| PRAC-001 | 🟢 低 | TODO 未追踪不影响功能 |
| PRAC-005 | 🟢 低 | 格式问题不影响功能 |
| PRAC-007 | 🟢 低 | 可访问性影响部分用户 |
| PRAC-008 | 🟢 低 | 配置硬编码影响灵活性 |

---

## Token 优化说明

**原始版本**: 1,700 tokens (199 行，105 行代码示例 = 52.8%)
**优化版本**: 800 tokens (纯检测模式，无冗余代码示例)
**节省**: 53%
