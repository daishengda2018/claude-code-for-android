# Code Quality Rules (QUAL-001 to QUAL-010)

**Severity:** P1 (HIGH) | **Category:** Code Quality | **Tokens:** ~3,200

## Rules Overview

Long functions, deep nesting, error handling, memory leaks, dead code.

---

## QUAL-001: 超长函数检测

### 检测目标

检测超过 50 行的函数，需要拆分为更小的单一职责函数。

### 风险场景

**HIGH**: 超长函数难以理解、测试和维护，容易隐藏 bug：
- 逻辑混乱，难以追踪执行路径
- 难以编写单元测试
- 代码复用性差
- 违反单一职责原则

### 代码模式

#### ❌ 错误示例

```kotlin
// BAD: 120行的超长函数
class ProductListActivity : AppCompatActivity() {
    private fun loadProductData() {
        // 1. 加载配置 (10 lines)
        val config = loadConfig()
        val apiEndpoint = config.endpoint
        val timeout = config.timeout

        // 2. 初始化视图 (15 lines)
        val progressBar = findViewById<ProgressBar>(R.id.progress)
        val recyclerView = findViewById<RecyclerView>(R.id.recycler_view)
        progressBar.visibility = View.VISIBLE

        // 3. 构建请求 (20 lines)
        val request = Request.Builder()
            .url(apiEndpoint)
            .addHeader("Authorization", "Bearer $token")
            .addHeader("Content-Type", "application/json")
            .post(RequestBody.create(
                MediaType.parse("application/json"),
                Gson().toJson(requestBody)
            ))
            .build()

        // 4. 发送网络请求 (30 lines)
        okHttpClient.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                runOnUiThread {
                    progressBar.visibility = View.GONE
                    Toast.makeText(this@ProductListActivity, "Failed", Toast.LENGTH_SHORT).show()
                }
            }

            override fun onResponse(call: Call, response: Response) {
                val body = response.body()?.string()
                val products = Gson().fromJson(body, Array<Product>::class.java)

                runOnUiThread {
                    // 5. 更新UI (25 lines)
                    progressBar.visibility = View.GONE
                    recyclerView.adapter = ProductAdapter(products.toList())

                    // 6. 保存到缓存 (15 lines)
                    val prefs = getSharedPreferences("cache", MODE_PRIVATE)
                    prefs.edit().putString("products", body).apply()

                    // 7. 记录分析 (5 lines)
                    analytics.logEvent("products_loaded", mapOf("count" to products.size))
                }
            }
        })
    }
}
```

#### ✅ 正确示例

```kotlin
// GOOD: 拆分为多个单一职责函数
class ProductListActivity : AppCompatActivity() {

    private fun loadProductData() {
        showLoading()
        val request = buildProductRequest()
        fetchProducts(request)
    }

    private fun showLoading() {
        progressBar.visibility = View.VISIBLE
    }

    private fun buildProductRequest(): Request {
        val config = loadConfig()
        return Request.Builder()
            .url(config.endpoint)
            .post(createRequestBody())
            .build()
    }

    private fun fetchProducts(request: Request) {
        okHttpClient.newCall(request).enqueue(ProductCallback(this))
    }

    private inner class ProductCallback(
        private val activity: ProductListActivity
    ) : Callback {

        override fun onFailure(call: Call, e: IOException) {
            activity.handleFetchError(e)
        }

        override fun onResponse(call: Call, response: Response) {
            val products = parseResponse(response)
            activity.runOnUiThread {
                activity.displayProducts(products)
            }
        }
    }
}
```

### 检测要点

1. **行数检查**
   - 函数体（含签名）超过 50 行
   - 不计空行和注释

2. **职责分析**
   - 函数是否执行多个不相关的操作
   - 是否混合不同抽象层次（UI、业务逻辑、数据访问）

3. **复杂度分析**
   - 圈复杂度是否过高（>10）
   - 是否有深层嵌套

### 置信度计算

```
confidence = 行数得分 × 0.5 + 复杂度得分 × 0.3 + 职责得分 × 0.2
```

### 修复建议

1. **立即修复**
   - 拆分超长函数为多个小函数
   - 每个函数只做一件事
   - 函数名应清晰表达其职责

