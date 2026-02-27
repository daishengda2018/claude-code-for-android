// Test Case 002: Handler Memory Leak
// Expected Detection: HIGH
// File: test-cases/memory/002-handler-leak.kt

package com.test.memory

import android.app.Activity
import android.os.Handler
import android.os.Looper

class HandlerLeakActivity : Activity() {

    // HIGH: Non-static Handler holds implicit Activity reference
    private val handler = Handler(Looper.getMainLooper())

    // HIGH: Runnable not cleaned up
    private val runnable = Runnable {
        // Doing work
    }

    override fun onResume() {
        super.onResume()
        handler.post(runnable)
    }

    // HIGH: Missing cleanup in onDestroy
    override fun onDestroy() {
        super.onDestroy()
        // BUG: Should call handler.removeCallbacks(runnable)
    }
}

class HandlerFixedActivity : Activity() {

    // CORRECT: Use lifecycle-aware components
    private val lifecycleScope = LifecycleScope()

    override fun onResume() {
        super.onResume()
        lifecycleScope.launch {
            // Work is automatically cancelled on destroy
        }
    }
}

// Verification Checklist:
// [ ] Plugin detects Handler as member variable
// [ ] Plugin detects missing cleanup in onDestroy
// [ ] Plugin suggests using lifecycle-aware coroutines
// [ ] Plugin severity is HIGH
