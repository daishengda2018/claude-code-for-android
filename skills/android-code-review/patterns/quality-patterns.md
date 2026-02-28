# Quality Detection Patterns

> **规则范围**: QUAL-001 到 QUAL-010
> **严重等级**: P1 (HIGH)
> **Token 优化版本**: 1,800 (原始: 3,200)

---

## QUAL-001: 超长函数检测

### 检测模式

**阈值**: 函数体 > 50 行（不含空行和注释）

**识别特征**:
- `fun functionName(...)` 或 `def function(...)` 后紧跟大量代码
- 混合多种职责：网络请求 + UI 更新 + 数据存储
- 多层嵌套逻辑 (if/for/while > 3 层)

**代码异味**:
- 包含 3+ 个不同的抽象层级
- 有多个 `return` 语句
- 有注释说明"步骤 1/2/3"

### 修复建议

1. **提取方法**: → 拆分为多个单一职责的小函数
2. **引入参数对象**: → 使用数据类传递相关参数
3. **策略模式**: → 用不同策略替代复杂条件逻辑

---

## QUAL-002: 超长文件检测

### 检测模式

**阈值**: 单文件 > 800 行（不含空行和注释）

**识别特征**:
- 文件包含多个不相关的类/功能
- 单个类有 > 10 个方法
- 包含多个顶级函数/类

**文件名线索**:
- `Utils.kt`, `Helper.kt`, `Common.kt` → 工具类膨胀
- `Activity.kt`, `Fragment.kt` > 500 行 → UI + 逻辑混合

### 修复建议

1. **拆分类**: → 按职责分离到多个文件
2. **提取适配器**: → RecyclerView 适配器独立文件
3. **工具类拆分**: → 按功能域分组（网络、日期、字符串）

---

## QUAL-003: 深度嵌套检测

### 检测模式

**阈值**: 嵌套层级 > 4

**识别特征**:
```
if (...) {
    for (...) {
        when (...) {
            if (...) {
                // ← 第 4 层，违规
            }
        }
    }
}
```

**代码异味**:
- 多个 `if` 嵌套无 `return` 提前退出
- `if (!condition)` 嵌套在主逻辑内
- 缺少卫语句 (guard clauses)

### 修复建议

1. **卫语句**: → 提前返回，减少嵌套
2. **提取方法**: → 将嵌套逻辑提取为独立函数
3. **三元运算符**: → 简单条件用 `?:` 替代 `if-else`
4. **Sealed 类**: → 用 `when` 表达式替代嵌套 `if`

---

## QUAL-004: 错误处理缺失

### 检测模式

**危险操作**:
- `JSONObject.getString("key")` → 无 `has("key")` 检查
- `list[index]` → 无 `index < list.size` 检查
- `requireNotNull(nullable)` → 无 try-catch
- `Integer.parseInt(str)` → 无 NumberFormatException 处理
- `File(path).readText()` → 无 IOException 处理

**网络操作**:
- `okHttpClient.newCall(request).execute()` → 无失败处理
- `apiService.getData()` → 无 try-catch 或 onError 回调

**空值处理**:
- `!!` 非断言操作符 → NPE 风险
- `lateinit var` 访问前无 `::lateinitVar.isInitialized`

### 修复建议

1. **空安全**: → 使用 `?.let {}` 或 `?:` 提供默认值
2. **Result 类型**: → 用 `Result<T>` 封装可能失败的操作
3. **Try-catch**: → 捕获具体异常，提供用户友好的错误消息
4. **Coroutine**: → `try-catch` 包裹 `suspend` 函数调用

---

## QUAL-005: 内存泄漏检测

### 检测模式

**Context 泄漏**:
- Activity/Service Context 传递到单例 → 静态引用持有
- `lateinit var context: Context` 在单例中 → 长生命周期持有短生命周期

**Handler 泄漏**:
- `private val handler = Handler()` → 非静态内部类持有外部类引用
- `handler.postDelayed(...)` 在 Activity 销毁后仍执行

**Coroutine 泄漏**:
- `GlobalScope.launch` → 不受生命周期控制
- `viewModelScope` 外启动协程 → 无自动取消
- `lifecycleScope` 无 `repeatOnLifecycle` → 可能在后台运行

**监听器泄漏**:
- 匿名监听器未移除 (`setOnClickListener` 但未 `set null`)
- RxJava `CompositeDisposable.dispose()` 未调用
- EventBus 订阅未取消

### 修复建议

1. **Context**: → 使用 `applicationContext` 或 `WeakReference`
2. **Handler**: → 静态内部类 + WeakReference
3. **Coroutine**:
   - Activity/Fragment: `lifecycleScope.launch { repeatOnLifecycle(...) }`
   - ViewModel: `viewModelScope.launch`
   - 避免: `GlobalScope`, `runBlocking`
4. **监听器**: → 在 `onDestroy()` 中清除所有引用

---

## QUAL-006: 调试代码残留

### 棟测模式

**调试日志**:
- `Log.d("TAG", "...")` → 调试日志应在 Release 移除
- `System.out.println(...)` → 控制台输出
- `printStackTrace()` → 堆栈跟踪
- `Toast.makeText` 用于调试 → 临时 UI 调试

**调试代码**:
- 注释掉的代码块 (`/* ... */` 或 `// ...`)
- `TODO()`, `FIXME()` 未关联 issue tracker
- `@Suppress("...")` 压制警告但未说明原因
- `Thread.sleep(...)` → 调试用延迟

