// Test Case 003: Unsafe Null Handling
// Expected Detection: MEDIUM
// File: test-cases/quality/003-unsafe-null.kt

package com.test.quality

class UnsafeNullHandling {

    // MEDIUM: Force unwrap operator
    fun processText(text: String?): Int {
        return text!!.length  // NPE risk
    }

    // MEDIUM: Unsafe nullable call without default
    fun getUserEmail(user: User?): String {
        return user.email.toString()  // Potential NPE
    }

    // MEDIUM: Lateinit not initialized
    private lateinit var requiredField: String

    fun dangerousMethod() {
        // Crash if not initialized
        println(requiredField.length)
    }
}

class SafeNullHandling {

    // CORRECT: Safe call with default
    fun processText(text: String?): Int {
        return text?.length ?: 0
    }

    // CORRECT: Early return pattern
    fun getUserEmail(user: User?): String? {
        if (user == null) return null
        return user.email
    }
}

data class User(
    val email: String? = null
)

// Verification Checklist:
// [ ] Plugin detects !! operator
// [ ] Plugin detects unsafe nullable access
// [ ] Plugin suggests safe alternatives
// [ ] Plugin severity is MEDIUM
