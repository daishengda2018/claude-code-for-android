# Security Rules (SEC-001 to SEC-010)

**Severity:** P0 (CRITICAL) | **Category:** Security | **Tokens:** ~2,500

## Rules Overview

- SEC-001: Hardcoded credentials
- SEC-002: Insecure data storage
- SEC-003: Unsafe Intent handling
- SEC-004: WebView vulnerabilities
- SEC-005: Cleartext traffic
- SEC-006: Permission abuse
- SEC-007: Sensitive data leakage
- SEC-008: Outdated dependencies
- SEC-009: SSL/TLS validation
- SEC-010: Weak cryptography

---

## SEC-001: 硬编码凭证检测

### 检测目标

检测代码中硬编码的敏感凭证，包括但不限于：
- API 密钥
- OAuth 凭证
- 加密密钥
- JWT 签名密钥
- 数据库连接字符串
- 第三方服务密钥

### 风险场景

**CRITICAL**: 这些信息会被提交到 Git 历史，APK 反编译后可直接提取，导致：
- 后端服务被盗用
- 云资源被恶意消耗
- 数据泄露
- 经济损失

### 代码模式

#### ❌ 错误示例

```kotlin
// 直接硬编码
const val API_KEY = "sk_live_abc1234567890"
const val DATABASE_URL = "postgres://user:password@host:5432/db"

// Base64 编码的密钥（可轻易解码）
val encodedKey = "c2tfbGl2ZV9hYmMxMjM0NTY3ODkw"

// 分段拼接（仍可被还原）
val keyPart1 = "sk_live"
val keyPart2 = "abc1234567890"
val API_KEY = "$keyPart1$keyPart2"
```

```java
// Java 中的硬编码
public static final String API_KEY = "sk_live_abc1234567890";
private String getSecret() {
    return "secret_value_12345";
}
```

```xml
<!-- AndroidManifest.xml 或 XML 资源文件 -->
<string name="api_key">sk_live_abc1234567890</string>
<meta-data android:value="sk_live_abc1234567890" android:name="API_KEY"/>
```

#### ✅ 正确示例

```kotlin
// 从 BuildConfig 读取（推荐）
const val API_KEY = BuildConfig.API_KEY

// 从 gradle.properties 注入
// build.gradle.kts:
// android {
//   defaultConfig {
//     buildConfigField("String", "API_KEY", "\"${project.findProperty("api_key")}\"")
//   }
// }

// 使用 EncryptedSharedPreferences
val masterKey = MasterKey.Builder(context)
    .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
    .build()

val encryptedPrefs = EncryptedSharedPreferences.create(
    "secure_prefs",
    masterKey,
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
)

// 运行时从安全存储获取
val apiKey = encryptedPrefs.getString("api_key", null)
```

### 检测要点

1. **字符串字面量匹配**
   - 查找包含敏感关键词的字符串赋值
   - 关键词：`api_key`, `secret`, `password`, `token`, `auth`, `key`
   - 字符串长度 ≥ 8 位

2. **模式识别**
   - `sk_` 开头（Stripe 密钥）
   - `pk_` 开头（Stripe 公钥）
   - `Bearer ` + 长字符串
   - `ssh-rsa` 开头
   - Base64 编码的长字符串（特征：连续字母数字，长度 ≥ 16）

3. **上下文分析**
   - 变量名包含敏感关键词
   - 常量声明（`const val`, `static final`）
   - 资源文件中的字符串值

4. **豁免条件**
   - 测试文件中的示例数据
   - 空字符串或格式化字符串
   - 注释中提到的关键词（非代码）
   - 包含 `code-review-ignore` 注释的行

### 置信度计算

```
confidence = 语义匹配得分 × 0.6 + 规则覆盖完整度 × 0.4
```

**语义匹配得分计算**：
- 匹配到敏感关键词：0.3
- 字符串长度可疑（≥16）：0.2
- 包含生产环境关键词：0.2
- 常量声明：0.2

