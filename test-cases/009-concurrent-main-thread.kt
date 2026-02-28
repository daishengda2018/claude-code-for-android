// Test Case 009: Concurrent Modification - Main Thread (SAFE)
// Expected: Should be SKIPPED (no async context)

package com.test.concurrent

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class SafeConcurrentExample : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // SAFE: Collection modification on main thread
        // Should NOT trigger ConcurrentModification warning
        // because there's no async context evidence
        val numbers = mutableListOf(1, 2, 3, 4, 5)
        numbers.forEach {
            if (it == 3) {
                numbers.remove(it)  // Safe here (main thread only)
            }
        }

        // Another example in init block
        val list = mutableListOf<String>()
        list.forEach { item ->
            if (item.isEmpty()) {
                list.remove(item)  // Safe in init
            }
        }
    }

    private fun processOnMainThread() {
        val data = mutableListOf<Int>()
        data.forEach { value ->
            if (value < 0) {
                data.remove(value)  // Safe (no async context)
            }
        }
    }
}

// Note: This test case verifies that ConcurrentModification
// detection only reports when async context is present.
// All modifications here are on the main thread without
// coroutines, handlers, or other async patterns.
