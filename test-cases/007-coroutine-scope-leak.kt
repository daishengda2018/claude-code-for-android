// Test Case 007: CoroutineScope Leak
// Expected Detection: HIGH (QUAL-004)
// Category: Memory / Lifecycle

package com.test.quality

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

/**
 * This file demonstrates CoroutineScope leaks that the plugin should detect.
 *
 * Issues to detect:
 * [ ] Plugin detects CoroutineScope not tied to lifecycle
 * [ ] Plugin detects missing cleanup mechanism
 * [ ] Plugin severity is HIGH
 * [ ] Plugin suggests lifecycle-aware alternatives
 */

class LeakyScope {

    // ========================================
    // Issue 1: CoroutineScope without lifecycle awareness
    // ========================================

    // ❌ BUG: CoroutineScope not tied to any lifecycle
    // Work continues even after object is destroyed
    private val scope = CoroutineScope(Dispatchers.Main + Job())

    fun startWork() {
        scope.launch {
            // Long-running work that leaks
            kotlinx.coroutines.delay(10000)
            println("Work completed")
        }
    }

    // ========================================
    // Issue 2: No cancellation method
    // ========================================

    // ❌ BUG: No way to cancel ongoing work
    // Memory leak until work completes naturally

    fun startMoreWork() {
        scope.launch {
            kotlinx.coroutines.delay(15000)
            println("More work completed")
        }
    }

    // ========================================
    // Issue 3: Multiple coroutines without tracking
    // ========================================

    fun startMultipleWork() {
        repeat(5) {
            scope.launch {
                kotlinx.coroutines.delay(5000)
                println("Work $it completed")
            }
        }
    }
}

// ========================================
// More Leak Examples
// ========================================

class LeakyRepository {

    // ❌ BUG: Repository with CoroutineScope but no cleanup
    private val scope = CoroutineScope(Dispatchers.IO)

    fun fetchData() {
        scope.launch {
            // Network call that leaks
            kotlinx.coroutines.delay(3000)
            println("Data fetched")
        }
    }
}

// ========================================
// Correct Examples (for reference)
// ========================================

class FixedScope {

    // ✅ CORRECT: Provide cancellation method
    private val scope = CoroutineScope(Dispatchers.Main + Job())

    fun startWork() {
        scope.launch {
            kotlinx.coroutines.delay(10000)
            println("Work completed")
        }
    }

    // ✅ CORRECT: Allow cleanup
    fun cleanup() {
        scope.cancel()
    }
}

// ✅ CORRECT: Use lifecycle-aware components in Android
class AndroidScopedComponent {

    // In Activity/Fragment, use lifecycleScope
    // In ViewModel, use viewModelScope
    // In Service, use Service scope or lifecycle-aware launch

    // Example for Activity:
    /*
    import androidx.lifecycle.lifecycleScope

    override fun onResume() {
        super.onResume()
        lifecycleScope.launch {
            // Work automatically cancelled on lifecycle change
            delay(5000)
            println("Safe work")
        }
    }
    */
}

// ✅ CORRECT: Use use-case pattern for repositories
class FixedRepository(
    private val scope: CoroutineScope // Inject scope from caller
) {
    fun fetchData() {
        scope.launch {
            // Caller controls lifecycle
            kotlinx.coroutines.delay(3000)
            println("Data fetched")
        }
    }
}

// Verification Checklist:
// [ ] Plugin detects CoroutineScope without lifecycle (Issue 1)
// [ ] Plugin detects missing cleanup/cancellation (Issue 2)
// [ ] Plugin detects multiple untracked coroutines (Issue 3)
// [ ] Plugin severity is HIGH
// [ ] Plugin suggests lifecycle-aware alternatives
