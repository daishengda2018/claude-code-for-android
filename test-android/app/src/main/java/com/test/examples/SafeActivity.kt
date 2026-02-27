package com.test.examples

import android.app.Activity
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Example: Safe Activity demonstrating best practices
 *
 * This file shows correct patterns for:
 * - Null safety
 * - Handler lifecycle management
 * - Coroutine usage
 */

class SafeActivity : Activity() {

    // ========================================
    // Null Safety Examples
    // ========================================

    private var nullableText: String? = null

    fun demonstrateSafeCall() {
        // ✅ CORRECT: Safe call with default value
        val length = nullableText?.length ?: 0
        println("Text length: $length")
    }

    fun demonstrateExplicitNullCheck() {
        // ✅ CORRECT: Explicit null check with early return
        val text = nullableText ?: return
        println("Text length: ${text.length}")
    }

    fun demonstrateNotNullAssertion(): Int {
        // ✅ CORRECT: Only use !! when you're certain value is not null
        val assuredText = nullableText!!
        return assuredText.length
    }

    // ========================================
    // Handler Memory Leak Prevention
    // ========================================

    // ✅ CORRECT: Handler as member variable with cleanup
    private val handler = Handler(Looper.getMainLooper())
    private val runnable = Runnable {
        // Main thread work
    }

    override fun onResume() {
        super.onResume()
        handler.post(runnable)
    }

    override fun onDestroy() {
        super.onDestroy()
        // ✅ CRITICAL: Remove callbacks to prevent memory leak
        handler.removeCallbacks(runnable)
        handler.removeCallbacksAndMessages(null)
    }

    // ========================================
    // Coroutine Best Practices
    // ========================================

    private val job = Job()
    private val scope = kotlinx.coroutines.CoroutineScope(Dispatchers.Main + job)

    fun demonstrateCoroutineWithCleanup() {
        scope.launch {
            // Coroutine work
            delay(1000)
            println("Coroutine completed")
        }
    }

    override fun onPause() {
        super.onPause()
        // ✅ CORRECT: Cancel coroutines when activity pauses
        job.cancel()
    }

    // ========================================
    // ViewModel Pattern
    // ========================================

    fun demonstrateViewModelPattern() {
        // ✅ CORRECT: Use ViewModel to preserve UI state
        // This would typically be injected via dependency injection
        // viewModel.observe(this) { state ->
        //     updateUI(state)
        // }
    }

    // ========================================
    // Safe Collection Operations
    // ========================================

    fun processList(items: List<String>?) {
        // ✅ CORRECT: Safe collection access
        val firstItem = items?.firstOrNull() ?: "default"
        println("First item: $firstItem")
    }

    // ========================================
    // Proper Error Handling
    // ========================================

    fun demonstrateErrorHandling() {
        try {
            riskyOperation()
        } catch (e: Exception) {
            // ✅ CORRECT: Proper exception handling
            println("Error occurred: ${e.message}")
        }
    }

    private fun riskyOperation() {
        // Some risky operation
    }
}