**测试代码**:
- `if (BuildConfig.DEBUG)` 块在生产代码中
- 硬编码测试数据 (`val testUser = "test@example.com"`)

### 修复建议

1. **日志**: → Timber 库 + Release 禁用
2. **注释代码**: → 删除或通过 Git 历史恢复
3. **TODO/FIXME**: → 关联 JIRA/GitHub issue
4. **测试代码**: → 移至 `src/test/` 或 `src/androidTest/`

---

## QUAL-007: 测试覆盖不足

### 检测模式

**无测试文件**:
- `src/main/java/com/example/UseCase.kt`
- 缺少 `src/test/java/com/example/UseCaseTest.kt`

**关键逻辑未测试**:
- 复杂算法无单元测试
- 网络层无 Mock 测试
- UI 交互无 Espresso 测试

**Mock 过度**:
- `whitelistEverything()` → Mock 所有依赖
- `any()`, `anyOrNull()` 过度使用 → 测试不验证真实行为

### 修复建议

1. **单元测试**: → 至少 80% 代码覆盖率
2. **分层测试**:
   - Domain 层: 纯 Kotlin 测试 (JUnit)
   - Data 层: Mock 测试 (MockK)
   - UI 层: UI 测试 (Compose UI Test / Espresso)
3. **关键路径**: → 用户核心流程必须有端到端测试

---

## QUAL-008: 死代码检测

### 检测模式

**未使用函数**:
- `private fun` 仅在注释代码中被调用
- `public fun` 在整个项目中无引用

**未使用类**:
- 自定义异常类从未 `throw`
- 工具类函数从未调用

**不可达代码**:
- `return` 语句后的代码
- `if (true) { ... } else { unreachable }`
- `throw Exception()` 后的代码

**过时代码**:
- 注释标记 `@Deprecated` 但未移除
- 特性开关永远为 `false`

### 修复建议

1. **工具扫描**: → Detekt (`UnusedPrivateClass`), Lint
2. **删除**: → 移除所有死代码
3. **重构**: → 提取有用的部分，移除冗余
4. **文档**: → 保留的代码添加 `@Suppress("unused")` + 理由

---

## QUAL-009: 不安全空值访问

### 检测模式

**强制非空断言**:
- `variable!!` → NPE 风险
- `list!![index]` → 双重风险

**平台类型**:
- Java 类型映射为 `String!` → 未声明可空性
- `@Nullable` 注解缺失

**Lateinit 风险**:
- `lateinit var` 访问前未初始化
- 无 `::lateinitVar.isInitialized` 检查

**可空类型转换**:
- `nullable as Type` → 不安全的类型转换
- `nullable as? Type` + 使用 `!!` → 失去安全意义

### 修复建议

1. **安全调用**: → `?.let { }` 代替 `!!`
2. **Elvis**: → `?:` 提供默认值
3. **类型检查**: → `is` 检查后自动转换
4. **Lateinit**: → 改为 `lazy` 委托或可空类型

---

## QUAL-010: 代码可读性

### 检测模式

**命名问题**:
- 单字符变量名 (`a`, `b`, `x`) → 除循环索引外
- 缩写过度 (`usrNm`, `pwd`) → 应为 `userName`, `password`
- 拼写错误 (`recieve` vs `receive`)

**魔法值**:
- 硬编码数字: `if (count > 10)` → 应为常量 `MAX_COUNT`
- 硬编码字符串: `if (type == "premium")` → 应为枚举

**复杂表达式**:
- 超长布尔表达式: `if (a && b || c && !d && e)`
- 嵌套三元: `val x = if (a) b else if (c) d else e`

**注释不足**:
- 复杂算法无注释
- 公共 API 无 KDoc
- "为什么做"未说明（只说"做什么"）

### 修复建议

1. **命名**: → 使用完整、描述性名称
2. **常量**: → 提取魔法值为 `const val`
3. **表达式**: → 提取为有意义的变量/函数
4. **文档**: → 公共 API 必须有 KDoc
5. **注释**: → 解释"为什么"而非"做什么"

---

## 检测优先级

| 规则 | 检测优先级 | 影响 |
|------|-----------|------|
| QUAL-005 | 🔴 最高 | 内存泄漏导致 ANR/崩溃 |
| QUAL-004 | 🔴 最高 | 无错误处理导致崩溃 |
| QUAL-009 | 🟠 高 | NPE 导致崩溃 |
| QUAL-003 | 🟠 高 | 深度嵌套难以维护 |
| QUAL-001 | 🟡 中 | 超长函数降低可维护性 |
| QUAL-002 | 🟡 中 | 超长文件难以导航 |
| QUAL-006 | 🟡 中 | 调试代码影响性能 |
| QUAL-008 | 🟢 低 | 死代码增加包体积 |
| QUAL-007 | 🟢 低 | 测试不足不直接导致崩溃 |
| QUAL-010 | 🟢 低 | 可读性问题不影响功能 |

---

## Token 优化说明

**原始版本**: 3,200 tokens (1,079 行，679 行代码示例 = 62.9%)
**优化版本**: 1,800 tokens (纯检测模式，无冗余代码示例)
**节省**: 44%

**优化策略**:
1. 移除所有 ❌/✅ 代码示例
2. 保留关键检测模式（阈值、特征、代码异味）
3. 用简洁的修复建议替代详细示例
4. 按优先级排序规则
