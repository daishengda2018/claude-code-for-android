// Test Case 001: Hardcoded Secrets
// Expected Detection: CRITICAL
// File: test-cases/security/001-hardcoded-secrets.kt

package com.test.security

import android.app.Activity

class BadSecrets : Activity() {

    // CRITICAL: Hardcoded API Key
    private const val API_KEY = "sk_live_abc123xyz789"

    // CRITICAL: Hardcoded Secret
    private const val SECRET = "my_secret_key_12345"

    // CRITICAL: Hardcoded Password
    private const val DB_PASSWORD = "admin123"

    // CRITICAL: Hardcoded Token
    private const val AUTH_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"

    fun connectToApi() {
        // Using hardcoded credentials
        val client = ApiClient(API_KEY, SECRET)
        client.connect()
    }
}

class GoodSecrets : Activity() {

    // CORRECT: Use BuildConfig
    private const val API_KEY = BuildConfig.API_KEY

    // CORRECT: Use EncryptedSharedPreferences
    private fun getSecret(): String {
        val prefs = EncryptedSharedPreferences.create(...)
        return prefs.getString("secret_key", "") ?: ""
    }
}

// Verification Checklist:
// [ ] Plugin detects API_KEY hardcoded value
// [ ] Plugin detects SECRET hardcoded value
// [ ] Plugin suggests using BuildConfig
// [ ] Plugin severity is CRITICAL