2. **长期优化**
   - 提取业务逻辑到 UseCase/ViewModel
   - 数据访问移到 Repository
   - UI 逻辑拆分到辅助方法

---

## QUAL-002: 超长文件检测

### 检测目标

检测超过 800 行的文件，需要提取逻辑到独立组件。

### 风险场景

**HIGH**: 超长文件通常表明：
- 单一类承担过多职责
- 难以维护和测试
- 违反模块化原则
- 编译速度慢

### 代码模式

#### ❌ 错误示例

```kotlin
// BAD: 1200行的Activity
class MainActivity : AppCompatActivity() {

    // 1. 成员变量 (100 lines)
    private var user: User? = null
    private val products = mutableListOf<Product>()
    // ... 98 more lines

    // 2. UI初始化 (200 lines)
    private fun setupViews() { ... }
    private fun setupRecyclerView() { ... }
    private fun setupToolbar() { ... }
    // ... 197 more lines

    // 3. 网络请求 (150 lines)
    private fun fetchUserData() { ... }
    private fun fetchProducts() { ... }
    private fun fetchOrders() { ... }
    // ... 147 more lines

    // 4. 业务逻辑 (250 lines)
    private fun calculateTotal() { ... }
    private fun applyDiscount() { ... }
    private fun validateCart() { ... }
    // ... 247 more lines

    // 5. 事件处理 (200 lines)
    override fun onClick(view: View) { ... }
    private fun handleAddToCart() { ... }
    // ... 197 more lines

    // 6. 生命周期管理 (100 lines)
    override fun onCreate(savedInstanceState: Bundle?) { ... }
    override fun onResume() { ... }
    // ... 97 more lines

    // 7. 工具方法 (200 lines)
    private fun formatPrice(price: Double): String { ... }
    private fun showLoadingDialog(): Dialog { ... }
    // ... 197 more lines
}
```

#### ✅ 正确示例

```kotlin
// GOOD: 拆分为多个职责清晰的组件

// MainActivity.kt (100 lines)
class MainActivity : AppCompatActivity() {
    private val viewModel: MainViewModel by viewModels()
    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        setupViews()
        observeViewModel()
    }

    private fun setupViews() {
        binding.recyclerView.layoutManager = LinearLayoutManager(this)
        binding.recyclerView.adapter = ProductAdapter()
    }

    private fun observeViewModel() {
        viewModel.products.observe(this) { products ->
            (binding.recyclerView.adapter as ProductAdapter).submitList(products)
        }
        viewModel.isLoading.observe(this) { isLoading ->
            binding.progressBar.visibility = if (isLoading) View.VISIBLE else View.GONE
        }
    }
}

// MainViewModel.kt (150 lines)
class MainViewModel(
    private val productRepository: ProductRepository,
    private val cartRepository: CartRepository
) : ViewModel() {
    private val _products = MutableLiveData<List<Product>>()
    val products: LiveData<List<Product>> = _products

    private val _isLoading = MutableLiveData<Boolean>()
    val isLoading: LiveData<Boolean> = _isLoading

    fun loadProducts() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                val products = productRepository.getProducts()
                _products.value = products
            } finally {
                _isLoading.value = false
            }
        }
    }
}

// ProductRepository.kt (80 lines)
class ProductRepository(
    private val apiService: ApiService,
    private val cache: ProductCache
) {
    suspend fun getProducts(): List<Product> {
        val cached = cache.getProducts()
        if (cached != null) return cached

        val products = apiService.fetchProducts()
        cache.saveProducts(products)
        return products
    }
}

// PriceFormatter.kt (30 lines)
object PriceFormatter {
    fun format(price: Double): String {
        return NumberFormat.getCurrencyInstance(Locale.CHINA)
            .format(price)
    }
}

// LoadingDialogHelper.kt (40 lines)
class LoadingDialogHelper(private val context: Context) {
    fun show(): Dialog {
        return AlertDialog.Builder(context)
            .setView(R.layout.dialog_loading)
            .setCancelable(false)
            .create()
    }
}
```

### 检测要点

1. **文件行数检查**
   - Kotlin/Java 文件超过 800 行
   - XML 文件超过 500 行

2. **职责分析**
   - 类是否承担过多职责
   - 是否包含多个不相关的功能模块

