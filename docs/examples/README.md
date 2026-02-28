# Code Examples

Real-world examples of detected issues and their fixes.

## 🔴 CRITICAL: Security

### Hardcoded API Keys

**❌ Bad Code** (SEC-001):
```kotlin
object ApiConfig {
    const val API_KEY = "sk_live_abc123xyz789"  // Detected!
    const val SECRET = "Bearer eyJhbGciOiJIUzI1NiIs..."  // Detected!
}
```

**✅ Fixed**:
```kotlin
// gradle.properties
API_KEY=sk_live_abc123xyz789

// build.gradle
android {
    buildFeatures {
        buildConfig = true
    }
}

// ApiConfig.kt
object ApiConfig {
    const val API_KEY = BuildConfig.API_KEY  // Safe
}
```

**Why**: Hardcoded keys in git history are exposed in APK decompilation.

---

## 🟠 HIGH: Memory Leaks

### Handler Leak (QUAL-002)

**❌ Bad Code**:
```kotlin
class LeakyActivity : Activity() {
    private val handler = Handler()  // Holds Activity reference!

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handler.postDelayed({
            // Activity might be destroyed here
            textView.text = "Updated"
        }, 5000)
    }
}
```

**✅ Fixed**:
```kotlin
class SafeActivity : Activity() {
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handler.postDelayed({
            if (!isFinishing && !isDestroyed) {
                textView.text = "Updated"
            }
        }, 5000)
    }

    override fun onDestroy() {
        handler.removeCallbacksAndMessages(null)
        super.onDestroy()
    }
}
```

**Why**: Activity Context leaks cause memory leaks and crashes.

---

## 🟡 MEDIUM: Null Safety

### Force Unwrap (NPE)

**❌ Bad Code**:
```kotlin
class UserProfileFragment : Fragment() {
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val args = arguments!!  // NPE risk!
        val userId = args.getString("userId")!!  // NPE risk!
        loadUser(userId)
    }
}
```

**✅ Fixed**:
```kotlin
class UserProfileFragment : Fragment() {
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val userId = arguments?.getString("userId")
        if (userId != null) {
            loadUser(userId)
        } else {
            showError("User ID not provided")
        }
    }
}
```

**Why**: Force unwrap causes NPE crashes in production.

---

## 🟢 LOW: Best Practices

### Missing Documentation

**❌ Bad Code**:
```kotlin
fun process(data: String, flag: Boolean): Result {
    // What does this do?
    return if (flag) parse(data) else validate(data)
}
```

**✅ Fixed**:
```kotlin
/**
 * Processes user input data.
 *
 * @param data Raw input string from user
 * @param flag If true, parses JSON; if false, validates format
 * @return Result object containing parsed data or validation errors
 * @throws IllegalArgumentException if data is empty
 */
fun process(data: String, flag: Boolean): Result {
    require(data.isNotEmpty()) { "Data cannot be empty" }
    return if (flag) parse(data) else validate(data)
}
```

**Why**: Good documentation prevents bugs and improves maintainability.

---

## More Examples

For complete test cases, see:
- [test-cases/](../test-cases/) - Standalone examples
- [test-android/](../test-android/) - Real Android project

For detailed patterns, see:
- [Detection Patterns](../skills/android-code-review/patterns/) - Technical patterns

---

**Last Updated**: 2026-02-28
