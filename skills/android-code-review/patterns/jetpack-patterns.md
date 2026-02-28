# Jetpack/Kotlin Detection Patterns

> **规则范围**: JETP-001 到 JETP-008
> **严重等级**: P1 (HIGH)
> **Token 优化版本**: 1,800 (原始: 3,500)

---

## JETP-001: 协程误配置

### 检测模式

**错误作用域**:
- `GlobalScope.launch` → 应用生命周期，泄漏风险
- `CoroutineScope(Dispatchers.Main).launch` → 无生命周期管理

**错误 Dispatcher**:
- `Dispatchers.IO` 中更新 UI (`textView.text = ...`) → 崩溃
- `Dispatchers.Main` 中执行网络请求 → ANR

**无生命周期感知**:
- `viewModelScope` 外使用 `launch` → 无自动取消
- 缺少 `repeatOnLifecycle` → 可能在后台运行

### 修复建议

1. **Activity/Fragment**: → `lifecycleScope.launch { repeatOnLifecycle(STARTED) { ... } }`
2. **ViewModel**: → `viewModelScope.launch { ... }`
3. **线程切换**: → `withContext(Dispatchers.IO) { ... }` 获取数据，主线程更新 UI
4. **避免**: → `GlobalScope`, `runBlocking` (生产代码)

---

## JETP-002: 状态管理缺陷

### 检测模式

**LiveData 问题**:
- `MutableLiveData` 暴露为 public → 外部可修改
- `observe()` 无 `viewLifecycleOwner` (Fragment) → 内存泄漏
- `postValue()` 连续调用 → 只保留最后一个值

**StateFlow 问题**:
- 使用 `MutableStateFlow` 但未暴露为 `StateFlow` → 封装性差
- `.collectIn()` 无 `repeatOnLifecycle` → 生命周期问题

**SharedFlow 问题**:
- `replay = 0` + 无订阅 → 事件丢失
- `shareIn` 配置错误 → 粘性事件问题

### 修复建议

1. **LiveData**: → 私有 `MutableLiveData` + 公开 `LiveData`
2. **Fragment**: → `liveData.observe(viewLifecycleOwner) { ... }`
3. **StateFlow**: → `private val _flow = MutableStateFlow(...)`, `val flow: StateFlow = _flow`
4. **事件**: → 使用 `Channel<Event>` (单次消费) 或 `SharedFlow` (广播)

---

## JETP-003: Room N+1 查询

### 检测模式

**N+1 问题**:
- 查询父列表 → 循环查询每个父的子项 → 1 + N 次查询
- `@Query("SELECT * FROM parent")` + 循环中 `@Query("SELECT * FROM child WHERE parentId = :id")`

**无关系映射**:
- `@Entity` 无 `@Relation` 注解 → 需要手动查询关联数据
- `@ForeignKey` 无 `@Index` → JOIN 查询慢

### 修复建议

1. **@Relation**: → 使用 `@Relation` 一次性加载关联数据
2. **嵌套查询**: → `@Transaction` + `data class` 包含 `List<Child>`
3. **JOIN**: → 使用多表 JOIN 查询替代循环查询
4. **索引**: → 在 `@Entity` 的外键字段上添加 `@Index`

---

## JETP-004: Hilt 依赖注入错误

### 检测模式

**注入问题**:
- `@Inject constructor()` 但无 `@Module` 提供依赖 → 编译错误
- `@ApplicationContext` 混淆 → 应使用 `@ActivityContext` / `@ApplicationContext`

**单例误用**:
- `@Singleton` 注解在非线程安全类 → 并发问题
- `@Singleton` 注解在需要清理的类 → 内存泄漏

**作用域混乱**:
- ViewModel 注入到 Activity → ViewModel 生命周期应短于 Activity
- Activity 作用域注入到单例 → 内存泄漏

### 修复建议

1. **作用域**: → `@Singleton` (应用), `@ActivityScoped` / `@ViewModelScoped`
2. **Context**: → `@ApplicationContext` (长生命周期), `@ActivityContext` (短生命周期)
3. **提供者**: → `@Module` + `@Provides` / `@Binds`
4. **ViewModel**: → 使用 `HiltViewModel` + `@Inject constructor`

---

## JETP-005: Compose 反模式

### 检测模式

