# Security Detection Patterns

> **规则范围**: SEC-001 到 SEC-010
> **严重等级**: P0 (CRITICAL)
> **Token 优化版本**: 1,500 (原始: 2,500)

---

## SEC-001: 硬编码凭证检测

### 检测模式

**字符串模式**:
- `"sk_live"` + 长字符串 → Stripe API Key
- `"pk_live"` + 长字符串 → Stripe Public Key
- `"Bearer "` + 长字符串 → JWT Token
- `"ssh-rsa "` + 密钥 → SSH Key
- Base64 长字符串 (≥16 字符) → 编码密钥
- 连续字母数字字符串 (≥20 字符) → 可疑密钥

**关键词匹配**:
- `api_key`, `secret`, `password`, `token`, `auth`, `key`
- `database_url`, `db_connection`, `connection_string`
- `access_token`, `refresh_token`, `auth_token`

**上下文线索**:
- 变量名: `const val`, `static final`, `val API_KEY`
- 文件名: `ApiClient`, `WebService`, `NetworkConfig`, `Constants`
- 位置: 顶部常量定义、对象声明

**XML 资源**:
- `<string name="api_key">sk_live_...`
- `<meta-data android:value="sk_live_..."`

### 修复建议

1. **立即**: 移至 `gradle.properties` + `BuildConfig`
2. **推荐**: EncryptedSharedPreferences (运行时)
3. **生产**: 密钥管理服务 (AWS Secrets Manager, HashiCorp Vault)
4. **清理**: BFG Repo-Cleaner 清理 Git 历史

---

## SEC-002: 不安全数据存储

### 检测模式

**明文存储**:
- `getSharedPreferences("...", MODE_PRIVATE)` + `putString("token", ...)` → 明文 token
- `SQLiteDatabase.openDatabase(...)` + `execSQL("INSERT...")` → 明文数据库
- `Environment.getExternalStorageDirectory()` → 外部存储
- `Log.d("TAG", "token: $token")` → 日志泄露

**敏感关键词**:
- `password`, `token`, `secret`, `auth`, `credential`, `key`
- `access_token`, `refresh_token`, `session`, `cookie`

**上下文线索**:
- 文件名: `UserManager`, `AuthManager`, `SessionManager`
- 方法名: `saveToken`, `storePassword`, `cacheCredentials`

### 修复建议

1. **SharedPreferences**: → `EncryptedSharedPreferences`
2. **数据库**: → SQLCipher (`SupportFactory` with passphrase)
3. **外部存储**: → 内部存储 + EncryptedFile
4. **日志**: → 仅输出长度/哈希，禁用 Release 日志

---

## SEC-003: 不安全 Intent 处理

### 检测模式

**隐式 Intent**:
- `Intent(ACTION_SEND)` + `startActivity(...)` → 未验证接收者
- `Intent(Intent.ACTION_VIEW)` + 隐式 URL → 劫持风险

**导出组件**:
- `android:exported="true"` + `<intent-filter>` → 无权限保护
- `android:exported="true"` + 无 `android:permission` → 公开访问

**Intent 接收**:
- `onNewIntent(intent)` + 直接使用数据 → 未验证来源
- `getIntent().getExtras()` + 无包名检查 → 信任问题

### 修复建议

1. **隐式 Intent**: → 显式 Intent 或设置 `intent.package = "com.trusted.app"`
2. **导出组件**: → 添加 `android:permission="com.example.CUSTOM_PERMISSION"`
3. **Intent 接收**: → 验证 `callingActivity?.packageName` 在白名单

---

## SEC-004: WebView 安全漏洞

### 检测模式

**JavaScript 启用**:
- `settings.javaScriptEnabled = true` + 无 CSP → XSS 风险
- `addJavascriptInterface(...)` + 返回敏感数据 → 暴露给 JS

**混合内容**:
- `setMixedContentMode(MIXED_CONTENT_ALWAYS_ALLOW)` → 明文 HTTP
- `loadUrl("http://...")` → 不安全来源

**文件访问**:
- `settings.setAllowFileAccess(true)` → 本地文件泄露

### 修复建议

1. **JavaScript**: → 启用 CSP (`Content-Security-Policy` header)
2. **JS 接口**: → 仅暴露安全方法，使用 `@JavascriptInterface`
3. **HTTPS**: → `MIXED_CONTENT_NEVER_ALLOW`，验证证书
4. **文件访问**: → `setAllowFileAccess(false)`

---

## SEC-005: 明文通信违规

### 检测模式

**HTTP 流量**:
- `"http://"` (非 localhost) → 明文通信
- `setMixedContentMode(MIXED_CONTENT_ALWAYS_ALLOW)` → 允许 HTTP

**网络安全配置**:
- 缺少 `res/xml/network_security_config.xml` → 无 TLS 配置
- `<base-config cleartextTrafficPermitted="true">` → 允许明文

### 修复建议

1. **URL**: → 强制 HTTPS，移除所有 `http://`
2. **配置**: → `network_security_config.xml` 禁止明文
3. **证书**: → 启用证书绑定 (Certificate Pinning)

---

## SEC-006: 权限滥用

### 检测模式

**危险权限**:
- `READ_CONTACTS`, `WRITE_CONTACTS` → 联系人访问
- `READ_SMS`, `SEND_SMS` → 短信访问
- `ACCESS_FINE_LOCATION` → 位置追踪
- `RECORD_AUDIO` → 麦克风录音
- `CAMERA` → 相机访问

