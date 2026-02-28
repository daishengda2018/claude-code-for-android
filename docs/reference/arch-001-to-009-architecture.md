# ARCH-001 到 ARCH-009: Android 架构规则检查清单

> **规则ID范围**: ARCH-001 到 ARCH-009
> **严重等级**: P1 (HIGH)
> **分类**: Architecture (Android 架构)
> **Token估算**: 2800

---

## 规则概览

- ARCH-001: 生命周期违规
- ARCH-002: ViewModel 误用
- ARCH-003: Fragment 反模式
- ARCH-004: 资源硬编码
- ARCH-005: 主线程阻塞
- ARCH-006: 弃用 API 使用
- ARCH-007: 权限处理缺陷
- ARCH-008: 配置变更问题
- ARCH-009: View binding 违规

---

## ARCH-001: 生命周期违规

### 检测目标

检测在生命周期方法之外访问 UI、在 onDestroy 后执行操作。

### ❌ 错误示例

```kotlin
// BAD: onDestroy后更新UI
class LeakyActivity : Activity() {
    private val handler = Handler()

    fun loadData() {
        Thread {
            Thread.sleep(2000)
            handler.post {
                // ❌ Activity可能已销毁
                textView.text = "Loaded"
            }
        }.start()
    }
}
```

### ✅ 正确示例

```kotlin
// GOOD: 生命周期感知
class SafeActivity : Activity() {
    fun loadData() {
        lifecycleScope.launch {
            repeatOnLifecycle(Lifecycle.State.STARTED) {
                delay(2000)
                textView.text = "Loaded"
            }
        }
    }
}
```

---

## ARCH-002: ViewModel 误用

### ❌ 错误示例

```kotlin
// BAD: ViewModel持有Activity Context
class BadViewModel(context: Context) : ViewModel() {
    private val prefs = context.getSharedPreferences("app", MODE_PRIVATE)
}

// BAD: 存储View引用
class BadViewModel : ViewModel() {
    var textView: TextView? = null
}
```

### ✅ 正确示例

```kotlin
// GOOD: 使用Application Context或依赖注入
class GoodViewModel(application: Application) : AndroidViewModel(application) {
    private val prefs = application.getSharedPreferences("app", MODE_PRIVATE)
}

// GOOD: 使用SavedStateHandle
class GoodViewModel(
    savedStateHandle: SavedStateHandle
) : ViewModel() {
    val text = savedStateHandle.getStateFlow("text", "")
}
```

---

## ARCH-003: Fragment 反模式

### ❌ 错误示例

```kotlin
// BAD: 直接类型转换
class MyFragment : Fragment() {
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val activity = activity as MainActivity  // ❌ 可能ClassCastException
    }
}
```

### ✅ 正确示例

```kotlin
// GOOD: 类型安全的通信
class MyFragment : Fragment() {
    interface Callback {
        fun onButtonClick()
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        if (context is Callback) {
            callback = context
        }
    }
}
```

---

## ARCH-004: 资源硬编码

### ❌ 错误示例

```kotlin
// BAD: 硬编码字符串
textView.text = "Welcome"

// BAD: 硬编码颜色
view.setBackgroundColor(Color.parseColor("#FF0000"))

// BAD: 硬编码尺寸
view.layoutParams.height = 100
```

### ✅ 正确示例

```kotlin
// GOOD: 使用资源
textView.text = getString(R.string.welcome)
view.setBackgroundColor(getColor(R.color.primary_color))
view.layoutParams.height = resources.getDimensionPixelSize(R.dimen.item_height)
```

---

## ARCH-005: 主线程阻塞

### ❌ 错误示例

```kotlin
// BAD: 主线程IO操作
fun loadData() {
    val data = File(path).readText()  // ❌ 阻塞主线程
    database.query("SELECT * FROM users").execute()  // ❌ 阻塞主线程
}
```

### ✅ 正确示例

```kotlin
// GOOD: 异步加载
fun loadData() {
    viewModelScope.launch(Dispatchers.IO) {
        val data = File(path).readText()
        withContext(Dispatchers.Main) {
            displayData(data)
        }
    }
}
```

---

## ARCH-006: 弃用 API

### ❌ 错误示例

```kotlin
// BAD: AsyncTask（Android 13已移除）
class LegacyTask : AsyncTask<Void, Void, Void>() {
    override fun doInBackground(vararg params: Void?): Void? {
        // ...
    }
}

// BAD: onActivityResult
override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    // ❌ 使用ActivityResultLauncher
}
```

### ✅ 正确示例

```kotlin
// GOOD: 使用协程替代AsyncTask
fun loadData() {
    lifecycleScope.launch(Dispatchers.IO) {
        // ...
    }
}

// GOOD: 使用ActivityResultLauncher
val resultLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
    // ...
}
```

---

## ARCH-007: 权限处理

### ❌ 错误示例

```kotlin
// BAD: 未检查权限
private fun takePhoto() {
    val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
    startActivityForResult(intent, REQUEST_CODE)
}
```

### ✅ 正确示例

```kotlin
// GOOD: 检查运行时权限
private fun takePhoto() {
    if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
        != PackageManager.PERMISSION_GRANTED
    ) {
        requestPermissions(arrayOf(Manifest.permission.CAMERA), REQUEST_CODE)
    } else {
        launchCamera()
    }
}
```

---

## ARCH-008: 配置变更

### ❌ 错误示例

```kotlin
// BAD: 屏幕旋转丢失状态
class MainActivity : Activity() {
    private var counter = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // ❌ counter在配置变更时重置为0
    }
}
```

### ✅ 正确示例

```kotlin
// GOOD: 使用ViewModel保存状态
class MainActivity : Activity() {
    private val viewModel: MyViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        viewModel.counter.observe(this) { count ->
            updateCount(count)
        }
    }
}
```

---

## ARCH-009: View binding

### ❌ 错误示例

```kotlin
// BAD: findViewById可能有NPE
val button = findViewById<Button>(R.id.button) as? Button
button?.setOnClickListener { ... }
```

### ✅ 正确示例

```kotlin
// GOOD: 使用View Binding
private lateinit var binding: ActivityMainBinding

override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    binding = ActivityMainBinding.inflate(layoutInflater)
    setContentView(binding.root)
    binding.button.setOnClickListener { ... }
}

override fun onDestroy() {
    super.onDestroy()
    binding = null  // 避免内存泄漏
}
```

---

**文档版本**: 1.0.0
**最后更新**: 2025-02-27
**Token估算**: 2800