3. **内聚性分析**
   - 方法之间的关联性
   - 是否可以按功能分组拆分

### 修复建议

1. **立即修复**
   - 按职责拆分为多个类
   - 每个类不超过 3 个主要职责

2. **拆分策略**
   - Activity/Fragment → 仅负责 UI 逻辑
   - ViewModel → 业务逻辑
   - Repository → 数据访问
   - UseCase → 业务用例
   - Helper/Util → 工具方法

---

## QUAL-003: 深度嵌套检测

### 检测目标

检测超过 4 层的嵌套，导致代码可读性差、逻辑复杂。

### 风险场景

**HIGH**: 深度嵌套的问题：
- 认知负担过重，难以理解
- 容易出现 bug
- 难以测试
- 违反"早返回"原则

### 代码模式

#### ❌ 错误示例

```kotlin
// BAD: 6层嵌套
fun processOrder(orderId: String?) {
    if (orderId != null) {  // Level 1
        val order = database.getOrder(orderId)
        if (order != null) {  // Level 2
            if (order.status == Status.PENDING) {  // Level 3
                if (order.items.isNotEmpty()) {  // Level 4
                    for (item in order.items) {  // Level 5
                        if (item.stock > 0) {  // Level 6
                            shipItem(item)
                        }
                    }
                }
            }
        }
    }
}
```

#### ✅ 正确示例

```kotlin
// GOOD: 使用早返回，扁平化结构
fun processOrder(orderId: String?) {
    val safeOrderId = orderId ?: return
    val order = database.getOrder(safeOrderId) ?: return

    if (order.status != Status.PENDING) return
    if (order.items.isEmpty()) return

    order.items.forEach { item ->
        if (item.stock > 0) {
            shipItem(item)
        }
    }
}
```

### 检测要点

1. **嵌套层级计算**
   - `if` 嵌套深度
   - `for/while` 循环嵌套深度
   - `try-catch` 嵌套深度

2. **复杂度分析**
   - 圈复杂度
   - 嵌套的循环

### 修复建议

1. **早返回模式**
   ```kotlin
   // 使用 ?: return 提前退出
   val value = nullableValue ?: return

   // 使用 takeIf 等函数式风格
   list.takeIf { it.isNotEmpty() }?.forEach { ... }
   ```

2. **提取方法**
   ```kotlin
   // 将嵌套逻辑提取为独立方法
   fun processOrder(order: Order) {
       if (isValidOrder(order)) {
           processOrderItems(order.items)
       }
   }

   private fun processOrderItems(items: List<Item>) {
       items.forEach { item ->
           if (item.stock > 0) {
               shipItem(item)
           }
       }
   }
   ```

---

## QUAL-004: 错误处理缺失

### 检测目标

检测空的 catch 块、未处理的异常、无降级方案。

### 代码模式

#### ❌ 错误示例

```kotlin
// BAD: 空catch块
fun loadUserData(userId: String) {
    try {
        val data = apiService.getUser(userId)
        updateUI(data)
    } catch (e: Exception) {
        // 静默失败，用户不知道发生了什么
    }
}

// BAD: 未处理特定异常
fun saveToFile(data: String, fileName: String) {
    val file = File(filesDir, fileName)
    file.writeText(data)  // 可能抛出 IOException
}

// BAD: 无降级UI
fun fetchFromNetwork(url: String) {
    lifecycleScope.launch {
        try {
            val data = apiService.fetch(url)
            displayData(data)
        } catch (e: HttpException) {
            // 直接崩溃或无用户反馈
        }
    }
}
```

#### ✅ 正确示例

```kotlin
// GOOD: 完整的错误处理
fun loadUserData(userId: String) {
    viewModelScope.launch {
        try {
            val data = apiService.getUser(userId)
            _userData.value = data
        } catch (e: HttpException) {
            when (e.code()) {
                401 -> _error.value = Error.Unauthorized
                404 -> _error.value = Error.NotFound
                else -> _error.value = Error.NetworkError(e.message)
            }
        } catch (e: IOException) {
            _error.value = Error.NoConnection
        } catch (e: Exception) {
            _error.value = Error.Unknown(e)
        }
    }
}

// GOOD: 使用 Result 类型
suspend fun saveToFile(data: String, fileName: String): Result<Unit> {
    return try {
        val file = File(filesDir, fileName)
        file.writeText(data)
        Result.success(Unit)
    } catch (e: IOException) {
        Result.failure(e)
    }
}

// 调用方
saveToFile(data, "user.json")
    .onFailure { error ->
        showError("保存失败: ${error.message}")
    }
```

