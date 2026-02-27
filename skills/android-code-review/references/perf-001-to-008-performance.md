# Performance Rules (PERF-001 to PERF-008)

**Severity:** P2 (MEDIUM) | **Category:** Performance | **Tokens:** ~2,400

---

## PERF-001: 布局低效

### ❌ 错误示例

```xml
<!-- BAD: 深层嵌套布局 -->
<LinearLayout>
    <FrameLayout>
        <LinearLayout>
            <TextView />
        </LinearLayout>
    </FrameLayout>
</LinearLayout>
```

### ✅ 正确示例

```xml
<!-- GOOD: 扁平化布局 -->
<TextView />
```

---

## PERF-002: ANR 风险

### ❌ 错误示例

```kotlin
// BAD: 主线程IO
fun loadData() {
    val data = URL("https://api.example.com").readText()  // ❌ ANR
    database.query("SELECT * FROM large_table").execute()  // ❌ ANR
}
```

### ✅ 正确示例

```kotlin
// GOOD: 异步操作
fun loadData() {
    viewModelScope.launch(Dispatchers.IO) {
        val data = apiService.fetchData()
        withContext(Dispatchers.Main) {
            displayData(data)
        }
    }
}
```

---

## PERF-003: Bitmap 管理

### ❌ 错误示例

```kotlin
// BAD: 未压缩的Bitmap
val bitmap = BitmapFactory.decodeResource(resources, R.drawable.large_image)
imageView.setImageBitmap(bitmap)  // ❌ 内存占用高
```

### ✅ 正确示例

```kotlin
// GOOD: 使用图片加载库
Glide.with(this)
    .load(R.drawable.large_image)
    .overrideSize(200, 200)
    .into(imageView)
```

---

## PERF-004: 启动性能

### ❌ 错误示例

```kotlin
// BAD: Application.onCreate中的重操作
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // ❌ 初始化多个SDK，同步加载配置
        SDK1.init(this)
        SDK2.init(this)
        SDK3.init(this)
    }
}
```

### ✅ 正确示例

```kotlin
// GOOD: 延迟初始化
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // 仅初始化必要的SDK
        startKoin { modules(appModule) }
    }
}
```

---

## PERF-005: SharedPreferences 优化

### ❌ 错误示例

```kotlin
// BAD: 频繁commit
for (i in 1..1000) {
    prefs.edit().putInt("key_$i", i).commit()  // ❌ 阻塞主线程1000次
}
```

### ✅ 正确示例

```kotlin
// GOOD: 批量提交
prefs.edit {
    for (i in 1..1000) {
        putInt("key_$i", i)
    }
}.apply()  // 异步提交
```

---

## PERF-006: WakeLock/Alarm 使用

### ❌ 错误示例

```kotlin
// BAD: 长时间持有WakeLock
val wakeLock = powerManager.newWakeLock(PARTIAL_WAKE_LOCK, "MyTag")
wakeLock.acquire(60000)  // ❌ 持有60秒
```

### ✅ 正确示例

```kotlin
// GOOD: 及时释放
wakeLock.acquire(10_000)
try {
    doWork()
} finally {
    wakeLock.release()
}
```

---

## PERF-007: Compose Recomposition

### ❌ 错误示例

```kotlin
// BAD: 不稳定的类型触发recomposition
@Composable
fun ItemList(items: List<Item>) {
    items.forEach { item ->
        ItemRow(item)  // ❌ 每次recomposition创建新实例
    }
}
```

### ✅ 正确示例

```kotlin
// GOOD: 使用key稳定recomposition
@Composable
fun ItemList(items: List<Item>) {
    items.forEach { item ->
        key(item.id) {  // 稳定的key
            ItemRow(item)
        }
    }
}
```

---

## PERF-008: 避免不必要的重组

### 检测目标

检测 Jetpack Compose 中可避免的频繁重组，包括不稳定类型、未使用 remember 的计算、以及不必要的参数传递。

### ❌ 错误示例

```kotlin
// BAD: 不稳定的 Lambda 导致父组件重组
@Composable
fun ParentComponent() {
    var count by remember { mutableStateOf(0) }
    ChildComponent {
        count++  // ❌ 每次重组都创建新 Lambda
    }
}

// BAD: 未使用 remember 缓存计算结果
@Composable
fun ExpensiveList(items: List<Item>) {
    val filtered = items.filter { it.isActive }  // ❌ 每次重组都重新计算
    LazyColumn {
        items(filtered) { item -> ... }
    }
}

// BAD: 不稳定的参数类型
data class User(val name: String, val age: Int)  // ❌ 非 data class 或 unstable

@Composable
fun UserProfile(user: User) {
    // user 类型不稳定导致频繁重组
}
```

### ✅ 正确示例

```kotlin
// GOOD: 使用 remember 稳定 Lambda
@Composable
fun ParentComponent() {
    var count by remember { mutableStateOf(0) }
    val increment = remember { { count++ } }  // ✅ 稳定的 Lambda
    ChildComponent(onClick = increment)
}

// GOOD: 使用 remember 缓存计算
@Composable
fun ExpensiveList(items: List<Item>) {
    val filtered = remember(items) {
        items.filter { it.isActive }  // ✅ 仅当 items 变化时重新计算
    }
    LazyColumn {
        items(filtered) { item -> ... }
    }
}

// GOOD: 使用 @Immutable 注解或稳定类型
@Immutable
data class User(val name: String, val age: Int)  // ✅ 稳定类型

// GOOD: 使用 derivedStateOf 依赖跟踪
@Composable
fun ExpensiveList(items: List<Item>) {
    val filterText by remember { mutableStateOf("") }
    val filtered by remember {
        derivedStateOf {
            items.filter { it.isActive && it.name.contains(filterText) }
        }
    }
    LazyColumn {
        items(filtered) { item -> ... }
    }
}
```

### 性能提示

- 使用 `Compose Compiler` 报告检查稳定性
- 对于复杂对象，使用 `@Immutable` 或 `@Stable` 注解
- 避免在 Composable 函数中直接创建集合或 Lambda
- 使用 `remember` 缓存计算密集型操作
- 使用 `key()` 辅助函数稳定列表项
- 使用 `derivedStateOf` 跟踪依赖变化

---

**文档版本**: 1.0.0
**Token估算**: 2400