**性能问题**:
- Composable 函数中创建对象 → 每次重组创建新对象
- `mutableStateOf` 在 Composable 中 → 重组时丢失状态
- `remember` 缺少 key → 不正确的缓存

**重组问题**:
- 大型 Composable 无 `@stable` 类 → 过度重组
- `LaunchedEffect` key 错误 → 过早/过晚执行
- `SideEffect` 误用 → 应使用 `LaunchedEffect` / `produceState`

**状态提升**:
- 状态在子 Composable 中 → 无法重用
- 无状态提升 → Composable 难以测试

### 修复建议

1. **性能**: → `remember { ... }` 缓存对象, `@Stable` / `@Immutable` 标记类
2. **状态**: → `remember { mutableStateOf(...) }` + `rememberSaveable` (跨重组)
3. **副作用**: → `LaunchedEffect(key) { ... }`, `DisposableEffect(key) { ... }`
4. **状态提升**: → 状态在父 Composable，子 Composable 接收参数

---

## JETP-006: Navigation 组件问题

### 检测模式

**类型安全问题**:
- `navController.navigate("route/$arg")` → 字符串路由易出错
- 无类型安全的导航封装

**深度链接问题**:
- `navGraph` 的 `deepLink` 无验证 → 任意应用可启动
- 深度链接参数未验证 → 注入攻击风险

**返回栈问题**:
- `navigate()` 无 `popUpTo` → 返回栈无限增长
- 导航后无法返回 → 用户体验差

### 修复建议

1. **类型安全**: → 使用 Safe Args 插件 或封装路由函数
2. **深度链接**: → 验证所有参数，使用 `NavController.handleDeepLink`
3. **返回栈**: → `navController.navigate(..., popUpTo = ...)` 管理返回栈

---

## JETP-007: DataStore 问题

### 检测模式

**协程问题**:
- `DataStore.data` 在 `runBlocking` 中 → ANR 风险
- `DataStore.edit` 无 `collect` → 数据可能不一致

**同步问题**:
- 多个进程同时写入 DataStore → 数据损坏风险
- 无事务保证 → 并发写入丢失

**迁移问题**:
- SharedPreferences 迁移未完成 → 数据丢失

### 修复建议

1. **异步**: → 使用 `Flow.collect` 或 `first()` 读取
2. **写入**: → 使用 `DataStore.edit { ... }` 自动处理并发
3. **进程**: → 单进程使用 `DataStore`, 多进程使用 `DataStoreFile`
4. **迁移**: → `SharedPreferences` 迁移到 `DataStore` 使用 `migrate` 函数

---

## JETP-008: WorkManager 问题

### 检测模式

**配置问题**:
- `OneTimeWorkRequestBuilder` 无约束 → 立即执行（可能不是预期）
- `PeriodicWorkRequest` 间隔 < 15 分钟 → 无效（系统限制）

**取消问题**:
- `workManager.cancelAllWork()` → 取消所有任务
- 无任务 ID 无法取消 → 无法管理任务

**重试问题**:
- `BackoffPolicy.LINEAR` + 短间隔 → 重试风暴
- 无最大重试次数 → 无限重试

### 修复建议

1. **约束**: → `Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED)`
2. **取消**: → 使用 `workManager.cancelWorkById(uuid)`
3. **重试**: → `setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 30, TimeUnit.SECONDS)`
4. **唯一任务**: → `enqueueUniqueWork(..., ExistingWorkPolicy.REPLACE, ...)`

---

## 检测优先级

| 规则 | 检测优先级 | 影响 |
|------|-----------|------|
| JETP-001 | 🔴 最高 | 协程误用导致泄漏/ANR |
| JETP-002 | 🟠 高 | 状态管理问题导致 UI 不更新 |
| JETP-005 | 🟠 高 | Compose 性能问题导致卡顿 |
| JETP-003 | 🟡 中 | N+1 查询导致性能问题 |
| JETP-004 | 🟡 中 | 依赖注入错误导致运行时崩溃 |
| JETP-006 | 🟡 中 | Navigation 问题导致用户体验差 |
| JETP-007 | 🟢 低 | DataStore 问题不直接崩溃 |
| JETP-008 | 🟢 低 | WorkManager 问题影响后台任务 |

---

## Token 优化说明

**原始版本**: 3,500 tokens (240 行，148 行代码示例 = 61.7%)
**优化版本**: 1,800 tokens (纯检测模式，无冗余代码示例)
**节省**: 49%