### 检测要点

1. **空catch块检测**
   - `catch (e: Exception) { }`
   - `catch (e: Exception) { // empty }`

2. **泛型异常捕获**
   - `catch (e: Exception)` 过于宽泛
   - 应捕获具体异常类型

3. **未处理异常**
   - 可能抛出异常的代码无 try-catch
   - 文件IO、网络请求、数据库操作

### 修复建议

1. **使用 Result 类型**
   ```kotlin
   fun divide(a: Int, b: Int): Result<Int> {
       return if (b == 0) {
           Result.failure(IllegalArgumentException("Division by zero"))
       } else {
           Result.success(a / b)
       }
   }
   ```

2. **使用 sealed class 定义错误**
   ```kotlin
   sealed class AppError {
       data class NetworkError(val message: String?) : AppError()
       data class ValidationError(val field: String) : AppError()
       data class Unauthorized(val message: String) : AppError()
   }
   ```

---

## QUAL-005: 内存泄漏检测

### 检测目标

检测常见的 Android 内存泄漏模式。

### 代码模式

#### ❌ 错误示例

```kotlin
// BAD: 静态Context引用
object AppCache {
    private var context: Context? = null

    fun init(context: Context) {
        this.context = context  // 泄漏Activity
    }
}

// BAD: 非静态Handler
class LeakyActivity : Activity() {
    private val handler = Handler(Looper.getMainLooper())

    private val runnable = Runnable {
        // 隐式持有Activity引用
        updateUI()
    }

    override fun onResume() {
        super.onResume()
        handler.post(runnable)
    }
    // ❌ 缺少onDestroy清理
}

// BAD: 协程未取消
class CoroutineLeakActivity : Activity() {
    private val job = Job()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        CoroutineScope(Dispatchers.Main + job).launch {
            while (true) {
                delay(1000)
                updateUI()
            }
        }
    }
    // ❌ 缺少onDestroy清理
}
```

#### ✅ 正确示例

```kotlin
// GOOD: 使用Application Context
object AppCache {
    private var context: Context? = null

    fun init(context: Context) {
        this.context = context.applicationContext
    }
}

// GOOD: 静态Handler + WeakReference
class SafeActivity : Activity() {
    private val handler = SafeHandler(this)

    private val runnable = Runnable {
        updateUI()
    }

    override fun onResume() {
        super.onResume()
        handler.post(runnable)
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacksAndMessages(null)
        handler.removeCallbacks(runnable)
    }

    private class SafeHandler(activity: Activity) : Handler(Looper.getMainLooper()) {
        private val activityRef = WeakReference(activity)

        override fun handleMessage(msg: Message): Boolean {
            activityRef.get()?.updateUI()
            return true
        }
    }
}

// GOOD: lifecycle-aware协程
class CoroutineSafeActivity : Activity() {
    private val job = SupervisorJob()
    private val scope = CoroutineScope(Dispatchers.Main + job)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        scope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                while (isActive) {
                    delay(1000)
                    updateUI()
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        job.cancel()  // 取消所有协程
    }
}
```

### 检测要点

1. **静态Context/Activity**
   - `object` 或 `companion object` 持有 Context 引用

2. **非静态Handler**
   - 内部类/匿名类 Handler 隐式持有外部类引用

3. **协程未取消**
   - 使用 GlobalScope
   - 未在 onDestroy() 取消 Job

4. **监听器未注销**
   - EventBus、BroadcastReceiver 未注销

### 修复建议

1. **使用生命周期感知组件**
   ```kotlin
   lifecycleScope.launch { ... }
   viewModelScope.launch { ... }
   ```

2. **使用 WeakReference**
   ```kotlin
   class MyActivity: Activity() {
       private val ref = WeakReference(this)
   }
   ```

---

## QUAL-006: 调试代码残留