**规则覆盖完整度**：
- 符合代码模式：0.5
- 无明显豁免条件：0.3
- 上下文支持判断：0.2

### 修复建议

1. **立即修复**（CRITICAL）
   - 移除所有硬编码凭证
   - 将密钥移至 `gradle.properties`（添加到 `.gitignore`）
   - 使用 BuildConfig 注入

2. **长期方案**（推荐）
   - 使用密钥管理服务（如 AWS Secrets Manager、HashiCorp Vault）
   - 实施运行时密钥获取
   - 定期轮换密钥

3. **Git 历史清理**
   - 如果已提交，使用 BFG Repo-Cleaner 或 git-filter-branch 清理历史
   - 强制推送到所有远程仓库
   - 通知团队重新克隆仓库

---

## SEC-002: 不安全数据存储

### 检测目标

检测敏感数据以明文形式存储在：
- SharedPreferences
- SQLite 数据库（未加密）
- 外部存储（SD 卡）
- Log 日志

### 风险场景

**CRITICAL**: root 设备可读取这些数据，导致：
- 用户隐私泄露
- 认证凭证被盗用
- 违反 GDPR/隐私法规

### 代码模式

#### ❌ 错误示例

```kotlin
// 明文 SharedPreferences
val prefs = getSharedPreferences("user_auth", Context.MODE_PRIVATE)
prefs.edit().putString("access_token", userToken).apply()

// 明文 SQLite
val db = SQLiteDatabase.openDatabase(dbPath, null)
db.execSQL("INSERT INTO users (email, password) VALUES (?, ?)", arrayOf(email, password))

// 外部存储
val file = File(Environment.getExternalStorageDirectory(), "secret.txt")
file.writeText(sensitiveData)

// Log 输出敏感信息
Log.d("AUTH", "User token: $authToken")
Log.i("API", "API key: $apiKey")
```

#### ✅ 正确示例

```kotlin
// EncryptedSharedPreferences
val masterKey = MasterKey.Builder(context)
    .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
    .build()

val encryptedPrefs = EncryptedSharedPreferences.create(
    "encrypted_user_auth",
    masterKey,
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
)
encryptedPrefs.edit().putString("access_token", userToken).apply()

// SQLCipher 加密数据库
val dbName = "encrypted.db"
val passphrase = SQLiteDatabase.getBytes("my-secret-passphrase".toCharArray())
val factory = SupportFactory(passphrase)
val db = SupportHelper(context, DatabaseCallback(), factory).writableDatabase

// 仅输出调试信息，不包含敏感数据
Log.d("AUTH", "Token received, length=${token.length}")
```

### 检测要点

1. **SharedPreferences 检查**
   - 查找 `getSharedPreferences` 调用
   - 检查存储的值是否包含敏感关键词
   - 确认是否使用 `EncryptedSharedPreferences`

2. **SQLite 检查**
   - 查找 `SQLiteDatabase` 直接打开
   - 确认是否使用 SQLCipher
   - 检查 INSERT/UPDATE 语句的值

3. **日志检查**
   - 查找 `Log.*` 调用
   - 检查日志内容是否包含敏感信息
   - 验证是否在 Release 构建中禁用

---

## SEC-003: 不安全 Intent 处理

### 检测目标

检测可能导致 Intent 劫持攻击的代码：
- 隐式 Intent 未验证组件
- 导出的组件缺少权限保护
- Intent 接收未验证来源

### 风险场景

**CRITICAL**: 恶意应用可劫持 Intent，导致：
- 未授权操作
- 数据泄露
- 代码执行

### 代码模式

#### ❌ 错误示例

```kotlin
// 隐式 Intent，未验证接收者
val intent = Intent(ACTION_SEND)
intent.putExtra("secret_data", secretData)
startActivity(intent)  // 任何应用都可响应

// 导出 Activity，无权限保护
<activity android:name=".ExportedActivity"
          android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW"/>
    </intent-filter>
</activity>

// 未验证 Intent 来源
override fun onNewIntent(intent: Intent?) {
    val data = intent?.getStringExtra("sensitive_data")
    processSensitiveData(data)  // 未验证来源
}
```

