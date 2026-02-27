package com.test.bugs.handler_leak

import android.app.Activity
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.Toast

/**
 * Test Case 002: Handler Memory Leaks
 *
 * Expected Detection: HIGH
 * Category: Memory / Performance
 *
 * This file demonstrates Handler memory leaks that the plugin should detect.
 *
 * Issues to detect:
 * [ ] Plugin detects Handler as member variable
 * [ ] Plugin detects missing cleanup in onDestroy()
 * [ ] Plugin severity is HIGH
 * [ ] Plugin suggests proper lifecycle management
 */

class LeakyActivity : Activity() {

    // ========================================
    // Issue 1: Handler with implicit Activity reference
    // ========================================

    // ❌ BUG: Non-static Handler holds implicit reference to Activity
    private val handler = Handler(Looper.getMainLooper())

    // ❌ BUG: Runnable not cleaned up
    private val runnable = Runnable {
        // Doing work on main thread
        // This holds implicit reference to LeakyActivity
        Toast.makeText(this@LeakyActivity, "Leaky!", Toast.LENGTH_SHORT).show()
    }

    // ========================================
    // Issue 2: Handler posting delayed message
    // ========================================

    private val delayedHandler = Handler(Looper.getMainLooper())

    // ========================================
    // Issue 3: No cleanup in lifecycle
    // ========================================

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ❌ BUG: Posting delayed message without cleanup
        handler.postDelayed(runnable, 5000)
    }

    override fun onResume() {
        super.onResume()

        // ❌ BUG: Posting runnable without cleanup plan
        handler.post(runnable)
    }

    override fun onDestroy() {
        super.onDestroy()
        // ❌ CRITICAL BUG: Missing cleanup!
        // Should call:
        // - handler.removeCallbacks(runnable)
        // - handler.removeCallbacksAndMessages(null)
        // - delayedHandler.removeCallbacksAndMessages(null)

        // Current implementation:
        // Memory leak! The Handler continues to hold reference to destroyed Activity
    }

    // ========================================
    // Additional Examples (similar issues)
    // ========================================

    private val anotherHandler = Handler(Looper.getMainLooper())

    fun postWork() {
        // ❌ BUG: Posting without considering lifecycle
        anotherHandler.post {
            // This could execute after Activity is destroyed
            updateUI()
        }
    }

    private fun updateUI() {
        // UI update code
    }

    // ========================================
    // Correct Examples (for reference)
    // ========================================

    class SafeActivity : Activity() {

        // ✅ CORRECT: Option 1 - Use lifecycle-aware coroutine
        private val job = kotlinx.coroutines.Job()
        private val scope = kotlinx.coroutines.CoroutineScope(
            kotlinx.coroutines.Dispatchers.Main + job
        )

        override fun onResume() {
            super.onResume()
            scope.launch {
                // Work is automatically cancelled on destroy
                delay(5000)
                Toast.makeText(this@SafeActivity, "Safe!", Toast.LENGTH_SHORT).show()
            }
        }

        override fun onDestroy() {
            super.onDestroy()
            job.cancel() // Proper cleanup
        }

        // ✅ CORRECT: Option 2 - Handler with proper cleanup
        private val safeHandler = Handler(Looper.getMainLooper())
        private val safeRunnable = Runnable {
            Toast.makeText(this@SafeActivity, "Safe!", Toast.LENGTH_SHORT).show()
        }

        override fun onPause() {
            super.onPause()
            safeHandler.removeCallbacks(safeRunnable)
            safeHandler.removeCallbacksAndMessages(null)
        }

        // ✅ CORRECT: Option 3 - Use WeakReference
        private val weakHandler = Handler(Looper.getMainLooper())
        private val weakRunnable = Runnable {
            // Use weak reference to avoid leak
        }

        override fun onStop() {
            super.onStop()
            weakHandler.removeCallbacks(weakRunnable)
        }
    }
}
