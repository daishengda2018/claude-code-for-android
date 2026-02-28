// Test Case 001: Hardcoded Secrets
// Expected Detection: CRITICAL
// File: test-cases/security/001-hardcoded-secrets.kt

package com.test.security

import android.app.Activity

class BadSecrets : Activity() {

    // CRITICAL: Hardcoded API Key
    private const val API_KEY = "sk_test_TEST_KEY_DO_NOT_USE_DEMO_ONLY"

    // CRITICAL: Hardcoded Secret
    private const val SECRET = "TEST_SECRET_FOR_DEMO_ONLY_DO_NOT_USE"

    // CRITICAL: Hardcoded Password
    private const val DB_PASSWORD = "TEST_PASSWORD_DEMO_DO_NOT_USE"

    // CRITICAL: Hardcoded Token
    private const val AUTH_TOKEN = "TEST.JWT.TOKEN.DEMO.DO.NOT.USE"

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