#### ✅ 正确示例

```kotlin
// 显式 Intent
val intent = Intent(this, TargetActivity::class.java)
intent.putExtra("data", data)
startActivity(intent)

// 或使用包名验证隐式 Intent
val intent = Intent(ACTION_SEND)
intent.`package` = "com.trusted.app"  // 指定包名

// 导出组件添加权限保护
<activity android:name=".ExportedActivity"
          android:exported="true"
          android:permission="com.example.PERMISSION_CUSTOM">
    <intent-filter>
        <action android:name="android.intent.action.VIEW"/>
    </intent-filter>
</activity>

// 验证 Intent 来源
override fun onNewIntent(intent: Intent?) {
    val callingPackage = callingActivity?.packageName
    if (callingPackage in TRUSTED_PACKAGES) {
        val data = intent?.getStringExtra("sensitive_data")
        processSensitiveData(data)
    }
}
```

---

## SEC-004: WebView 安全漏洞

### 检测目标

检测 WebView 的不安全配置：
- 启用 JavaScript 但无 CSP
- 不安全的 `addJavascriptInterface`
- 禁用 SSL 证书验证
- 加载不可信内容

### 代码模式

#### ❌ 错误示例

```kotlin
// 启用 JS，无限制
webView.settings.javaScriptEnabled = true
webView.loadUrl(untrustedUrl)

// 不安全的 JS 接口
webView.addJavascriptInterface(object {
    @JavascriptInterface
    fun getToken(): String = authToken  // 暴露给 JS
}, "bridge")

// 禁用 SSL 验证
webView.settings.setMixedContentMode(MIXED_CONTENT_ALWAYS_ALLOW)
```

#### ✅ 正确示例

```kotlin
// 使用 CSP
webView.settings.javaScriptEnabled = true
webView.settings.domStorageEnabled = true

// 安全的 JS 接口
class JsBridge(private val context: Context) {
    @JavascriptInterface
    fun safeMethod(): String {
        // 仅暴露安全方法
        return "safe_value"
    }
}

webView.addJavascriptInterface(JsBridge(this), "bridge")

// 启用 HTTPS
webView.settings.mixedContentMode = WebSettings.MIXED_CONTENT_NEVER_ALLOW
```

---

## SEC-005 到 SEC-010

（剩余规则按相同格式展开...）

---

## 检查流程

### 执行顺序

```
1. SEC-001 (硬编码凭证)
   ↓
2. SEC-002 (不安全存储)
   ↓
3. SEC-003 (Intent 安全)
   ↓
4. SEC-004 (WebView 安全)
   ↓
5. SEC-005 (明文通信)
   ↓
6. SEC-006 (权限滥用)
   ↓
7. SEC-007 (数据泄露)
   ↓
8. SEC-008 (依赖安全)
   ↓
9. SEC-009 (SSL/TLS)
   ↓
10. SEC-010 (加密算法)
```

### 置信度阈值

- **默认**: 0.8
- **CRITICAL 问题**: 必须报告，不考虑置信度
- **误报处理**: 通过 `code-review-ignore` 注释豁免

### 输出格式

每个问题必须包含：
- 规则 ID（如 `[SEC-001]`）
- 严重等级（`P0`）
- 文件位置和行号
- 问题描述（1-2 句话）
- 修复建议（含代码示例）
- 置信度得分（0.0-1.0）

---

## 附录：豁免机制

### 单行豁免

```kotlin
// code-review-ignore
val API_KEY = "sk_live_abc123"  // 特殊原因：测试环境
```

### 块级豁免

```kotlin
/*code-review-ignore
val password = "hardcoded"
val token = "hardcoded"
*/
```

### 注解豁免

```kotlin
@Suppress("HardcodedSecret")
fun testFunction() {
    val key = "test_key_123"
}
```
