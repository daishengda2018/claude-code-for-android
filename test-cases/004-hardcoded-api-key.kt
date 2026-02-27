// Test Case 004: Single File - Hardcoded API Key
// Expected Detection: CRITICAL (SEC-001)
package com.test.security

class ApiKeyHandler {
    // CRITICAL: Hardcoded API key in production code
    private const val API_KEY = "AIzaSyDaShengDa2018_TEST_KEY_DO_NOT_USE"

    fun makeRequest(): String {
        return "Calling API with key: $API_KEY"
    }
}
