# PRAC-001 到 PRAC-008: 最佳实践规则检查清单

> **规则ID范围**: PRAC-001 到 PRAC-008
> **严重等级**: P3 (LOW)
> **分类**: Best Practices (最佳实践)
> **Token估算**: 2000

---

## PRAC-001: TODO/FIXME 跟踪

### ❌ 错误示例

```kotlin
// TODO: 实现错误处理
// FIXME: 优化性能
// HACK: 临时方案，需要重构
```

### ✅ 正确示例

```kotlin
// TODO: 实现错误处理 (PROJ-456)
// FIXME: 优化性能 - 当前O(n²)，目标O(n) (TECH-789)
// HACK: 临时方案，需要重构 - 使用WorkManager替代 (ARCH-234)
```

---

## PRAC-002: 文档缺失

### 检测目标

公共 API 缺少 KDoc/Javadoc。

### ✅ 正确示例

```kotlin
/**
 * 用户认证管理器
 *
 * 负责用户登录、登出和token刷新。
 * 使用[OkHttp]执行网络请求。
 *
 * @property apiService API服务接口
 * @see AuthToken
 * @author Your Name
 * @since 1.0.0
 */
class AuthManager @Inject constructor(
    private val apiService: ApiService
) {
    /**
     * 用户登录
     *
     * @param username 用户名
     * @param password 密码
     * @return [Result] 包含token或错误
     * @throws [InvalidCredentialsException] 凭据无效时抛出
     */
    suspend fun login(username: String, password: String): Result<AuthToken>
}
```

---

## PRAC-003: 命名规范

### ❌ 错误示例

```kotlin
// BAD: 单字母变量
val u = getUser()
val d = getDate()

// BAD: 缩写不明确
fun calc() { }

// BAD: 资源命名不规范
layout/button_login.xml  // ❌ 应该是btn_login.xml
```

### ✅ 正确示例

```kotlin
// GOOD: 有意义的命名
val user = getUser()
val dispatchDate = getDate()

// GOOD: 描述性函数名
fun calculateTotal() { }

// GOOD: 标准资源命名
layout/btn_login.xml
drawable/ic_launcher_background.xml
string/app_name.xml
```

---

## PRAC-004: Magic Numbers/Strings

### ❌ 错误示例

```kotlin
// BAD: 魔法数字
if (retryCount > 5) { }  // ❌ 为什么是5？

// BAD: 硬编码字符串
apiService.get("https://api.example.com/v1/products")
```

### ✅ 正确示例

```kotlin
// GOOD: 命名常量
companion object {
    private const val MAX_RETRY_COUNT = 5
}

if (retryCount > MAX_RETRY_COUNT) { }

// GOOD: 使用资源
apiService.get(getString(R.string.api_endpoint))
```

---

## PRAC-005: 格式一致性

### 检查项

- 缩进：4空格（Kotlin标准）
- 行宽：建议 ≤ 120 字符
- 空行：类、函数之间一个空行
- 花括号：省略单行函数的括号

---

## PRAC-006: 未使用资源

### 检测工具

- Android Lint "UnusedResources"
- 手动检查 `res/` 目录

---

## PRAC-007: 架构一致性

### 检测目标

检查是否违反项目建立的架构模式（MVVM/MVI/Clean）。

### 示例

```kotlin
// ❌ 在Activity中直接访问数据库
class MainActivity : Activity() {
    fun loadData() {
        database.userDao().getAll()  // ❌ 应通过Repository
    }
}

// ✅ 正确的分层
Activity → ViewModel → Repository → DAO
```

---

## PRAC-008: 无障碍支持

### ❌ 错误示例

```xml
<!-- BAD: ImageView缺少contentDescription -->
<ImageView
    android:src="@drawable/profile_pic"
    android:layout_width="48dp"
    android:layout_height="48dp" />
```

### ✅ 正确示例

```xml
<!-- GOOD: 包含contentDescription -->
<ImageView
    android:src="@drawable/profile_pic"
    android:contentDescription="@string/profile_picture"
    android:layout_width="48dp"
    android:layout_height="48dp"
    android:focusable="true" />
```

---

**文档版本**: 1.0.0
**Token估算**: 2000
