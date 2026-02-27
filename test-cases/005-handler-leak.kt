// Test Case 005: Single File - Handler Memory Leak
// Expected Detection: HIGH (QUAL-005 - Memory Leak)
package com.test.quality

import android.os.Handler
import android.os.Looper

/**
 * HIGH: Non-static Handler holds implicit reference to Activity
 *
 * This test case demonstrates a common Android memory leak pattern where
 * a non-static Handler is used as a member variable of an Activity.
 *
 * The Handler implicitly holds a reference to the Activity (the outer class),
 * preventing garbage collection even after the Activity is destroyed.
 *
 * Detection Pattern (from QUAL-005):
 * - Non-static inner class Handler
 * - postDelayed() with long delay
 * - Missing cleanup in onDestroy()
 */
class LeakyHandler {
    // HIGH: Non-static Handler holds implicit reference to Activity
    private val handler = Handler(Looper.getMainLooper())

    fun postDelayed() {
        handler.postDelayed({
            // This runnable implicitly holds reference to LeakyHandler instance
            // If LeakyHandler is an Activity, this prevents garbage collection
            doSomething()
        }, 5000)  // 5 second delay extends beyond Activity lifecycle
    }

    private fun doSomething() {
        // Simulated work
    }

    // ❌ Missing cleanup: No onDestroy() to call handler.removeCallbacksAndMessages(null)
}