### 检测目标

检测生产代码中的调试语句。

### 代码模式

#### ❌ 错误示例

```kotlin
// BAD: 生产代码中的调试日志
class PaymentActivity : AppCompatActivity() {
    private fun processPayment() {
        Log.d("DEBUG", "Processing payment...")
        Log.d("DEBUG", "Card number: $cardNumber")
        Log.d("DEBUG", "CVV: $cvv")

        val result = paymentService.charge(cardNumber, cvv)
        Log.d("DEBUG", "Result: $result")
    }
}

// BAD: 硬编码测试URL
class ApiClient {
    private val BASE_URL = "http://test-api.example.com"  // ❌

    private val ENDPOINT = "https://api.example.com/v1/products?debug=true"  // ❌
}

// BAD: 注释掉的代码
fun calculateTotal() {
    // val discount = 0.1  // 暂时禁用
    // val tax = 0.08

    var total = price
    // total = total * (1 - discount)
    // total = total * (1 + tax)
}
```

#### ✅ 正确示例

```kotlin
// GOOD: 使用BuildConfig控制日志
class PaymentActivity : AppCompatActivity() {
    private fun processPayment() {
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "Processing payment for user ${currentUser.id}")
        }

        val result = paymentService.charge(cardNumber, cvv)
        if (result.isSuccess) {
            if (BuildConfig.DEBUG) {
                Log.d(TAG, "Payment succeeded: ${result.data}")
            }
        }
    }
}

// GOOD: 使用BuildConfig控制URL
class ApiClient {
    private val BASE_URL = if (BuildConfig.DEBUG) {
        "http://test-api.example.com"
    } else {
        "https://api.example.com"
    }
}

// GOOD: 移除注释代码，使用Git历史
fun calculateTotal(price: Double): Double {
    return price * 1.08  // 仅含税
}
```

### 检测要点

1. **Log语句**
   - `Log.d()`、`Log.v()` 在生产代码中
   - 检查是否有 BuildConfig.DEBUG 保护

2. **硬编码测试URL**
   - 包含 "test"、"localhost"、"127.0.0.1" 等

3. **注释代码**
   - 大段被注释的功能代码

4. **断点**
   - `breakpoint()` 或 `Debug.waitForDebugger()`

### 修复建议

1. **使用 Timber 或类似日志库**
   ```kotlin
   if (BuildConfig.DEBUG) {
       Timber.d("Payment processing...")
   }
   ```

2. **使用 ProGuard 移除日志**
   ```proguard
   -assumenosideeffects class android.util.Log {
       public static boolean isLoggable(java.lang.String, int);
       public static int v(...);
       public static int d(...);
   }
   ```

---

## QUAL-007: 测试覆盖不足

### 检测目标

检测新增业务逻辑缺少单元测试或仪器测试。

### 检测要点

1. **ViewModel/Repository 无对应测试**
2. **关键业务流程无仪器测试**
3. **复杂逻辑（算法、计算）无测试**

### 修复建议

1. **单元测试示例**
   ```kotlin
   @Test
   fun `calculateTotal returns correct total`() {
       val calculator = PriceCalculator()
       val result = calculator.calculateTotal(100.0, 0.08, 0.1)
       assertEquals(97.2, result, 0.001)
   }
   ```

2. **仪器测试示例**
   ```kotlin
   @Test
   fun `login flow success`() {
       // 输入用户名密码
       composeTestRule.onNodeWithTag("username_input")
           .performTextInput("test@example.com")
       composeTestRule.onNodeWithTag("password_input")
           .performTextInput("password123")

       // 点击登录
       composeTestRule.onNodeWithTag("login_button")
           .performClick()

       // 验证跳转主页
       composeTestRule.onNodeWithTag("home_screen")
           .assertIsDisplayed()
   }
   ```

---

## QUAL-008: 死代码检测

### 检测目标

检测未使用的代码、不可达的代码分支。

### 代码模式

#### ❌ 错误示例