**问题模式**:
- 请求权限但未检查 `shouldShowRequestPermissionRationale` → 用户体验差
- 权限未在 `AndroidManifest.xml` 声明 → 运行时异常

### 修复建议

1. **最小权限**: → 仅请求必要的权限
2. **运行时检查**: → `ContextCompat.checkSelfPermission` + 合理解释
3. **降级方案**: → 权限被拒绝时提供替代功能

---

## SEC-007: 敏感数据泄露

### 检测模式

**日志泄露**:
- `Log.*("TAG", sensitiveData)` → 日志包含敏感信息
- `System.out.println(token)` → 控制台泄露
- `printStackTrace()` → 堆栈包含敏感信息

**剪贴板**:
- `clipboardManager.setPrimaryClip(token)` → 其他应用可读取
- `clipboardManager.primaryClip` + 无验证 → 读取不可信数据

**截图**:
- 敏感界面未设置 `FLAG_SECURE` → 可被截图/录屏

### 修复建议

1. **日志**: → 移除所有敏感数据，仅输出长度/哈希
2. **剪贴板**: → 避免存储敏感信息，使用后清除
3. **截图**: → `window.setFlags(FLAG_SECURE, FLAG_SECURE)`

---

## SEC-008: 不安全依赖

### 检测模式

**版本检查**:
- `build.gradle` / `build.gradle.kts` 中的库版本
- 过时的库 (有已知 CVE)
- 未维护的库 (最后更新 > 2 年)

**关键字**:
- `com.android.support:.*` → 旧版 Support Library
- `implementation "com.squareup.okhttp3:okhttp:3.*"` → OkHttp 3.x (已知漏洞)

### 修复建议

1. **扫描**: → `./gradlew dependencyCheckAnalyze` (OWASP Dependency Check)
2. **更新**: → 升级到最新稳定版本
3. **监控**: → 使用 Dependabot 或 Snyk

---

## SEC-009: SSL/TLS 验证缺陷

### 检测模式

**禁用验证**:
- `TrustManager` + 空实现 → 信任所有证书
- `HttpsURLConnection.setDefaultSSLSocketFactory(...)` → 自定义工厂
- `OkHttpClient` + `trustAllCertificates()` → 跳过验证

**错误配置**:
- 使用 TLS 1.1 或更低 → 过时协议
- 使用弱密码套件 (如 `RC4`) → 不安全加密

### 修复建议

1. **移除自定义 TrustManager**: → 使用系统默认验证
2. **协议版本**: → 强制 TLS 1.2+
3. **证书绑定**: → 实施 Certificate Pinning

---

## SEC-010: 加密算法缺陷

### 检测模式

**弱加密**:
- `DES`, `DESede` → 已破解
- `MD5`, `SHA1` → 哈希碰撞
- `AES/ECB/NoPadding` → 无 IV，可预测

**硬编码密钥**:
- 加密密钥硬编码在代码中 → 可被提取
- IV 固定或可预测 → 加密失效

**模式问题**:
- `Cipher.getInstance("AES")` → 默认 ECB 模式
- `Cipher.getInstance("DES/ECB/...")` → 弱算法 + 弱模式

### 修复建议

1. **算法**: → AES-256-GCM
2. **哈希**: → SHA-256 或更高
3. **密钥管理**: → KeyStore (Android Keystore)
4. **IV**: → 随机生成，每次加密唯一

---

## 检测优先级

| 规则 | 检测优先级 | 理由 |
|------|-----------|------|
| SEC-001 | 🔴 最高 | 直接导致密钥泄露 |
| SEC-002 | 🔴 最高 | 用户数据可被 root 读取 |
| SEC-003 | 🟠 高 | Intent 劫持可执行恶意代码 |
| SEC-004 | 🟠 高 | WebView XSS 可窃取数据 |
| SEC-005 | 🟠 高 | 中间人攻击可拦截通信 |
| SEC-006 | 🟡 中 | 隐私侵犯，但非直接安全漏洞 |
| SEC-007 | 🟡 中 | 日志可能被导出 |
| SEC-008 | 🟡 中 | 依赖漏洞需利用代码 |
| SEC-009 | 🟠 高 | 禁用 TLS 验证非常危险 |
| SEC-010 | 🟡 中 | 弱加密降低破解难度 |

---

## 豁免机制

### 单行豁免
```kotlin
// code-review-ignore: SEC-001 - 测试环境临时凭证
const val TEST_KEY = "sk_test_abc123"
```

### 块级豁免
```kotlin
/* code-review-ignore: SEC-002 - 示例代码，不存储真实数据 */
val prefs = getSharedPreferences("demo", MODE_PRIVATE)
```

### 注解豁免
```kotlin
@Suppress("HardcodedSecret", "IntentFirewallWarning")
fun testCode() { /* ... */ }
```

---

## Token 优化说明

**原始版本**: 2,500 tokens (457 行，213 行代码示例 = 46.6%)
**优化版本**: 1,500 tokens (纯检测模式，无冗余代码示例)
**节省**: 40%

**优化策略**:
1. 移除完整的 ❌/✅ 代码示例
2. 保留关键检测模式（字符串、关键词、上下文）
3. 用简洁的修复建议替代详细示例
4. 保留豁免机制和置信度计算
