package com.example.test

import android.app.Activity
import android.os.Handler
import android.os.Looper
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.withContext

// Test file with intentional issues for review

class TestActivity : Activity() {

    // CRITICAL: Hardcoded API key
    private const val API_KEY = "sk_abc123xyz789"

    // HIGH: Memory leak - Handler in Activity
    private val handler = Handler(Looper.getMainLooper())

    // HIGH: Memory leak - no cleanup
    private val runnable = Runnable {
        // Doing work on main thread
    }

    override fun onResume() {
        super.onResume()
        handler.post(runnable)
    }

    // MEDIUM: Missing cleanup
    override fun onDestroy() {
        super.onDestroy()
        // Should remove callbacks
    }
}

class NetworkClient {

    // CRITICAL: Hardcoded secret
    private const val SECRET_KEY = "secret_key_12345"

    suspend fun fetchData() = withContext(Dispatchers.IO) {
        // Simulating network call
        delay(1000)
        "data"
    }

    // MEDIUM: Unsafe nullable
    fun processInput(text: String?): Int {
        return text!!.length  // Force unwrap - potential NPE
    }
}