```kotlin
// BAD: 未使用的函数
private fun oldFunction() {  // ❌ 从未被调用
    // ...
}

// BAD: 不可达的代码
fun processData(data: String?) {
    if (data == null) return
    if (data.isNotEmpty()) {
        processData(data)
    } else {
        processData(data)  // ❌ 永远不会执行
    }
}

// BAD: 未使用的导入
import android.util.Log  // ❌ 未使用
import java.io.File       // ❌ 未使用
import okhttp3.OkHttpClient  // ✅ 使用
```

#### ✅ 正确示例

```kotlin
// 移除未使用的函数和导入
import okhttp3.OkHttpClient

class DataProcessor {
    private val client = OkHttpClient()

    fun processData(data: String?) {
        val safeData = data ?: return
        if (safeData.isNotEmpty()) {
            process(safeData)
        }
    }
}
```

### 检测工具

- Android Lint
- Detekt
- IDE 内置检查

---

## QUAL-009: 不安全空值访问

### 检测目标

检测过度使用 `!!` 操作符，存在 NPE 风险。

### 代码模式

#### ❌ 错误示例

```kotlin
// BAD: 不安全的强制解包
fun processUser(userId: String?) {
    val user = getUser(userId)!!  // ❌ 可能NPE
    val name = user.name!!        // ❌ 可能NPE
    val email = user.email!!      // ❌ 可能NPE
    println("Name: $name, Email: $email")
}

// BAD: 链式!!操作
val userName = getUser(id)!!.profile!!.name!!
```

#### ✅ 正确示例

```kotlin
// GOOD: 使用安全调用
fun processUser(userId: String?) {
    val user = getUser(userId) ?: return
    val name = user.name ?: "Unknown"
    val email = user.email ?: return
    println("Name: $name, Email: $email")
}

// GOOD: 使用提前返回
fun getUserName(userId: String?): String {
    val user = getUser(userId) ?: return "Unknown"
    return user.name ?: "Unknown"
}

// GOOD: 使用Result或Optional
fun getUserSafe(userId: String): Result<User> {
    return try {
        val user = apiService.getUser(userId)
        Result.success(user)
    } catch (e: Exception) {
        Result.failure(e)
    }
}
```

### 检测要点

1. **`!!` 操作符使用**
   - 计算每个函数中 `!!` 的数量
   - 超过 3 个需要重构

2. **平台类型**
   - Java 互操作时的平台类型
   - 应添加 `@Nullable` / `@NonNull` 注解

---

## QUAL-010: 代码可读性

### 检测目标

检测影响代码可读性的问题。

### 检查项

1. **命名规范**
   - 变量名是否有意义
   - 函数名是否表达意图
   - 类名是否使用名词

2. **注释质量**
   - 复杂逻辑是否有注释说明
   - "为什么"而非"是什么"

3. **函数参数**
   - 参数数量（建议 ≤ 4个）
   - 使用参数对象（data class）封装

---

## 检查流程

### 执行顺序

```
1. QUAL-001 (超长函数)
   ↓
2. QUAL-002 (超长文件)
   ↓
3. QUAL-003 (深度嵌套)
   ↓
4. QUAL-004 (错误处理)
   ↓
5. QUAL-005 (内存泄漏)
   ↓
6. QUAL-006 (调试代码)
   ↓
7. QUAL-007 (测试覆盖)
   ↓
8. QUAL-008 (死代码)
   ↓
9. QUAL-009 (空值访问)
   ↓
10. QUAL-010 (可读性)
```

---

## 附录：修复优先级

| 规则ID | 修复优先级 | 理由 |
|--------|-----------|------|
| QUAL-004 (错误处理) | P0 | 直接影响稳定性 |
| QUAL-005 (内存泄漏) | P0 | 直接影响用户体验 |
| QUAL-009 (空值访问) | P0 | 高NPE风险 |
| QUAL-001 (超长函数) | P1 | 影响可维护性 |
| QUAL-003 (深度嵌套) | P1 | 影响可读性 |
| QUAL-002 (超长文件) | P1 | 影响可维护性 |
| QUAL-006 (调试代码) | P2 | 影响性能和安全性 |
| QUAL-008 (死代码) | P2 | 影响可维护性 |
| QUAL-007 (测试覆盖) | P2 | 影响代码质量 |
| QUAL-010 (可读性) | P3 | 长期维护性 |

---

**文档版本**: 1.0.0
**最后更新**: 2025-02-27
**Token估算**: 3200
