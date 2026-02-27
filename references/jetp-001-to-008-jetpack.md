# JETP-001 到 JETP-008: Jetpack/Kotlin 规则检查清单

> **规则ID范围**: JETP-001 到 JETP-008
> **严重等级**: P1 (HIGH)
> **分类**: Jetpack/Kotlin Patterns
> **Token估算**: 3500

---

## JETP-001: 协程误配置

### ❌ 错误示例

```kotlin
// BAD: GlobalScope（内存泄漏）
GlobalScope.launch {
    // 运行即使Activity销毁
}

// BAD: 错误的Dispatcher
viewModelScope.launch(Dispatchers.IO) {
    // ❌ 不应该在IO线程更新UI
    textView.text = "Data"
}
```

### ✅ 正确示例

```kotlin
// GOOD: 生命周期感知
lifecycleScope.launch {
    repeatOnLifecycle(Lifecycle.State.STARTED) {
        val data = withContext(Dispatchers.IO) { fetchData() }
        textView.text = data  // ✅ 主线程更新UI
    }
}
```

---

## JETP-002: 状态管理缺陷

### ❌ 错误示例

```kotlin
// BAD: 未使用repeatOnLifecycle
class MyFragment : Fragment() {
    private val viewModel: MyViewModel by viewModels()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel.data.observe(view) { data ->
            // ❌ Fragment不可见时仍会触发
            updateUI(data)
        }
    }
}
```

### ✅ 正确示例

```kotlin
// GOOD: 使用repeatOnLifecycle
override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    super.onViewCreated(view, savedInstanceState)
    viewLifecycleOwner.lifecycleScope.launch {
        repeatOnLifecycle(Lifecycle.State.STARTED) {
            viewModel.data.collect { data ->
                updateUI(data)
            }
        }
    }
}
```

---

## JETP-003: Room 数据库问题

### ❌ 错误示例

```kotlin
// BAD: N+1查询
@Transaction
suspend fun getUsersWithOrders(): List<User> {
    val users = userDao.getAllUsers()
    users.forEach { user ->
        user.orders = orderDao.getOrdersForUser(user.id)  // ❌ N+1
    }
    return users
}
```

### ✅ 正确示例

```kotlin
// GOOD: 优化JOIN查询
@Transaction
@Query("""
    SELECT * FROM users
    LEFT JOIN orders ON users.id = orders.user_id
""")
suspend fun getUsersWithOrders(): List<UserWithOrders>
```

---

## JETP-004: Hilt/Dagger 错误

### ❌ 错误示例

```kotlin
// BAD: 缺少@Inject
class MyViewModel @Inject constructor() {
    // ❌ 缺少@Inject注解
}
```

### ✅ 正确示例

```kotlin
// GOOD: 正确的Hilt注解
class MyViewModel @Inject constructor(
    private val repository: MyRepository
) : ViewModel()
```

---

## JETP-005: Compose 反模式

### ❌ 错误示例

```kotlin
// BAD: 不必要的recomposition
@Composable
fun BadList(items: List<Item>) {
    items.forEach { item ->
        Row {
            // ❌ 每次recomposition都创建新Lambda
            Text(item.name) { /* TODO */ }
        }
    }
}
```

### ✅ 正确示例

```kotlin
// GOOD: 稳定的Lambda
@Composable
fun GoodList(items: List<Item>) {
    items.forEach { item ->
        val onClick = remember { /* TODO */ }
        Row {
            Text(item.name, onClick = onClick)
        }
    }
}
```

---

## JETP-006: Navigation 错误

### ❌ 错误示例

```kotlin
// BAD: 硬编码导航路由
navController.navigate("product/detail/123")
```

### ✅ 正确示例

```kotlin
// GOOD: 类型安全的导航
val direction = ProductDetailDirections.actionGlobalToDetail(productId = 123)
navController.navigate(direction)
```

---

## JETP-007: WorkManager 误用

### ❌ 错误示例

```kotlin
// BAD: 无限制的后台任务
val workRequest = OneTimeWorkRequestBuilder<SyncWorker>()
    .build()

WorkManager.getInstance(context).enqueue(workRequest)
```

### ✅ 正确示例

```kotlin
// GOOD: 有约束的后台任务
val constraints = Constraints.Builder()
    .setRequiredNetworkType(NetworkType.CONNECTED)
    .setRequiresCharging(true)
    .build()

val workRequest = OneTimeWorkRequestBuilder<SyncWorker>()
    .setConstraints(constraints)
    .setBackoffCriteria(
        BackoffPolicy.LINEAR,
        OneTimeWorkRequest.MIN_BACKOFF_MILLIS,
        OneTimeWorkRequest.MAX_BACKOFF_MILLIS
    )
    .build()
```

---

## JETP-008: Kotlin null safety 违规

### ❌ 错误示例

```kotlin
// BAD: 过度使用!!
fun process(data: String?) {
    val length = data!!.length  // ❌ 可能NPE
}
```

### ✅ 正确示例

```kotlin
// GOOD: 安全的null处理
fun process(data: String?) {
    val length = data?.length ?: 0
}
```

---

**文档版本**: 1.0.0
**Token估算**: 3500
